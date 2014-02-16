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

@dynamic ID, name, age, profileImage, articles;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
    
    [translator addRuleForSourceKey:@"profile_image"
                      translatedKey:@"profileImage"];
}

+ (void)associationMapper:(REAssociationMapper *)mapper
{
    [mapper registerAssociatedEntityForKey:@"profileImage"
                               entityClass:[Image class]];
    
    [mapper registerAssociatedEntityCollectionForKey:@"articles"
                                         entityClass:[Article class]
                                          foreignKey:@"author"];
}

+ (NSString *)identifierKey
{
    return @"ID";
}

@end