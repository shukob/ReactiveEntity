/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@class REReactiveEntity;
@class REReactiveCollectionAssociation;
@class REAssociatedCollection;

@interface REContext : NSObject

+ (instancetype)defaultContext;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)childContextWithName:(NSString *)name;
- (REReactiveEntity *)entityWithIdentifier:(id <NSCopying>)identifier class:(Class)klass;
- (NSHashTable *)allEntities;

- (REReactiveCollectionAssociation *)collectionAssociationWithCollection:(REAssociatedCollection *)collection
                                                            referenceKey:(NSString *)referenceKey
                                                         otherCollection:(REAssociatedCollection *)otherCollection
                                                              foreignKey:(NSString *)foreignKey;

- (void)registerCollectionAssociationWithCollection:(REAssociatedCollection *)collection
                                       referenceKey:(NSString *)referenceKey
                                    otherCollection:(REAssociatedCollection *)otherCollection
                                         foreignKey:(NSString *)foreignKey;

- (void)clearAllEntities;
- (void)clearAllEntitiesRecursive;

@end