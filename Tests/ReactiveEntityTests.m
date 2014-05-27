//
//  ReactiveEntityTests.m
//  ReactiveEntityTests
//
//  Created by irony on 2013/11/20.
//  Copyright (c) 2013年 Limbate Inc. All rights reserved.
//

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
    XCTAssertEqual([User context], [User context], @"同じエンティティのコンテクストが何回取得しても同じであること");
}

- (void)testAssign
{
    User *user = [User entityWithIdentifier:@(1)];
    user.name = @"Jake";
    
    XCTAssertEqualObjects(user.name, @"Jake", @"エンティティにデータが正しくアサインできること");
}

- (void)testUnspecificIdentifier
{
    User *user1 = [User isolatedEntity];
    User *user2 = [User isolatedEntity];
    User *user3 = [User isolatedEntity];
    
    XCTAssertNotEqual(user1, user2, @"孤立エンティティを取得したとき、毎回新しいものが作られること");
    XCTAssertNotEqual(user2, user3, @"孤立エンティティを取得したとき、毎回新しいものが作られること");
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
    
    XCTAssertEqualObjects(name, @"Jeremy", @"エンティティが更新されたとき、データフローが実行されること");
    
    User *user2 = [User entityWithIdentifier:@(2)];
    user2.name = @"Jack";
    
    XCTAssertEqualObjects(name, @"Jack", @"コンテクストから取得したエンティティを更新した場合も正しくデータフローが実行されること");
}

- (void)testValueTransform
{
    Image *image = [Image importFromDictionary:@{
                                                 @"content_type":  @"image/jpeg",
                                                 @"original_url":  @"http://0.0.0.0/wan.jpg",
                                                 @"thumbnail_url": @"http://0.0.0.0/wan_t.jpg",
                                                 }];
    
    XCTAssertEqualObjects(image.originalURL, [NSURL URLWithString:@"http://0.0.0.0/wan.jpg"], @"import 時、valueTransformer により変換された値が設定されていること");
    
    image.originalURL = (id)@"http://0.0.0.0/nyan.jpg";
    
    XCTAssertEqualObjects(image.originalURL, [NSURL URLWithString:@"http://0.0.0.0/nyan.jpg"], @"set 時、valueTransformer により変換された値が設定されていること");
}

- (void)testImport
{
    User *user = [User importFromDictionary:@{
                                              @"id": @(100),
                                              @"name": @"Joseph",
                                              @"age":  @(36),
                                              @"profile_image": @{
                                                      @"content_type":  @"image/jpeg",
                                                      @"original_url":  @"http://0.0.0.0/wan.jpg",
                                                      @"thumbnail_url": @"http://0.0.0.0/wan_t.jpg",
                                                      },
                                              }];
    
    XCTAssertEqualObjects(user.name, @"Joseph", @"正しくインポートできていること");
    XCTAssertEqualObjects(user.age,  @(36),     @"正しくインポートできていること");
    
    XCTAssertEqualObjects(user.ID, @(100), @"キー変換が正しく行われた上でインポートできていること");
    
    XCTAssertEqualObjects(user.profileImage.contentType, @"image/jpeg", @"IDを持たないサブエンティティが正しくインポートできていること");
    
    User  *beforeUser  = user;
    Image *beforeImage = user.profileImage;
    
    user = [User importFromDictionary:@{
                                        @"id": @(100),
                                        @"profile_image": @{
                                                @"content_type": @"image/jpeg",
                                                @"original_url":  @"http://0.0.0.0/wan.jpg",
                                                @"thumbnail_url": @"http://0.0.0.0/wan_t.jpg",
                                                },
                                        }];
    
    XCTAssertEqual(beforeUser, user, @"インポートを繰り返してもエンティティのアドレスが同一であること");
    XCTAssertEqual(beforeImage, user.profileImage, @"インポートを繰り返してもIDを持たないサブエンティティが同一であること");
}

- (void)testIdentifier
{
    XCTAssertTrue([User hasIdentifierProperty],   @"identifier property を持っている場合");
    XCTAssertFalse([Image hasIdentifierProperty], @"identifier property を持っていない場合");
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
    
    XCTAssertEqualObjects([users[0] ID],   @(1),    @"正しくインポートできていること");
    XCTAssertEqualObjects([users[0] name], @"Jane", @"正しくインポートできていること");
    XCTAssertEqualObjects([users[0] age],  @(38),   @"正しくインポートできていること");
    
    XCTAssertEqualObjects([users[1] ID],   @(2),     @"正しくインポートできていること");
    XCTAssertEqualObjects([users[1] name], @"Judas", @"正しくインポートできていること");
    XCTAssertEqualObjects([users[1] age],  @(24),    @"正しくインポートできていること");
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
    
    XCTAssertEqualObjects(article.author.name, @"Jane", @"辞書型をインポートした際に関連する単数のエンティティクラスが自動的に生成・保存されること");
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
    
    XCTAssertEqual(counter, (NSInteger)2, @"source が解放され、ブロックが呼ばれなくなること");
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
    
    XCTAssertEqual(counter, (NSInteger)2, @"データフローを破棄したとき、ブロックが呼ばれなくなること");
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
    
    XCTAssertEqual(counter, (NSInteger)0, @"同名のデータフローを設定したとき、古いデータフローが破棄されること");
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
    XCTAssertEqual(allUsers.setRepresentation.count, (NSUInteger)3, @"当該エンティティの全てのオブジェクトを持ったコレクションを作成できること");
    
    REReactiveCollection *minorUsers = [[REReactiveCollection alloc] initWithEntityClass:[User class] condition:^BOOL(User *entity) {
        return entity.age.integerValue < 20;
    }];
    XCTAssertEqual(minorUsers.setRepresentation.count, (NSUInteger)2, @"条件を使ってコレクションを作成できること");
    
    userC.age = @(22);
    
    __block BOOL waiting = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        waiting = NO;
    });
    
    while (waiting) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    XCTAssertEqual(minorUsers.setRepresentation.count, (NSUInteger)1, @"条件を使って作成したコレクションがエンティティの状態変化によって自動的に更新されること");
}

- (void)testDeleteEntity
{
    User *userA = [User entityWithIdentifier:@(1)];
    User *userB = [User entityWithIdentifier:@(2)];
    
    XCTAssertEqual([User allEntities].count, 2);
    
    [userA deleteEntity];
    
    XCTAssertEqual([User allEntities].count, 1);
    
    [userB deleteEntity];
    
    XCTAssertEqual([User allEntities].count, 0);
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
        XCTAssertEqualObjects(correct, ageSortedUsersAscending, @"指定された keyPath の結果で昇順にソートされた配列が取得できること");
    }
    
    {
        NSArray *correct = @[userB, userA, userC];
        XCTAssertEqualObjects(correct, ageSortedUsersDescending, @"指定された keyPath の結果で降順にソートされた配列が取得できること");
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
        XCTAssertEqualObjects(user.articles.setRepresentation, correct, @"一対多の関連が正しく取得できること");
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
    
    XCTAssertEqual(counter, (NSInteger)2, @"直接のエンティティ追加によって一対多関連のアソシエーションが変動したときに依存元に push が送られること");
    
    [user.articles addEntity:article2];
    
    XCTAssertEqual(counter, (NSInteger)3, @"直接のエンティティ追加によって一対多関連のアソシエーションが変動したときに依存元に push が送られること");
    
    [user.articles addEntity:article3];
    
    XCTAssertEqual(counter, (NSInteger)4, @"直接のエンティティ追加によって一対多関連のアソシエーションが変動したときに依存元に push が送られること");
}

- (void)testDependencyOnAssociatedReactiveCollectionDeletion
{
    User *user = [User entityWithIdentifier:@(1)];
    
    Article *article1 = [Article entityWithIdentifier:@(1)];
    Article *article2 = [Article entityWithIdentifier:@(2)];
    Article *article3 = [Article entityWithIdentifier:@(3)];
    
    __block NSInteger numberOfArticles = 0;
    
    __weak User *weakUser = user;
    [user.articles addDependenceFromSource:self block:^(id source) {
        numberOfArticles = weakUser.articles.setRepresentation.count;
    }];
    
    XCTAssertEqual(numberOfArticles, (NSInteger)0);
    
    [user.articles addEntity:article1];
    
    XCTAssertEqual(numberOfArticles, (NSInteger)1);
    
    [user.articles addEntity:article2];
    
    XCTAssertEqual(numberOfArticles, (NSInteger)2);
    
    [user.articles addEntity:article3];
    
    XCTAssertEqual(numberOfArticles, (NSInteger)3);

    // pending
#if 0
        [article1 deleteEntity];
        
        XCTAssertEqual(numberOfArticles, (NSInteger)2);
        
        [article2 deleteEntity];
        
        XCTAssertEqual(numberOfArticles, (NSInteger)1);
        
        [article3 deleteEntity];
        
        XCTAssertEqual(numberOfArticles, (NSInteger)0);
#endif
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
        XCTAssertEqualObjects(article1.tags.setRepresentation, correct, @"多対多の関連が正しく取得できること");
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:tag2, tag3, nil];
        XCTAssertEqualObjects(article2.tags.setRepresentation, correct, @"多対多の関連が正しく取得できること");
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:tag3, tag1, nil];
        XCTAssertEqualObjects(article3.tags.setRepresentation, correct, @"多対多の関連が正しく取得できること");
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:article1, article3, nil];
        XCTAssertEqualObjects(tag1.articles.setRepresentation, correct, @"多対多の関連が正しく取得できること");
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:article1, article2, nil];
        XCTAssertEqualObjects(tag2.articles.setRepresentation, correct, @"多対多の関連が正しく取得できること");
    }
    
    {
        NSSet *correct = [NSSet setWithObjects:article2, article3, nil];
        XCTAssertEqualObjects(tag3.articles.setRepresentation, correct, @"多対多の関連が正しく取得できること");
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
    
    XCTAssertEqual(counter, (NSInteger)2, @"直接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られること");
    
    [article1.tags addEntity:tag2];
    
    XCTAssertEqual(counter, (NSInteger)3, @"直接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られること");
    
    [article1.tags addEntity:tag3];
    
    XCTAssertEqual(counter, (NSInteger)4, @"直接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られること");
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
    
    XCTAssertEqual(counter, (NSInteger)2, @"間接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られること");
    
    [tag2.articles addEntity:article1];
    
    XCTAssertEqual(counter, (NSInteger)3, @"間接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られること");
    
    [tag3.articles addEntity:article1];
    
    XCTAssertEqual(counter, (NSInteger)4, @"間接のエンティティ追加によって多対多関連のアソシエーションが変動したときに依存元に push が送られること");
}

@end