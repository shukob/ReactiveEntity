/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveCollectionAssociation.h"

@implementation REReactiveCollectionAssociation

- (id)initWithCollection:(REAssociatedCollection *)collection1 otherCollection:(REAssociatedCollection *)collection2
{
    if (self = [super init]) {
        _collection1 = collection1;
        _collection2 = collection2;
    }
    return self;
}

@end