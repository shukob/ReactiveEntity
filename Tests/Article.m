/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "Article.h"

@implementation Article

@dynamic ID, title, content, author, tags;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
}

+ (void)associationMapper:(REAssociationMapper *)mapper
{
    [mapper registerEntityClass:[User class]
                          forKey:@"author"];
    
    [mapper registerEntityClass:[Tag class]
                          forKey:@"tags"];
}

@end
