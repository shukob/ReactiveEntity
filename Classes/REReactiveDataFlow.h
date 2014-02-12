/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@interface REReactiveDataFlow : NSObject

- (id)initWithOwner:(id)owner name:(NSString *)name queue:(dispatch_queue_t)queue block:(void(^)(id owner))block;
- (void)push;
- (void)unlink;

- (NSString *)name;
- (dispatch_queue_t)queue;
- (void(^)(id owner))block;

@end