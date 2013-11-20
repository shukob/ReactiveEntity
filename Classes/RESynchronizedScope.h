/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@interface RESynchronizedScope : NSObject

- (id)initWithBlock:(void(^)(void))block queue:(dispatch_queue_t)queue;
- (void)execute;

@end