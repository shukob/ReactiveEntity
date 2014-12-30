/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REDependence.h"
#import "REReactiveObject.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface NSObject (ReactiveDependences)
@property (readonly) NSMutableArray *reactiveDependencesInternal;
@end

@implementation NSObject (ReactiveDependences)

- (NSMutableArray *)reactiveDependencesInternal
{
    const void * key = "reactiveDependences";
    if (objc_getAssociatedObject(self, key) == nil) {
        objc_setAssociatedObject(self, key, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN);
    }
    return objc_getAssociatedObject(self, key);
}

@end

@interface REReactiveObject ()
- (NSHashTable *)reactiveInverseDependences;
@end

@interface REDependence ()
@property (nonatomic, weak)   id source;
@property (nonatomic, weak)   REReactiveObject *destination;
@property (nonatomic, copy)   void(^block)(id source);
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation REDependence

- (id)initWithSource:(id)source destination:(REReactiveObject *)destination name:(NSString *)name queue:(dispatch_queue_t)queue block:(void(^)(id source))block
{
    if (self = [super init]) {
        self.source      = source;
        self.destination = destination;
        self.name        = name;
        self.block       = block;
        self.queue       = queue;
        
        [[source reactiveDependencesInternal] addObject:self];
        [[destination reactiveInverseDependences] addObject:self];
        [self push];
    }
    return self;
}

+ (instancetype)addDependenceFromSource:(id)source destination:(REReactiveObject *)destination name:(NSString *)name queue:(dispatch_queue_t)queue block:(void(^)(id source))block
{
    if (name.length > 0) {
        for (REDependence *existsDependence in [source reactiveDependencesInternal]) {
            if ([existsDependence.name isEqualToString:name]) {
                if (existsDependence.destination == destination) {
                    existsDependence.queue = queue;
                    existsDependence.block = block;
                    [existsDependence push];
                    
                    return existsDependence;
                }
                
                [existsDependence unlink];
                break;
            }
        }
    }
    
    return [[self alloc] initWithSource:source destination:destination name:name queue:queue block:block];
}

+ (void)removeDependenceFromSource:(id)source destination:(REReactiveObject *)destination name:(NSString *)name
{
    for (REDependence *dependence in [source reactiveDependencesInternal].copy) {
        if ((name.length == 0 && dependence.name.length == 0) || [dependence.name isEqualToString:name]) {
            [dependence unlink];
        }
    }
}

- (void)push
{
    if (self.queue) {
        __weak id weakSource = self.source;
        dispatch_async(self.queue, ^{ self.block(weakSource); });
        
    } else {
        self.block(self.source);
    }
}

- (void)unlink
{
    [[self.destination reactiveInverseDependences] removeObject:self];
    [[self.source reactiveDependencesInternal] removeObject:self];
}

@end

@implementation NSObject (ReactiveDependence)

- (NSArray *)reactiveDependences
{
    return [(id)(((id(*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"reactiveDependencesInternal"))) copy];
}

- (REDependence *)reactiveDependenceWithName:(NSString *)name
{
    for (REDependence *dependence in self.reactiveDependences) {
        if ([dependence.name isEqualToString:name]) {
            return dependence;
        }
    }
    return nil;
}

@end