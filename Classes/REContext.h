/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@class REReactiveEntity;

@interface REContext : NSObject

+ (instancetype)defaultContext;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)childContextWithName:(NSString *)name;
- (REReactiveEntity *)entityWithIdentifier:(id <NSCopying>)identifier class:(Class)klass;

@end