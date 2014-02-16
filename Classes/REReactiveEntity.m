/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "ReactiveEntity.h"
#import <objc/runtime.h>

@interface REReactiveEntity ()
@property (nonatomic, copy)   id<NSCopying>   identifier;
@property (nonatomic, strong) NSMutableArray *variables;
@property BOOL isolated;
@end

@implementation REReactiveEntity

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier
{
    if (self = [self init]) {
        self.identifier = identifier;
        NSUInteger numberOfVariables = [self.class entityModel].numberOfVariables;
        self.variables  = [NSMutableArray arrayWithCapacity:numberOfVariables];
        for (NSUInteger index = 0; index < numberOfVariables; index++) {
            [self.variables addObject:[NSNull null]];
        }
        
        if ([self.class hasIdentifierProperty]) {
            NSString *identifierKey = [self.class identifierKey];
            [self setValue:identifier forKey:identifierKey];
        }
    }
    return self;
}

+ (instancetype)entityWithIdentifier:(id)identifier
{
    return [[self context] entityWithIdentifier:identifier class:self];
}

+ (instancetype)entityWithUnspecificIdentifier
{
    static NSInteger identifier = 1;
    return [self entityWithIdentifier:@(identifier++)];
}

+ (REContext *)context
{
    return [[REContext defaultContext] childContextWithName:[self entityName]];
}

+ (REEntityModel *)entityModel
{
    return [REEntityModel entityModelForEntityClass:self];
}

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

+ (NSSet *)allEntities
{
    return [[self context] allEntities].setRepresentation;
}

+ (void)initialize
{
    [super initialize];
    
    if (self != [REReactiveEntity class]) {
        [self defineAccessorsForProperties];
        
        REKeyTranslator *massAssignmentKeyTranslator = [[REKeyTranslator alloc] init];
        [self keyTranslatorForMassAssignment:massAssignmentKeyTranslator];
        [self entityModel].massAssignmentKeyTranslator = massAssignmentKeyTranslator;
        
        REAssociationMapper *associationMapper = [[REAssociationMapper alloc] init];
        [self associationMapper:associationMapper];
        [self entityModel].associationMapper = associationMapper;
    }
}

#pragma mark -

+ (void)defineAccessorsForProperties
{
    unsigned int propertiesCount;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertiesCount);
    
    for(int index = 0; index < propertiesCount; index++) {
        objc_property_t property = properties[index];
        [self defineAccessorsForProperty:property];
    }
    
    free(properties);
}

+ (void)defineAccessorsForProperty:(objc_property_t)property
{
    NSString *key = [NSString stringWithUTF8String:property_getName(property)];
    
    if (! [self shouldDefineAccessorForKey:key]) {
        return;
    }
    
    REEntityModel *entityModel = [self entityModel];
    [entityModel addVariableWithKey:key];
    
    [self defineGetterForKey:key];
    [self defineSetterForKey:key];
}

#pragma mark -

- (id)valueForKey:(NSString *)key
{
    REEntityModel       *entityModel       = [self.class entityModel];
    REAssociationMapper *associationMapper = entityModel.associationMapper;
    
    if ([entityModel hasVariableForKey:key]) {
        REAssociationMapping *mapping = [associationMapper mappingForKey:key];
        
        NSUInteger index = [entityModel variableIndexForKey:key];
        id value = self.variables[index];
        
        if ([value isKindOfClass:[NSNull class]]) {
            value = nil;
        }
        
        if (value) {
            return value;
        }
        
        if (mapping && [mapping isKindOfClass:[REAssociationMappingCollection class]]) {
            NSString *foreignKey = [(REAssociationMappingCollection *)mapping foreignKey];
            __block REAssociatedCollection *collection = [[REAssociatedCollection alloc] initWithOwner:self
                                                                                          referenceKey:key
                                                                                           entityClass:mapping.entityClass
                                                                                            foreignKey:foreignKey];
            self.variables[index] = collection;
            return collection;
        }
        
        return nil;
        
    } else {
        return [super valueForKey:key];
    }
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [self setValue:value forKey:key push:YES];
}

- (void)setValue:(id)value forKey:(NSString *)key push:(BOOL)push
{
    NSString *identifierKey = [self.class identifierKey];
    BOOL isPrimaryKey = identifierKey && [key isEqualToString:identifierKey];
    
    REEntityModel *entityModel = [self.class entityModel];
    if (isPrimaryKey || [entityModel hasVariableForKey:key]) {
        id currentIdentifier = [self valueForKey:key];
        BOOL hasChanged = ! [currentIdentifier isEqual:value];
        if (! hasChanged) return;
        
        if (currentIdentifier != nil && isPrimaryKey) {
            [[NSException exceptionWithName:@"CanNotModifyIdentifier" reason:nil userInfo:nil] raise];
        }
        
        NSInteger index = [entityModel variableIndexForKey:key];
        self.variables[index] = value ?: [NSNull null];
        if (push && ! _isolated) {
            [self push];
        }
    } else {
#if RE_RAISES_WHEN_NOT_DEFINED_ATTRIBUTE_ASSIGNED
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:[NSString stringWithFormat:@"`%@` is not defined in class (%@)", key, self]
                               userInfo:nil] raise];
#endif
    }
}

+ (BOOL)hasIdentifierProperty
{
    NSString *identifierKey = [self identifierKey];
    return identifierKey && [[self entityModel] variableIndexForKey:identifierKey] != NSNotFound;
}

#pragma mark -

- (id)valueForSelector:(SEL)selector
{
    NSString *key = NSStringFromSelector(selector);
    return [self valueForKey:key];
}

- (void)setValue:(id)value forSelector:(SEL)selector
{
    NSMutableString *key = NSStringFromSelector(selector).mutableCopy;
    [key deleteCharactersInRange:NSMakeRange(0, @"set".length)];
    [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    [self setValue:value forKey:key];
}

#pragma mark -

- (instancetype)copiedEntityWithNewIdentifier:(id<NSCopying>)identifier
{
    REReactiveEntity *entity = [self.class entityWithIdentifier:identifier];
    entity.variables = self.variables.mutableCopy;
    return entity;
}

- (instancetype)isolatedEntity
{
    REReactiveEntity *entity = [[self.class alloc] init];
    entity.variables = self.variables.mutableCopy;
    entity.isolated = YES;
    return entity;
}

#pragma mark -

- (id)__getterTemplate
{
    return [self valueForSelector:_cmd];
}

- (void)__setterTemplate:(id)given
{
    [self setValue:given forSelector:_cmd];
}

#pragma mark -

+ (SEL)getterSelectorForKey:(NSString *)key
{
    return NSSelectorFromString(key);
}

+ (SEL)setterSelectorForKey:(NSString *)key
{
    NSMutableString *buffer = key.mutableCopy;
    [buffer replaceCharactersInRange:NSMakeRange(0, 1) withString:[buffer substringToIndex:1].uppercaseString];
    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", buffer]);
}

#pragma mark -

+ (void)defineMethodForSelector:(SEL)selector template:(SEL)template
{
    Method method = class_getInstanceMethod(self.class, template);
    IMP imp = method_getImplementation(method);
    const char* types = method_getTypeEncoding(method);
    class_addMethod(self, selector, imp, types);
}

#pragma mark -

+ (void)defineGetterForKey:(NSString *)key
{
    SEL selector = [self getterSelectorForKey:key];
    
    if (class_getInstanceMethod(self, selector) != nil) {
        NSAssert(NO, @"Getter already defined");
    }
    
    [self defineMethodForSelector:selector template:@selector(__getterTemplate)];
}

+ (void)defineSetterForKey:(NSString *)key
{
    SEL selector = [self setterSelectorForKey:key];
    
    if (class_getInstanceMethod(self, selector) != nil) {
        NSAssert(NO, @"Setter already defined");
    }
    
    [self defineMethodForSelector:selector template:@selector(__setterTemplate:)];
}

#pragma mark -

+ (BOOL)shouldDefineAccessorForKey:(NSString *)key
{
    return YES;
}

+ (NSString *)identifierKey
{
    return @"ID";
}

@end

@implementation REReactiveEntity (MassAssignment)

+ (instancetype)importFromDictionary:(NSDictionary *)attributes
{
    REKeyTranslator *translator = [self.class entityModel].massAssignmentKeyTranslator;
    REReactiveEntity *entity = nil;
    
    if ([self identifierKey]) {
        NSString *identifierKey = [translator restoreSourceKeyForTranslatedKey:[self identifierKey]] ?: [self identifierKey];
        id<NSCopying> identifier = attributes[identifierKey];
        entity = [self entityWithIdentifier:identifier];
        
    } else {
        entity = [self entityWithUnspecificIdentifier];
    }
    
    [entity assignAttributesFromDictionary:attributes];
    return entity;
}

- (void)assignAttributesFromDictionary:(NSDictionary *)attributes
{
    REKeyTranslator     *translator        = [self.class entityModel].massAssignmentKeyTranslator;
    REAssociationMapper *associationMapper = [self.class entityModel].associationMapper;
    
    NSString *identifierKey = [self.class identifierKey];
    
    for (NSString *key in attributes.allKeys) {
        id value = attributes[key];
        id translatedKey = [translator translateKeyForSourceKey:key];
        
        if (identifierKey && [translatedKey isEqualToString:identifierKey]) {
            continue;
        }
        
        REAssociationMapping *mapping = [associationMapper mappingForKey:key];
        
        if (mapping && [mapping isKindOfClass:[REAssociationMappingEntity class]]) {
            REAssociationMappingEntity *entityMapping = (id)mapping;
            if ([value isKindOfClass:[NSArray class]]) {
                value = [entityMapping.entityClass importFromListOfDictionary:value];
                
            } else if([value isKindOfClass:[NSDictionary class]]) {
                value = [entityMapping.entityClass importFromDictionary:value];
            }
        }
        [self setValue:value forKey:translatedKey push:NO];
    }
    
    [self push];
}

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
}

+ (NSArray *)importFromListOfDictionary:(NSArray *)listOfDictionary
{
    NSMutableArray *buffer = [NSMutableArray array];
    for (NSDictionary *attribute in listOfDictionary) {
        [buffer addObject:[self importFromDictionary:attribute]];
    }
    return buffer.copy;
}

@end

@implementation REReactiveEntity (Association)


+ (void)associationMapper:(REAssociationMapper *)mapper
{
}

@end