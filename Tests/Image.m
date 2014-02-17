/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "Image.h"
#import "REURLTransformer.h"

@implementation Image

@dynamic originalURL, thumbnailURL, contentType;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"content_type"
                      translatedKey:@"contentType"];
    
    [translator addRuleForSourceKey:@"original_url"
                      translatedKey:@"originalURL"];
    
    [translator addRuleForSourceKey:@"thumbnail_url"
                      translatedKey:@"thumbnailURL"];
}

+ (void)valueTransformer:(REValueTransformer *)transformer
{
    REURLTransformer *URLTransformer = [[REURLTransformer alloc] init];
    
    [transformer addTransformer:URLTransformer
                         forKey:@"thumbnailURL"];
    
    [transformer addTransformer:URLTransformer
                         forKey:@"originalURL"];
}

+ (NSString *)identifierKey
{
    return nil;
}

@end
