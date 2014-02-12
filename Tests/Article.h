/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "ReactiveEntity.h"
#import "User.h"
#import "Tag.h"

@interface Article : REReactiveEntity

@property NSNumber *ID;
@property NSString *title;
@property NSString *content;
@property User     *author;

@property REAssociatedCollection *tags;

@end
