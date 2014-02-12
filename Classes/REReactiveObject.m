/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveObject.h"

@interface REReactiveObject ()

@property (nonatomic, strong) NSHashTable *reactiveInverseDependences;

@end

@implementation REReactiveObject

- (id)init
{
    if (self = [super init]) {
        self.reactiveInverseDependences = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

#pragma mark -

- (REDependence *)addDependenceFromSource:(id)source queue:(dispatch_queue_t)queue block:(void (^)(id source))block
{
    return [self addDependenceFromSource:source name:nil queue:queue block:block];
}

- (REDependence *)addDependenceFromSource:(id)source block:(void (^)(id source))block
{
    return [self addDependenceFromSource:source name:nil queue:nil block:block];
}

- (REDependence *)addDependenceFromSource:(id)source name:(const void *)name block:(void(^)(id source))block
{
    return [self addDependenceFromSource:source name:name queue:nil block:block];
}

- (REDependence *)addDependenceFromSource:(id)source name:(const void *)name queue:(dispatch_queue_t)queue block:(void(^)(id source))block
{
    NSString *nameObject = [NSString stringWithCString:name ?: "" encoding:NSASCIIStringEncoding];
    return [REDependence addDependenceFromSource:source destination:self name:nameObject queue:queue block:block];
}

- (void)push
{
    for (REDependence *dependence in self.reactiveInverseDependences) {
        [dependence push];
    }
}

@end