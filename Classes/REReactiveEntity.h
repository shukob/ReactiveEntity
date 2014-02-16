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
#import "REDependence.h"
#import "REReactiveObject.h"

@class REAssociationMapper;

@interface REReactiveEntity : REReactiveObject

- (instancetype)initWithIdentifier:(id <NSCopying>)identifier;
+ (instancetype)entityWithIdentifier:(id <NSCopying>)identifier;
+ (instancetype)entityWithUnspecificIdentifier;
+ (NSString *)entityName;
+ (NSSet *)allEntities;

+ (NSString *)identifierKey;
+ (BOOL)hasIdentifierProperty;

- (instancetype)copiedEntityWithNewIdentifier:(id <NSCopying>)identifier;

- (id <NSCopying>)identifier;

- (void)setValue:(id)value forKey:(NSString *)key push:(BOOL)push;

+ (REContext *)context;
+ (REEntityModel *)entityModel;

- (instancetype)isolatedEntity;
@property (readonly, getter = isIsolated) BOOL isolated;

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