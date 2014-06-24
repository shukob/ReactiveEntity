/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REKeyTranslator.h"
#import "REValueTransformer.h"

@class REAssociationMapper;

@interface REEntityModel : NSObject

+ (instancetype)entityModelForEntityClass:(Class)klass;

- (void)addVariableWithKey:(NSString *)key;
- (BOOL)hasVariableForKey:(NSString *)key;
- (NSUInteger)variableIndexForKey:(NSString *)key;
- (NSUInteger)numberOfVariables;
- (NSArray *)variableKeys;

@property (nonatomic, strong) REKeyTranslator     *massAssignmentKeyTranslator;
@property (nonatomic, strong) REAssociationMapper *associationMapper;
@property (nonatomic, strong) REValueTransformer  *valueTransformer;

@end
