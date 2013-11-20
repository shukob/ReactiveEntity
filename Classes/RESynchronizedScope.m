/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "RESynchronizedScope.h"

@interface RESynchronizedScope ()
@property (nonatomic, copy)   void(^block)(void);
@property (nonatomic, assign) dispatch_queue_t queue;
@end

@implementation RESynchronizedScope

- (id)initWithBlock:(void (^)(void))block queue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        self.block = block;
        self.queue = queue;
    }
    return self;
}

- (void)execute
{
    if (self.queue) {
        dispatch_async(self.queue, self.block);
        
    } else {
        self.block();
    }
}

@end
