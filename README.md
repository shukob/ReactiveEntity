[![Stories in Ready](https://badge.waffle.io/limbate/reactiveentity.png?label=ready)](https://waffle.io/limbate/reactiveentity)
Reactive Entity
============

Reactive Entity is Memory-based Reactive ValueObject Library.  

Example:

```  objective-c

#import "ReactiveEntity.h"

@interface User : REReactiveEntity

@property NSNumber *ID;
@property NSString *name;
@property NSNumber *age;
@property NSString *profileImageURL;

@property REAssociatedCollection *articles;

@end

#pragma mark -

@interface Article : REReactiveEntity

@property NSNumber *ID;
@property NSString *title;
@property NSString *content;
@property User     *author;

@property REAssociatedCollection *tags;

@end

#pragma mark -

@interface Tag : REReactiveEntity

@property NSNumber *ID;
@property NSString *name;

@property REAssociatedCollection *articles;

@end

```

``` objective-c

@implementation User

@dynamic ID, name, age, profileImageURL, articles;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
    
    [translator addRuleForSourceKey:@"profile_image_url"
                      translatedKey:@"profileImageURL"];
}

+ (void)associationMapper:(REAssociationMapper *)mapper
{
    [mapper registerAssociatedEntityCollectionForKey:@"articles"
                                         entityClass:[Article class]
                                          foreignKey:@"author"];
}

+ (NSString *)identifierKey
{
    return @"ID";
}

@end

#pragma mark -

@implementation Article

@dynamic ID, title, content, author, tags;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
}

+ (void)associationMapper:(REAssociationMapper *)mapper
{
    [mapper registerAssociatedEntityForKey:@"author"
                               entityClass:[User class]];
    
    [mapper registerAssociatedEntityCollectionForKey:@"tags"
                                         entityClass:[Tag class]
                                          foreignKey:@"articles"];
}

@end

#pragma mark -

@implementation Tag

@dynamic ID, name, articles;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
    [translator addRuleForSourceKey:@"id"
                      translatedKey:@"ID"];
}

+ (void)associationMapper:(REAssociationMapper *)mapper
{
    [mapper registerAssociatedEntityCollectionForKey:@"articles"
                                         entityClass:[Article class]
                                          foreignKey:@"tags"];
}

@end

```

``` objective-c

#import <XCTest/XCTest.h>
#import "ReactiveEntity.h"
#import "User.h"
#import "Article.h"

@interface ReactiveEntityTests : XCTestCase

@end

@implementation ReactiveEntityTests

- (void)setUp
{
    [super setUp];
    
    [[REContext defaultContext] clearAllEntitiesRecursive];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testContext
{
    XCTAssertEqual([User context], [User context]); // 同じエンティティのコンテクストが何回取得しても同じである
}

- (void)testAssign
{
    User *user = [User entityWithIdentifier:@(1)];
    user.name = @"Jake";
    
    XCTAssertEqualObjects(user.name, @"Jake"); // エンティティにデータが正しくアサインできる
}

- (void)testDependence
{
    __block NSString *name = @"John";
    
    __weak User *user = [User entityWithIdentifier:@(2)];
    user.name = name;
    
    [user addDependenceFromSource:self block:^(id source) {
        name = user.name;
    }];
    
    user.name = @"Jeremy";
    
    XCTAssertEqualObjects(name, @"Jeremy"); // エンティティが更新されたとき、データフローが実行される
    
    User *user2 = [User entityWithIdentifier:@(2)];
    user2.name = @"Jack";
    
    XCTAssertEqualObjects(name, @"Jack"); // コンテクストから取得したエンティティを更新した場合も正しくデータフローが実行される
}

- (void)testImport
{
    User *user = [User importFromDictionary:@{
                                              @"id": @(100),
                                              @"name": @"Joseph",
                                              @"age":  @(36),
                                              @"profile_image_url": @"http://0.0.0.0/nyan.png",
                                              }];
    
    XCTAssertEqualObjects(user.name, @"Joseph"); // 正しくインポートできている
    XCTAssertEqualObjects(user.age,  @(36)); // 正しくインポートできている
    
    XCTAssertEqualObjects(user.profileImageURL, @"http://0.0.0.0/nyan.png"); // キー変換が正しく行われた上でインポートできている
}

- (void)testImportList
{
    NSArray *users = [User importFromListOfDictionary:@[@{
                                                            @"id": @(1),
                                                            @"name": @"Jane",
                                                            @"age":  @(38),
                                                            @"profile_image_url": @"http://0.0.0.0/jane.png",
                                                            },
                                                        @{
                                                            @"id": @(2),
                                                            @"name": @"Judas",
                                                            @"age":  @(24),
                                                            @"profile_image_url": @"http://0.0.0.0/judas.png",
                                                            }]];
    
    XCTAssertEqualObjects([users[0] ID],   @(1)); // 正しくインポートできている
    XCTAssertEqualObjects([users[0] name], @"Jane"); // 正しくインポートできている
    XCTAssertEqualObjects([users[0] age],  @(38)); // 正しくインポートできている
    
    XCTAssertEqualObjects([users[1] ID],   @(2)); // 正しくインポートできている
    XCTAssertEqualObjects([users[1] name], @"Judas"); // 正しくインポートできている
    XCTAssertEqualObjects([users[1] age],  @(24)); // 正しくインポートできている
}

- (void)testImportWithAssociation
{
    Article *article = [Article importFromDictionary:@{
                                                       @"id": @(1),
                                                       @"title": @"今日のご飯はなんですか？",
                                                       @"content": @"そろそろ鍋にしたい",
                                                       @"author": @{
                                                               @"id": @(1),
                                                               @"name": @"Jane",
                                                               @"age":  @(38),
                                                               @"profile_image_url": @"http://0.0.0.0/jane.png",
                                                               },
                                                       }];
    
    XCTAssertEqualObjects(article.author.name,   @"Jane"); // 辞書型をインポートした際に関連する単数のエンティティクラスが自動的に生成・保存される
}

- (void)testDependenceLifetime
{
    User *user = [User entityWithIdentifier:@(3)];
    user.name = @"Jacob";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    
    @autoreleasepool {
        NSObject *object = [[NSObject alloc] init];
        
        [user addDependenceFromSource:object block:^(NSObject *source) {
            NSLog(@"%@", source);
            counter++;
        }];
        
        XCTAssertEqual(counter, (NSInteger)1);
        
        user.age = @(11);
        
        XCTAssertEqual(counter, (NSInteger)2);
    }
    
    user.age = @(12);
    
    XCTAssertEqual(counter, (NSInteger)2); // source が解放され、ブロックが呼ばれなくなる
}

- (void)testUnlinkDependence
{
    User *user = [User entityWithIdentifier:@(3)];
    user.name = @"Julia";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    NSObject *object = [[NSObject alloc] init];
    
    @autoreleasepool {
        REDependence *dependence = [user addDependenceFromSource:object block:^(id source) {
            counter++;
        }];
        
        XCTAssertEqual(counter, (NSInteger)1);
        
        user.age = @(11);
        
        XCTAssertEqual(counter, (NSInteger)2);
        
        [dependence unlink];
    }
    
    user.age = @(12);
    
    XCTAssertEqual(counter, (NSInteger)2); // データフローを破棄したとき、ブロックが呼ばれなくなる
}

- (void)testUnlinkDependenceWithName
{
    User *user = [User entityWithIdentifier:@(4)];
    user.name = @"Jet";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    NSObject *object = [[NSObject alloc] init];
    
    [user addDependenceFromSource:object name:__FUNCTION__ block:^(NSObject *source) {
        counter++;
    }];
    
    XCTAssertEqual(counter, (NSInteger)1);
    
    user.age = @(11);
    
    XCTAssertEqual(counter, (NSInteger)2);
    
    [user addDependenceFromSource:object name:__FUNCTION__ block:^(NSObject *source) {
        counter--;
    }];
    
    XCTAssertEqual(counter, (NSInteger)1);
    
    user.age = @(12);
    
    XCTAssertEqual(counter, (NSInteger)0); // 同名のデータフローを設定したとき、古いデータフローが破棄される
}

- (void)testReactiveCollection
{
    User *userA = [User entityWithIdentifier:@(5)];
    userA.name = @"Alice";
    userA.age  = @(18);
    
    User *userB = [User entityWithIdentifier:@(6)];
    userB.name = @"Bob";
    userB.age  = @(24);
    
    User *userC = [User entityWithIdentifier:@(7)];
    userC.name = @"Carol";
    userC.age  = @(12);
    
    REReactiveCollection *allUsers = [[REReactiveCollection alloc] initWithEntityClass:[User class] condition:nil];
    XCTAssertEqual(allUsers.setRepresentation.count, (NSUInteger)3); // 当該エンティティの全てのオブジェクトを持ったコレクションを作成できる
    
    REReactiveCollection *minorUsers = [[REReactiveCollection alloc] initWithEntityClass:[User class] condition:^BOOL(User *entity) {
        return entity.age.integerValue < 20;
    }];
    XCTAssertEqual(minorUsers.setRepresentation.count, (NSUInteger)2); // 条件を使ってコレクションを作成できる
    
    userC.age = @(22);
    
    __block BOOL waiting = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        waiting = NO;
    });
    
    while (waiting) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    XCTAssertEqual(minorUsers.setRepresentation.count, (NSUInteger)1); // 条件を使って作成したコレクションがエンティティの状態変化によって自動的に更新される
}

- (void)testReactiveCollectionSortedArray
{
    User *userA = [User entityWithIdentifier:@(5)];
    userA.name = @"Alice";
    userA.age  = @(18);
    
    User *userB = [User entityWithIdentifier:@(6)];
    userB.name = @"Bob";
    userB.age  = @(24);
    
    User *userC = [User entityWithIdentifier:@(7)];
    userC.name = @"Carol";
    userC.age  = @(12);
    
    REReactiveCollection *allUsers = [[REReactiveCollection alloc] initWithEntityClass:[User class] condition:nil];
    NSArray *ageSortedUsersAscending  = [allUsers sortedArrayWithKeyPath:@"age" ascending:YES];
    NSArray *ageSortedUsersDescending = [allUsers sortedArrayWithKeyPath:@"age" ascending:NO];
    
    {
        NSArray *correct = @[userC, userA, userB];
        XCTAssertEqualObjects(correct, ageSortedUsersAscending); // 指定された keyPath の結果で昇順にソートされた配列が取得できる
    }
    
    {
        NSArray *correct = @[userB, userA, userC];
        XCTAssertEqualObjects(correct, ageSortedUsersDescending); // 指定された keyPath の結果で降順にソートされた配列が取得できる
    }
}

- (void)testAssociatedReactiveCollectionOneToOne
{
    User *user = [User entityWithIdentifier:@(1)];
    
    Article *article1 = [Article entityWithIdentifier:@(1)];
    Article *article2 = [Article entityWithIdentifier:@(2)];
    Article *article3 = [Article entityWithIdentifier:@(3)];
    
    [user.articles addEntity:article1];
    [user.articles addEntity:article2];
    [user.articles addEntity:article3];
    
    {
        NSSet *correct = [NSSet setWithObjects:article1, article2, article3, nil];
        XCTAssertEqualObjects(user.articles.setRepresentation, correct); // 一対多の関連が正しく取得できる
    }
}

- (void)testDependencyOnAssociatedReactiveCollectionOneToOne
{
    User *user = [User entityWithIdentifier:@(1)];
    
    Article *article1 = [Article entityWithIdentifier:@(1)];
    Article *article2 = [Article entityWithIdentifier:@(2)];
    Article *article3 = [Article entityWithIdentifier:@(3)];
    
    __block NSInteger counter = 0;
    
    [user.articles addDependenceFromSource:self block:^(id source) {
        counter++;
    }];
    
    XCTAssertEqual(counter, (NSInteger)1);
    
    [user.articles addEntity:article1];
    
    XCTAssertEqual(counter, (NSInteger)2); // 直接のエンティティ追加によって一対多関連のアソシエーションが変動したときに依存元に push が送られる
    
    [user.articles addEntity:article2];
    
    XCTAssertEqual(counter, (NSInteger)3); // 直接のエンティティ追加によって一対多関連のアソシエーションが変動したときに依存元に push が送られる
    
    [user.articles addEntity:article3];
    
    XCTAssertEqual(counter, (NSInteger)4); // 直接のエンティティ追加によって一対多関連のアソシエーションが変動したときに依存元に push が送られる
}

- (void)testAssociatedReactiveCollectionManyToMany
{
    Article *article1 = [Article entityWithIdentifier:@(1)];
    Article *article2 = [Article entityWithIdentifier:@(2)];
    Article *article3 = [Article entityWithIdentifier:@(3)];
    
    Tag *tag1 = [Tag entityWithIdentifier:@(1)];
    Tag *tag2 = [Tag entityWithIdentifier:@(2)];
    Tag *tag3 = [Tag entityWithIdentifier:@(3)];
    
    [article1.tags addEntity:tag1];
    [article1.tags addEntity:tag2];
    
    [article2.tags addEntity:tag2];
    [article2.tags addEntity:tag3];
    
    [article3.tags addEntity:tag3];
    [article3.tags addEntity:tag1];
    
    {
        NSSet *correct = [NSSet setWithObjects:tag1, tag2, nil];
        XCTAssertEqualObjects(article1.tags.setRepresentation, correct); // 多対多の関連が正しく取得できる
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:tag2, tag3, nil];
        XCTAssertEqualObjects(article2.tags.setRepresentation, correct); // 多対多の関連が正しく取得できる
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:tag3, tag1, nil];
        XCTAssertEqualObjects(article3.tags.setRepresentation, correct); // 多対多の関連が正しく取得できる
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:article1, article3, nil];
        XCTAssertEqualObjects(tag1.articles.setRepresentation, correct); // 多対多の関連が正しく取得できる
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:article1, article2, nil];
        XCTAssertEqualObjects(tag2.articles.setRepresentation, correct); // 多対多の関連が正しく取得できる
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:article2, article3, nil];
        XCTAssertEqualObjects(tag3.articles.setRepresentation, correct); // 多対多の関連が正しく取得できる
    }
}

- (void)testDependencyOnAssociatedReactiveCollectionManyToMany
{
    Article *article1 = [Article entityWithIdentifier:@(1)];
    
    Tag *tag1 = [Tag entityWithIdentifier:@(1)];
    Tag *tag2 = [Tag entityWithIdentifier:@(2)];
    Tag *tag3 = [Tag entityWithIdentifier:@(3)];
    
    __block NSInteger counter = 0;
    
    [article1.tags addDependenceFromSource:self block:^(id source) {
        counter++;
    }];
    
    XCTAssertEqual(counter, (NSInteger)1);
    
    [article1.tags addEntity:tag1];
    
    XCTAssertEqual(counter, (NSInteger)2); // 直接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られる
    
    [article1.tags addEntity:tag2];
    
    XCTAssertEqual(counter, (NSInteger)3); // 直接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られる
    
    [article1.tags addEntity:tag3];
    
    XCTAssertEqual(counter, (NSInteger)4); // 直接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られる
}

- (void)testDependencyOnAssociatedReactiveCollectionManyToManyIndirectly
{
    Article *article1 = [Article entityWithIdentifier:@(1)];
    
    Tag *tag1 = [Tag entityWithIdentifier:@(1)];
    Tag *tag2 = [Tag entityWithIdentifier:@(2)];
    Tag *tag3 = [Tag entityWithIdentifier:@(3)];
    
    __block NSInteger counter = 0;
    
    [article1.tags addDependenceFromSource:self block:^(id source) {
        counter++;
    }];
    
    XCTAssertEqual(counter, (NSInteger)1);
    
    [tag1.articles addEntity:article1];
    
    XCTAssertEqual(counter, (NSInteger)2); // 間接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られる
    
    [tag2.articles addEntity:article1];
    
    XCTAssertEqual(counter, (NSInteger)3); // 間接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られる
    
    [tag3.articles addEntity:article1];
    
    XCTAssertEqual(counter, (NSInteger)4); // 間接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られる
}

@end

```

## Getting Started

``` Podfile
pod 'ReactiveEntity', git: 'https://github.com/Limbate/ReactiveEntity.git'
```

## License

ReactiveEntity is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](LICENSE) file for full details.

## Credits

ReactiveEntity is written by [うーねこ](http://twitter.com/ne_ko_o).
