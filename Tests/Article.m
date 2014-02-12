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
    [mapper registerAssociatedEntityForKey:@"author"
                               entityClass:[User class]];
    
    [mapper registerAssociatedEntityCollectionForKey:@"tags"
                                         entityClass:[Tag class]
                                          foreignKey:@"articles"];
}

@end