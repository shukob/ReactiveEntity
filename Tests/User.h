/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "ReactiveEntity.h"
#import "Image.h"

@interface User : REReactiveEntity

@property NSNumber *ID;
@property NSString *name;
@property NSNumber *age;

@property Image *profileImage;

@property REAssociatedCollection *articles;

@end