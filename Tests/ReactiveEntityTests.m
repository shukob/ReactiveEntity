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

- (void)testDataFlow
{
    __block NSString *name = @"John";
    
    User *user = [User entityWithIdentifier:@(2)];
    user.name = name;
    
    [user reactiveDataFlowWithOwner:self block:^(id owner) {
        name = user.name;
    }];
    
    user.name = @"Jeremy";
    
    XCTAssertEqualObjects(name, @"Jeremy", @"エンティティが更新されたとき、データフローが実行されること");
    
    User *user2 = [User entityWithIdentifier:@(2)];
    user2.name = @"Jack";
    
    XCTAssertEqualObjects(name, @"Jack", @"コンテクストから取得したエンティティを更新した場合も正しくデータフローが実行されること");
}

- (void)testImport
{
    User *user = [User importFromDictionary:@{
                                              @"id": @(100),
                                              @"name": @"Joseph",
                                              @"age":  @(36),
                                              @"profile_image_url": @"http://0.0.0.0/nyan.png",
                                              }];
    
    XCTAssertEqualObjects(user.name, @"Joseph", @"正しくインポートできていること");
    XCTAssertEqualObjects(user.age,  @(36),     @"正しくインポートできていること");
    
    XCTAssertEqualObjects(user.profileImageURL, @"http://0.0.0.0/nyan.png", @"キー変換が正しく行われた上でインポートできていること");
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
                                                       @"tags": @[
                                                               @{
                                                                   @"id": @(1),
                                                                   @"name": @"日記",
                                                                   },
                                                               @{
                                                                   @"id": @(2),
                                                                   @"name": @"雑事",
                                                                   },
                                                               ],
                                                       }];
    
    XCTAssertEqualObjects(article.author.name,   @"Jane", @"辞書型をインポートした際に関連する単数のエンティティクラスが自動的に生成・保存されること");
    XCTAssertEqualObjects([article.tags[0] name], @"日記", @"辞書型をインポートした際に関連する複数のエンティティクラスが自動的に生成・保存されること");
}

- (void)testDataFlowLifetime
{
    User *user = [User entityWithIdentifier:@(3)];
    user.name = @"Jacob";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    
    @autoreleasepool {
        NSObject *object = [[NSObject alloc] init];
        
        [user reactiveDataFlowWithOwner:object block:^(NSObject *owner) {
            NSLog(@"%@", owner);
            counter++;
        }];
        
        XCTAssertEqual(counter, (NSInteger)1);
        
        user.age = @(11);
        
        XCTAssertEqual(counter, (NSInteger)2);
    }
    
    user.age = @(12);
    
    XCTAssertEqual(counter, (NSInteger)2, @"owner が解放され、ブロックが呼ばれなくなること");
}

- (void)testUnlinkDataFlow
{
    User *user = [User entityWithIdentifier:@(3)];
    user.name = @"Julia";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    NSObject *object = [[NSObject alloc] init];
    
    @autoreleasepool {
        REReactiveDataFlow *dataFlow = [user reactiveDataFlowWithOwner:object block:^(id owner) {
            counter++;
        }];
        
        XCTAssertEqual(counter, (NSInteger)1);
        
        user.age = @(11);
        
        XCTAssertEqual(counter, (NSInteger)2);
        
        [dataFlow unlink];
    }
    
    user.age = @(12);
    
    XCTAssertEqual(counter, (NSInteger)2, @"データフローを破棄したとき、ブロックが呼ばれなくなること");
}

- (void)testUnlinkDataFlowWithName
{
    User *user = [User entityWithIdentifier:@(4)];
    user.name = @"Jet";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    NSObject *object = [[NSObject alloc] init];
    
    [user reactiveDataFlowWithOwner:object name:__FUNCTION__ block:^(NSObject *owner) {
        counter++;
    }];
    
    XCTAssertEqual(counter, (NSInteger)1);
    
    user.age = @(11);
    
    XCTAssertEqual(counter, (NSInteger)2);
    
    [user reactiveDataFlowWithOwner:object name:__FUNCTION__ block:^(NSObject *owner) {
        counter--;
    }];
    
    XCTAssertEqual(counter, (NSInteger)1);
    
    user.age = @(12);
    
    XCTAssertEqual(counter, (NSInteger)0, @"同名のデータフローを設定したとき、古いデータフローが破棄されること");
}

@end