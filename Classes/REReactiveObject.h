/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REDependence.h"

@interface REReactiveObject : NSObject

- (REDependence *)addDependenceFromSource:(id)source block:(void(^)(id source))block;
- (REDependence *)addDependenceFromSource:(id)source queue:(dispatch_queue_t)queue block:(void(^)(id source))block;
- (REDependence *)addDependenceFromSource:(id)source name:(const void *)name block:(void(^)(id source))block;
- (REDependence *)addDependenceFromSource:(id)source name:(const void *)name queue:(dispatch_queue_t)queue block:(void(^)(id source))block;

- (void)removeDependenceFromSource:(id)source;
- (void)removeDependenceFromSource:(id)source name:(const void *)name;

- (void)push;

@end