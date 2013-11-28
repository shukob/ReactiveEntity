/*
 |=   _    _       _          _
 |=  | |  (_)_ __ | |__  __ _| |_ ___
 |=  | |__| | '  \| '_ \/ _` |  _/ -_)
 |=  |____|_|_|_|_|_.__/\__,_|\__\___|
 |=
 */

#import "REKeyTranslator.h"
#import "REAssociationMapper.h"

@interface REEntityModel : NSObject

+ (instancetype)entityModelForEntityClass:(Class)klass;

- (void)addVariableWithKey:(NSString *)key;
- (BOOL)hasVariableForKey:(NSString *)key;
- (NSUInteger)variableIndexForKey:(NSString *)key;
- (NSUInteger)numberOfVariables;

@property (nonatomic, strong) REKeyTranslator      *massAssignmentKeyTranslator;
@property (nonatomic, strong) REAssociationMapper *associationMapper;

@end
