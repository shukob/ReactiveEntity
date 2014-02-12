/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveCollection.h"

@interface REAssociationMapping : NSObject
@property (readonly) Class entityClass;
@end

@interface REAssociationMappingEntity : REAssociationMapping
@end

@interface REAssociationMappingCollection : REAssociationMapping
@property (readonly) NSString *foreignKey;
@end

@interface REAssociationMapper : NSObject

- (void)registerAssociatedEntityForKey:(NSString *)key entityClass:(Class)entityClass;
- (void)registerAssociatedEntityCollectionForKey:(NSString *)key entityClass:(Class)entityClass foreignKey:(NSString *)foreignKey;

- (REAssociationMapping *)mappingForKey:(NSString *)key;

@end