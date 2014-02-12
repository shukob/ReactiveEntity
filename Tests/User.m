/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "User.h"
#import "Article.h"

@implementation User

@dynamic ID, name, age, profileImageURL, articles;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
    
    [translator addRuleForSourceKey:@"profile_image_url"
                      translatedKey:@"profileImageURL"];
}

+ (void)associationMapper:(REAssociationMapper *)mapper
{
    [mapper registerAssociatedEntityCollectionForKey:@"articles"
                                         entityClass:[Article class]
                                          foreignKey:@"author"];
}

+ (NSString *)identifierKey
{
    return @"ID";
}

@end