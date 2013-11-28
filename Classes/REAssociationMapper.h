/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@interface REAssociationMapper : NSObject

- (void)registerEntityClass:(Class)entityClass forKey:(NSString *)key;
- (Class)entityClassForKey:(NSString *)key;

@end
