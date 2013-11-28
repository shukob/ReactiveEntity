/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REKeyTranslator.h"

@interface REKeyTranslator ()
@property (nonatomic, strong) NSMutableDictionary *rules;
@end

@implementation REKeyTranslator

- (id)init
{
    if (self = [super init]) {
        self.rules = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRuleForSourceKey:(NSString *)sourceKey translatedKey:(NSString *)translatedKey
{
    self.rules[sourceKey] = translatedKey;
}

- (NSString *)translateKeyForSourceKey:(NSString *)sourceKey
{
    return self.rules[sourceKey] ?: sourceKey;
}

- (NSString *)restoreSourceKeyForTranslatedKey:(NSString *)translatedKey
{
    __block NSString *sourceKey = nil;
    [self.rules enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isEqual:translatedKey]) {
            sourceKey = key;
        }
    }];
    return sourceKey;
}

@end
