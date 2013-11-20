/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REContext.h"
#import "REAbstractEntity.h"

static REContext *__defaultContext = nil;

@interface REContext ()
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, strong) NSMutableDictionary *childContexts;
@property (nonatomic, strong) NSMutableDictionary *entities;
@end

@implementation REContext

- (id)init
{
    if (self = [super init]) {
        self.childContexts = [NSMutableDictionary dictionary];
        self.entities      = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name
{
    if (self = [self init]) {
        self.name = name;
    }
    return self;
}

+ (instancetype)defaultContext
{
    return __defaultContext ?: (__defaultContext = [[self alloc] init]);
}

- (instancetype)childContextWithName:(NSString *)name
{
    return self.childContexts[name] ?: (self.childContexts[name] = [[REContext alloc] initWithName:name]);
}

#pragma mark -

- (REAbstractEntity *)entityWithIdentifier:(id<NSCopying>)identifier class:(__unsafe_unretained Class)klass
{
    return self.entities[identifier] ?: (self.entities[identifier] = [[klass alloc] initWithIdentifier:identifier]);
}

@end
