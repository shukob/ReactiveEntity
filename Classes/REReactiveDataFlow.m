/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveDataFlow.h"
#import <objc/runtime.h>

@interface NSObject (ReactiveDataFlows)
@property (readonly) NSMutableArray *reactiveDataFlowsInternal;
@end

@implementation NSObject (ReactiveDataFlows)

- (NSMutableArray *)reactiveDataFlowsInternal
{
    const void * key = "reactiveDataFlows";
    if (objc_getAssociatedObject(self, key) == nil) {
        objc_setAssociatedObject(self, key, [NSMutableArray array], OBJC_ASSOCIATION_RETAIN);
    }
    return objc_getAssociatedObject(self, key);
}

@end

@interface REReactiveDataFlow ()
@property (nonatomic, weak)   id owner;
@property (nonatomic, copy)   void(^block)(id owner);
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation REReactiveDataFlow

- (id)initWithOwner:(id)owner name:(NSString *)name queue:(dispatch_queue_t)queue block:(void (^)(id))block
{
    if (self = [super init]) {
        self.owner = owner;
        self.name  = name;
        self.block = block;
        self.queue = queue;
        
        [[owner reactiveDataFlowsInternal] addObject:self];
    }
    return self;
}

- (void)push
{
    if (self.queue) {
        __weak id weakOwner = self.owner;
        dispatch_async(self.queue, ^{ self.block(weakOwner); });
        
    } else {
        self.block(self.owner);
    }
}

- (void)unlink
{
    [[self.owner reactiveDataFlowsInternal] removeObject:self];
}

@end