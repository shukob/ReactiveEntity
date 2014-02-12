/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REAssociationMapper.h"
#import "REReactiveEntity.h"

@interface REAssociationMapper ()
@property (nonatomic, strong) NSMutableDictionary *rules;
@end

@implementation REAssociationMapper

- (id)init
{
    if (self = [super init]) {
        self.rules = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerEntityClass:(Class)entityClass forKey:(NSString *)key
{
    self.rules[key] = NSStringFromClass(entityClass);
}

- (Class)entityClassForKey:(NSString *)key
{
    return self.rules[key] ? NSClassFromString(self.rules[key]) : nil;
}

@end
