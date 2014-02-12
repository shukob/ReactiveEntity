/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "ReactiveEntity.h"

@interface User : REReactiveEntity

@property NSNumber *ID;
@property NSString *name;
@property NSNumber *age;
@property NSString *profileImageURL;

@property REAssociatedCollection *articles;

@end