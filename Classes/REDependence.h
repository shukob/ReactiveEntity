/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

@class REReactiveObject;

@interface REDependence : NSObject

+ (instancetype)addDependenceFromSource:(id)source destination:(REReactiveObject *)destination name:(NSString *)name queue:(dispatch_queue_t)queue block:(void(^)(id source))block;
+ (void)removeDependenceFromSource:(id)source destination:(REReactiveObject *)destination name:(NSString *)name;

- (void)push;
- (void)unlink;

- (NSString *)name;
- (dispatch_queue_t)queue;
- (void(^)(id destination))block;

@end

@interface NSObject (ReactiveDependence)

- (NSArray *)reactiveDependences;
- (REDependence *)reactiveDependenceWithName:(NSString *)name;

@end