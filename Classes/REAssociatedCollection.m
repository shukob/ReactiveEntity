/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REAssociatedCollection.h"
#import "ReactiveEntity.h"

@implementation REAssociatedCollection
{
    __weak REReactiveEntity *_owner;
    
    NSString *_referenceKey;
    NSString *_foreignKey;
}

- (id)initWithOwner:(REReactiveEntity *)owner referenceKey:(NSString *)referenceKey entityClass:(__unsafe_unretained Class)entityClass foreignKey:(NSString *)foreignKey
{
    __block REAssociatedCollection *collection = [super initWithEntityClass:entityClass condition:^BOOL(id entity) {
        
        id destination = [entity valueForKey:foreignKey];
        if (destination == owner) {
            return YES;
            
        } else if ([destination isKindOfClass:[REReactiveCollection class]]) {
            REContext *context = [REContext defaultContext];
            
            REReactiveCollectionAssociation *association = [context collectionAssociationWithCollection:collection
                                                                                           referenceKey:referenceKey
                                                                                        otherCollection:destination
                                                                                             foreignKey:foreignKey];
            if (association != nil) {
                return YES;
            }
        }
        
        return NO;
    }];
    
    self = collection;
    
    if (self) {
        _owner = owner;
        
        _referenceKey = referenceKey;
        _foreignKey   = foreignKey;
    }
    
    return self;
}

- (void)addEntity:(REReactiveEntity *)entity
{
    id source = [entity valueForKey:_foreignKey];
    
    if (source == nil) {
        [entity setValue:_owner forKey:_foreignKey];
        [self push];
        
    } else if ([source isKindOfClass:[REAssociatedCollection class]]) {
        REAssociatedCollection *otherCollection = source;
        [[REContext defaultContext] registerCollectionAssociationWithCollection:self
                                                                   referenceKey:_referenceKey
                                                                otherCollection:otherCollection
                                                                     foreignKey:_foreignKey];
        [self push];
        [otherCollection push];
    }
}

@end
