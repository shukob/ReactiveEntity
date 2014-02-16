/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "Image.h"

@implementation Image

@dynamic originalURL, thumbnailURL;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"original_url"
                      translatedKey:@"originalURL"];
    
    [translator addRuleForSourceKey:@"thumbnail_url"
                      translatedKey:@"thumbnailURL"];
}

+ (NSString *)identifierKey
{
    return nil;
}

@end
