/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@interface REKeyTranslator : NSObject

- (void)addRuleForSourceKey:(NSString *)sourceKey translatedKey:(NSString *)translatedKey;
- (NSString *)translateKeyForSourceKey:(NSString *)sourceKey;
- (NSString *)restoreSourceKeyForTranslatedKey:(NSString *)translatedKey;

@end