/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REURLTransformer.h"

@implementation REURLTransformer

+ (Class)transformedValueClass
{
    return [NSURL class];
}

+ (BOOL)allowsReverseTransformation { return YES; }

- (id)transformedValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:value];
    }
    return value;
}

- (id)reverseTransformedValue:(id)value
{
    return [value absoluteString];
}

@end
