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

@interface REAbstractEntity : NSObject

- (instancetype)initWithIdentifier:(id <NSCopying>)identifier;
+ (instancetype)entityWithIdentifier:(id <NSCopying>)identifier;
+ (NSString *)entityName;

- (id <NSCopying>)identifier;

- (void)synchronizedScopeWithOwner:(id)owner block:(void(^)(void))block;
- (void)synchronizedScopeWithOwner:(id)owner queue:(dispatch_queue_t)queue block:(void(^)(void))block;
- (void)synchronize;

- (void)setValue:(id)value forKey:(NSString *)key synchronize:(BOOL)synchronize;

+ (REContext *)context;
+ (REEntityModel *)entityModel;

@end

@interface REAbstractEntity (MassAssignment)

+ (instancetype)importFromDictionary:(NSDictionary *)attributes identifier:(id<NSCopying>)identifier;
- (void)assignAttributesFromDictionary:(NSDictionary *)attributes;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator;

@end