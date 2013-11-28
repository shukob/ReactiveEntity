/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "User.h"

@implementation User

@dynamic ID, name, age, profileImageURL;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
    
    [translator addRuleForSourceKey:@"profile_image_url"
                      translatedKey:@"profileImageURL"];
}

+ (NSString *)identifierKey
{
    return @"ID";
}

@end
