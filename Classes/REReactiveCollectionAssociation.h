/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@class REAssociatedCollection;

@interface REReactiveCollectionAssociation : NSObject

- (id)initWithCollection:(REAssociatedCollection *)collection1 otherCollection:(REAssociatedCollection *)collection2;

@property (readonly, weak) REAssociatedCollection *collection1;
@property (readonly, weak) REAssociatedCollection *collection2;

@end