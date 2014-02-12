/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "Tag.h"
#import "Article.h"

@implementation Tag

@dynamic ID, name, articles;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
}

+ (void)associationMapper:(REAssociationMapper *)mapper
{
    [mapper registerAssociatedEntityCollectionForKey:@"articles"
                                         entityClass:[Article class]
                                          foreignKey:@"tags"];
}

@end
