/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REEntityModel.h"
#import "REReactiveEntity.h"
#import "REAssociationMapper.h"

static REEntityModel *__defaultEntityModel = nil;

@interface REEntityModel ()
@property (nonatomic, strong) NSMutableDictionary *childrenModel;
@property (nonatomic, strong) NSMutableOrderedSet *variables;
@end

@implementation REEntityModel

- (instancetype)init
{
    if (self = [super init]) {
        self.variables     = [NSMutableOrderedSet orderedSet];
        self.childrenModel = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)defaultEntityModel
{
    return __defaultEntityModel ?: (__defaultEntityModel = [[self alloc] init]);
}

- (instancetype)childEntityModelForEntityName:(NSString *)entityName
{
    return self.childrenModel[entityName] ?: (self.childrenModel[entityName] = [[REEntityModel alloc] init]);
}

+ (instancetype)entityModelForEntityClass:(Class)klass
{
    return [[self defaultEntityModel] childEntityModelForEntityName:[klass entityName]];
}

- (void)addVariableWithKey:(NSString *)key
{
    [self.variables addObject:[key lowercaseString]];
}

- (BOOL)hasVariableForKey:(NSString *)key
{
    return [self.variables containsObject:[key lowercaseString]];
}

- (NSUInteger)variableIndexForKey:(NSString *)key
{
    return [self.variables indexOfObject:[key lowercaseString]];
}

- (NSUInteger)numberOfVariables
{
    return self.variables.count;
}

- (NSArray *)variableKeys
{
    return self.variables.copy;
}

@end
