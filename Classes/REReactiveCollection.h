/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveEntity.h"
#import "REReactiveObject.h"

@interface REReactiveCollection : REReactiveObject

- (instancetype)initWithEntityClass:(Class)entityClass condition:(BOOL(^)(id entity))condition;

- (NSSet *)setRepresentation;
- (NSArray *)sortedArrayWithKeyPath:(NSString *)keyPath ascending:(BOOL)ascending;

- (Class)entityClass;
- (BOOL(^)(id entity))condition;

@end