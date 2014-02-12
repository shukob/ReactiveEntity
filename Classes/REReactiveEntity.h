/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REContext.h"
#import "REEntityModel.h"
#import "REKeyTranslator.h"
#import "REAssociationMapper.h"
#import "REReactiveDataFlow.h"

@interface REReactiveEntity : NSObject

- (instancetype)initWithIdentifier:(id <NSCopying>)identifier;
+ (instancetype)entityWithIdentifier:(id <NSCopying>)identifier;
+ (NSString *)entityName;

- (id <NSCopying>)identifier;

- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner block:(void(^)(id owner))block;
- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner queue:(dispatch_queue_t)queue block:(void(^)(id owner))block;
- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner name:(const void *)name block:(void(^)(id owner))block;
- (REReactiveDataFlow *)reactiveDataFlowWithOwner:(id)owner name:(const void *)name queue:(dispatch_queue_t)queue block:(void(^)(id owner))block;
- (void)push;

- (void)setValue:(id)value forKey:(NSString *)key push:(BOOL)push;

+ (REContext *)context;
+ (REEntityModel *)entityModel;

+ (NSString *)identifierKey;

@end

@interface REReactiveEntity (MassAssignment)

+ (instancetype)importFromDictionary:(NSDictionary *)dictionary;
- (void)assignAttributesFromDictionary:(NSDictionary *)attributes;
+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator;

+ (NSArray *)importFromListOfDictionary:(NSArray *)listOfDictionary;

@end

@interface REReactiveEntity (Association)

+ (void)associationMapper:(REAssociationMapper *)mapper;

@end

@interface NSObject (ReactiveEntity)

- (NSArray *)reactiveDataFlows;
- (REReactiveDataFlow *)reactiveDataFlowWithName:(NSString *)name;

@end