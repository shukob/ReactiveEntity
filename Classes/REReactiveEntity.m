/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveEntity.h"
#import <objc/runtime.h>

@interface REReactiveEntity ()
@property (nonatomic, copy)   id<NSCopying>   identifier;
@property (nonatomic, strong) NSMutableArray *variables;
@property (nonatomic, strong) NSHashTable    *reactiveDataFlows;
@end

@implementation REReactiveEntity

- (id)init
{
    if (self = [super init]) {
        self.reactiveDataFlows = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier
{
    if (self = [self init]) {
        self.identifier = identifier;
        
        NSUInteger numberOfVariables = [self.class entityModel].numberOfVariables;
        self.variables  = [NSMutableArray arrayWithCapacity:numberOfVariables];
        for (NSUInteger index = 0; index < numberOfVariables; index++) {
            [self.variables addObject:[NSNull null]];
        }
    }
    return self;
}

+ (instancetype)entityWithIdentifier:(id)identifier
{
    return [[self context] entityWithIdentifier:identifier class:self];
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

- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner queue:(dispatch_queue_t)queue block:(void (^)(id owner))block
{
    return [self reactiveDataFlowWithOwner:owner name:nil queue:queue block:block];
}

- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner block:(void (^)(id owner))block
{
    return [self reactiveDataFlowWithOwner:owner queue:nil block:block];
}

- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner name:(const void *)name block:(void(^)(id owner))block
{
    return [self reactiveDataFlowWithOwner:owner name:name queue:nil block:block];
}

- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner name:(const void *)name queue:(dispatch_queue_t)queue block:(void(^)(id owner))block
{
    NSString *nameObject = [NSString stringWithCString:name ?: "" encoding:NSASCIIStringEncoding];
    REReactiveDataFlow *dataFlow = [[REReactiveDataFlow alloc] initWithOwner:owner name:nameObject queue:queue block:block];
    if (nameObject.length > 0) {
        for (REReactiveDataFlow *existsDataFlow in self.reactiveDataFlows.copy) {
            if ([existsDataFlow.name isEqualToString:nameObject]) {
                [existsDataFlow unlink];
                [self.reactiveDataFlows removeObject:existsDataFlow];
            }
        }
    }
    [self.reactiveDataFlows addObject:dataFlow];
    block(owner);
    return dataFlow;
}

- (void)push
{
    for (REReactiveDataFlow *scope in self.reactiveDataFlows) {
        [scope push];
    }
}

#pragma mark -

- (id)valueForKey:(NSString *)key
{
    REEntityModel *entityModel = [self.class entityModel];
    if ([entityModel hasVariableForKey:key]) {
        id value = self.variables[[entityModel variableIndexForKey:key]];
        if ([value isKindOfClass:[NSNull class]]) {
            return nil;
        } else {
            return value;
        }
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
    REEntityModel *entityModel = [self.class entityModel];
    if ([entityModel hasVariableForKey:key]) {
        self.variables[[entityModel variableIndexForKey:key]] = value ?: [NSNull null];
        if (push) {
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
    NSString *identifierKey = [translator restoreSourceKeyForTranslatedKey:[self identifierKey]] ?: [self identifierKey];
    REReactiveEntity *entity = [self entityWithIdentifier:attributes[identifierKey]];
    [entity assignAttributesFromDictionary:attributes];
    return entity;
}

- (void)assignAttributesFromDictionary:(NSDictionary *)attributes
{
    REKeyTranslator      *translator         = [self.class entityModel].massAssignmentKeyTranslator;
    REAssociationMapper *associationMapper = [self.class entityModel].associationMapper;
    for (NSString *key in attributes.allKeys) {
        id value = attributes[key];
        id translatedKey = [translator translateKeyForSourceKey:key];
        Class entityClass = [associationMapper entityClassForKey:key];
        if (entityClass) {
            if ([value isKindOfClass:[NSArray class]]) {
                value = [entityClass importFromListOfDictionary:value];
                
            } else if([value isKindOfClass:[NSDictionary class]]) {
                value = [entityClass importFromDictionary:value];
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
