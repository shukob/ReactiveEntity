/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REValueTransformer.h"

@implementation REValueTransformer
{
    NSMutableDictionary *_transformers;
}

- (id)init
{
    if (self = [super init]) {
        _transformers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)transformedValue:(id)value forKey:(NSString *)key
{
    key = key.lowercaseString;
    NSArray *transformers = [self transformersForKey:key];
    id buffer = value;
    for (NSValueTransformer *transformer in transformers) {
        buffer = [transformer transformedValue:buffer];
    }
    return buffer;
}

- (void)addTransformers:(NSArray *)transformers forKey:(NSString *)key
{
}

- (void)addTransformer:(NSValueTransformer *)transformer forKey:(NSString *)key
{
    key = key.lowercaseString;
    NSMutableArray *keyedTransformers = _transformers[key] ?: (_transformers[key] = [NSMutableArray array]);
    [keyedTransformers addObject:transformer];
}

- (NSArray *)transformersForKey:(NSString *)key
{
    key = key.lowercaseString;
    return _transformers[key] ? [_transformers[key] copy] : @[];
}

@end