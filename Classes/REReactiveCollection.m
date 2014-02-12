/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REReactiveCollection.h"

@interface REReactiveCollection ()
{
    BOOL _dirty;
    BOOL _needsPushOnNextRunLoop;
}

@property (nonatomic, assign) Class entityClass;
@property (nonatomic, copy)   BOOL(^condition)(id entity);
@property (nonatomic, strong) NSSet *setRepresentationCache;

@property (nonatomic, strong) NSMutableDictionary *sortedArrayCacheStore;

- (void)purify;
- (void)defile;

@end

@implementation REReactiveCollection

- (instancetype)initWithEntityClass:(Class)entityClass condition:(BOOL (^)(id))condition
{
    if (self = [super init]) {
        self.entityClass = entityClass;
        self.condition   = condition;
        self.sortedArrayCacheStore = [NSMutableDictionary dictionary];
        
        [self defile];
    }
    
    return self;
}

- (void)defile
{
    if (_dirty) return;
    
    _setRepresentationCache = nil;
    [self.sortedArrayCacheStore removeAllObjects];
    
    _dirty = YES;
}

- (void)purify
{
    if (_dirty == NO) return;
    
    if (self.condition == nil) {
        _setRepresentationCache = [self.entityClass allEntities];
        
    } else {
        _setRepresentationCache = [[self.entityClass allEntities] objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return self.condition(obj);
        }];
    }
    
    for (REDependence *dependence in self.reactiveDependences) {
        [dependence unlink];
    }
    
    for (REReactiveEntity *entity in _setRepresentationCache) {
        [entity addDependenceFromSource:self block:^(REReactiveCollection *source) {
            [source setNeedsPush];
        }];
    }
    
    _dirty = NO;
}

- (void)push
{
    [self defile];
    [super push];
}

- (void)setNeedsPush
{
    if (_needsPushOnNextRunLoop) return;
    
    _needsPushOnNextRunLoop = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self push];
        _needsPushOnNextRunLoop = NO;
    });
}

#pragma mark -

- (NSSet *)setRepresentation
{
    if (_setRepresentationCache) {
        return _setRepresentationCache;
    }
    
    [self purify];
    
    return _setRepresentationCache;
}

- (NSArray *)sortedArrayWithKeyPath:(NSString *)keyPath ascending:(BOOL)ascending
{
    if (self.sortedArrayCacheStore[keyPath] == nil) {
        self.sortedArrayCacheStore[keyPath] = [self.setRepresentation.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            id v1 = [obj1 valueForKeyPath:keyPath];
            id v2 = [obj2 valueForKeyPath:keyPath];
            return [v1 compare:v2];
        }];
    }
    
    if (ascending) {
        return self.sortedArrayCacheStore[keyPath];
    } else {
        return [self.sortedArrayCacheStore[keyPath] reverseObjectEnumerator].allObjects;
    }
}

@end