/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveEntity.h"

@interface Tag : REReactiveEntity

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *name;

@end