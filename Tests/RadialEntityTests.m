//
//  RadialEntityTests.m
//  RadialEntityTests
//
//  Created by irony on 2013/11/20.
//  Copyright (c) 2013年 Limbate Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RadialEntity.h"
#import "User.h"

@interface RadialEntityTests : XCTestCase

@end

@implementation RadialEntityTests

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

- (void)testSynchronize
{
    __block NSString *name = @"John";
    
    User *user = [User entityWithIdentifier:@(2)];
    user.name = name;
    
    [user synchronizedScopeWithOwner:self block:^(id owner) {
        name = user.name;
    }];
    
    user.name = @"Jeremy";
    
    XCTAssertEqualObjects(name, @"Jeremy", @"エンティティが更新されたとき、synchronized ブロックが実行されること");
    
    User *user2 = [User entityWithIdentifier:@(2)];
    user2.name = @"Jack";
    
    XCTAssertEqualObjects(name, @"Jack", @"コンテクストから取得したエンティティを更新した場合も正しく synchronized ブロックが実行されること");
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

- (void)testScopeLifetime
{
    User *user = [User entityWithIdentifier:@(2)];
    user.name = @"Jacob";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    
    @autoreleasepool {
        NSObject *object = [[NSObject alloc] init];
        
        [user synchronizedScopeWithOwner:object block:^(NSObject *owner) {
            NSLog(@"%@", owner);
            counter++;
        }];
        
        XCTAssertEqual(counter, 1);
        
        user.age = @(11);
        
        XCTAssertEqual(counter, 2);
    }
    
    user.age = @(12);
    
    XCTAssertEqual(counter, 2, @"owner が解放され、synchronized ブロックが呼ばれなくなること");
}

@end