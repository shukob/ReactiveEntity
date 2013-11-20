/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@class REAbstractEntity;

@interface REContext : NSObject

+ (instancetype)defaultContext;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)childContextWithName:(NSString *)name;
- (REAbstractEntity *)entityWithIdentifier:(id <NSCopying>)identifier class:(Class)klass;

@end