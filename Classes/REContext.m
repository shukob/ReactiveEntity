/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REContext.h"
#import "REReactiveEntity.h"
#import "REReactiveCollectionAssociation.h"

static REContext *__defaultContext = nil;

@interface REContext ()
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, strong) NSMutableDictionary *childContexts;
@property (nonatomic, strong) NSMutableDictionary *entities;
@property (nonatomic, strong) NSMutableDictionary *collectionAssociations;
@property (nonatomic, strong) NSHashTable *allEntities;
@end

@implementation REContext

- (id)init
{
    if (self = [super init]) {
        self.childContexts = [NSMutableDictionary dictionary];
        self.entities      = [NSMutableDictionary dictionary];
        self.allEntities   = [NSHashTable weakObjectsHashTable];
        self.collectionAssociations = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
{
    if (self = [self init]) {
        self.name = name;
    }
    return self;
}

+ (instancetype)defaultContext
{
    return __defaultContext ?: (__defaultContext = [[self alloc] init]);
}

- (instancetype)childContextWithName:(NSString *)name
{
    return self.childContexts[name] ?: (self.childContexts[name] = [[REContext alloc] initWithName:name]);
}

#pragma mark -

- (REReactiveEntity *)entityWithIdentifier:(id<NSCopying>)identifier class:(__unsafe_unretained Class)klass
{
    if (self.entities[identifier] == nil) {
        id entity = [[klass alloc] initWithIdentifier:identifier];
        self.entities[identifier] = entity;
        [self.allEntities addObject:entity];
        return entity;
        
    } else {
        return self.entities[identifier];
    }
}

- (REReactiveCollectionAssociation *)collectionAssociationWithCollection:(REAssociatedCollection *)collection referenceKey:(NSString *)referenceKey otherCollection:(REAssociatedCollection *)otherCollection foreignKey:(NSString *)foreignKey
{
    NSSet *key = [NSSet setWithObjects:@[ foreignKey, collection ], @[ referenceKey, otherCollection ], nil];
    return self.collectionAssociations[key];
}

- (void)registerCollectionAssociationWithCollection:(REAssociatedCollection *)collection referenceKey:(NSString *)referenceKey otherCollection:(REAssociatedCollection *)otherCollection foreignKey:(NSString *)foreignKey
{
    NSSet *key = [NSSet setWithObjects:@[ foreignKey, collection ], @[ referenceKey, otherCollection ], nil];
    self.collectionAssociations[key] = [[REReactiveCollectionAssociation alloc] initWithCollection:collection otherCollection:otherCollection];
}

#pragma mark -

- (void)clearAllEntities
{
    [self.allEntities removeAllObjects];
    [self.entities removeAllObjects];
}

- (void)clearAllEntitiesRecursive
{
    [self clearAllEntities];
    
    for (REContext *childContext in [self.childContexts allValues]) {
        [childContext clearAllEntitiesRecursive];
    }
}

@end