/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "ReactiveEntity.h"

@interface Tag : REReactiveEntity

@property NSNumber *ID;
@property NSString *name;

@property REAssociatedCollection *articles;

@end