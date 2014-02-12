/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REAssociationMapper.h"
#import "REReactiveEntity.h"


@implementation REAssociationMappingEntity
@end

@implementation REAssociationMapping

- (id)initWithEntityClass:(Class)entityClass
{
    if (self = [super init]) {
        _entityClass = entityClass;
    }
    return self;
}

@end

@implementation REAssociationMappingCollection

- (id)initWithEntityClass:(Class)entityClass foreignKey:(NSString *)foreignKey
{
    if (self = [super initWithEntityClass:entityClass]) {
        _foreignKey  = foreignKey;
    }
    return self;
}
@end

@interface REAssociationMapper ()
@property (nonatomic, strong) NSMutableDictionary *mappings;
@end

@implementation REAssociationMapper

- (id)init
{
    if (self = [super init]) {
        self.mappings = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerAssociatedEntityForKey:(NSString *)key entityClass:(Class)entityClass
{
    self.mappings[key] = [[REAssociationMappingEntity alloc] initWithEntityClass:entityClass];
}

- (void)registerAssociatedEntityCollectionForKey:(NSString *)key entityClass:(Class)entityClass foreignKey:(NSString *)foreignKey
{
    self.mappings[key] = [[REAssociationMappingCollection alloc] initWithEntityClass:entityClass
                                                                          foreignKey:foreignKey];
}

- (REAssociationMapping *)mappingForKey:(NSString *)key
{
    return self.mappings[key] ?: nil;
}

@end
