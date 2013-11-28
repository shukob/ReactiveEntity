/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REAbstractEntity.h"
#import <objc/runtime.h>
#import "RESynchronizedScope.h"

@interface REAbstractEntity ()
@property (nonatomic, copy)   id<NSCopying>   identifier;
@property (nonatomic, strong) NSMutableArray *variables;
@property (nonatomic, strong) NSHashTable    *synchronizedScopes;
@end

@implementation REAbstractEntity

- (id)init
{
    if (self = [super init]) {
        self.synchronizedScopes = [NSHashTable weakObjectsHashTable];
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
    
    if (self != [REAbstractEntity class]) {
        [self defineAccessorsForProperties];
        
        REKeyTranslator *massAssignmentKeyTranslator = [[REKeyTranslator alloc] init];
        [self keyTranslatorForMassAssignment:massAssignmentKeyTranslator];
        [self entityModel].massAssignmentKeyTranslator = massAssignmentKeyTranslator;
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

- (void)synchronizedScopeWithOwner:(id)owner queue:(dispatch_queue_t)queue block:(void (^)(id owner))block
{
    __weak id weakOwner = owner;
    void(^caller)(void) = ^{ block(weakOwner); };
    RESynchronizedScope *scope = [[RESynchronizedScope alloc] initWithBlock:caller queue:queue];
    NSString *referenceKey = [NSString stringWithFormat:@"__synchronizedScope_%ld", (long)self];
    objc_setAssociatedObject(owner, [referenceKey cStringUsingEncoding:NSASCIIStringEncoding], scope, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.synchronizedScopes addObject:scope];
    caller();
}

- (void)synchronizedScopeWithOwner:(id)owner block:(void (^)(id owner))block
{
    [self synchronizedScopeWithOwner:owner queue:nil block:block];
}

- (void)synchronize
{
    for (RESynchronizedScope *scope in self.synchronizedScopes) {
        [scope execute];
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
    [self setValue:value forKey:key synchronize:YES];
}

- (void)setValue:(id)value forKey:(NSString *)key synchronize:(BOOL)synchronize
{
    REEntityModel *entityModel = [self.class entityModel];
    if ([entityModel hasVariableForKey:key]) {
        self.variables[[entityModel variableIndexForKey:key]] = value ?: [NSNull null];
        if (synchronize) {
            [self synchronize];
        }
    } else {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:nil userInfo:nil] raise];
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

@end


@implementation REAbstractEntity (MassAssignment)

+ (instancetype)importFromDictionary:(NSDictionary *)attributes identifierKey:(id)identifierKey
{
    REAbstractEntity *entity = [self entityWithIdentifier:attributes[identifierKey]];
    [entity assignAttributesFromDictionary:attributes];
    return entity;
}

- (void)assignAttributesFromDictionary:(NSDictionary *)attributes
{
    REKeyTranslator *translator = [self.class entityModel].massAssignmentKeyTranslator;
    for (NSString *key in attributes.allKeys) {
        id value = attributes[key];
        id translatedKey = [translator translateKeyForSourceKey:key];
        [self setValue:value forKey:translatedKey synchronize:NO];
    }
    [self synchronize];
}

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
}

+ (NSArray *)importFromListOfDictionary:(NSArray *)listOfDictionary identifierKey:(id)identifierKey
{
    NSMutableArray *buffer = [NSMutableArray array];
    for (NSDictionary *attribute in listOfDictionary) {
        [buffer addObject:[self importFromDictionary:attribute identifierKey:identifierKey]];
    }
    return buffer.copy;
}

@end
