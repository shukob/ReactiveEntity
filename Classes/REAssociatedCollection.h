/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveCollection.h"

@interface REAssociatedCollection : REReactiveCollection

- (id)initWithOwner:(REReactiveEntity *)owner referenceKey:(NSString *)referenceKey entityClass:(Class)entityClass foreignKey:(NSString *)foreignKey;
- (void)addEntity:(REReactiveEntity *)entity;

@end