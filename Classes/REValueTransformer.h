/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@interface REValueTransformer : NSObject

- (NSArray *)transformersForKey:(NSString *)key;
- (void)addTransformer:(NSValueTransformer *)transformer forKey:(NSString *)key;

- (id)transformedValue:(id)value forKey:(NSString *)key;

@end