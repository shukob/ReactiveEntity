/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REAbstractEntity.h"
#import "User.h"
#import "Tag.h"

@interface Article : REAbstractEntity

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) User     *author;
@property (nonatomic, strong) NSArray  *tags;

@end
