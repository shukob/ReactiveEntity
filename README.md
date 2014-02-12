Reactive Entity
============

Reactive Entity is Memory-based Reactive ValueObject Library.  

Example:

```  objective-c

#import "ReactiveEntity.h"

@interface User : REReactiveEntity
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, strong) NSString *profileImageURL;
@end

```

``` objective-c

@implementation User

@dynamic name, age, profileImageURL;

+ (void)keyTranslatorForMassAssignment:(REKeyTranslator *)translator
{
      [translator addRuleForSourceKey:@"profile_image_url"
                        translatedKey:@"profileImageURL"];
}

@end

```

``` objective-c

@interface ReactiveEntityTests : XCTestCase
@end

@implementation ReactiveEntityTests

- (void)testAssign
{
    User *user = [User entityWithIdentifier:@(1)];
    user.name = @"Jake";
    
    XCTAssertEqualObjects(user.name, @"Jake");
}

- (void)testDataFlow
{
    __block NSString *name = @"John";
    
    User *user = [User entityWithIdentifier:@(2)];
    user.name = name;
    
    // setup `DataFlow` and call the block at once 
    [user reactiveDataFlowWithOwner:self block:^(id owner) {
        name = user.name;
    }];
    
    user.name = @"Jeremy";
    
    XCTAssertEqualObjects(name, @"Jeremy");
    
    User *user2 = [User entityWithIdentifier:@(2)];
    user2.name = @"Jack";
    
    // -[REReactiveDataFlow push] is called automatically in -[User setName:].
    //
    // user2
    //  \_ -[NSObject reactiveDataFlows] (NSArray)
    //     \_ * REReactiveDataFlow --[push]--> `name` (local variable)
    //        * REReactiveDataFlow --[push]--> ...
    //        * REReactiveDataFlow --[push]--> ...
    //        ...
    //
    
    XCTAssertEqualObjects(name, @"Jack"); // Modified
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

    // DataFlow lifetime are same as owner
    
    user.age = @(12);
    
    XCTAssertEqual(counter, 2); // This is not typo.
}

- (void)testImport
{
    User *user = [User importFromDictionary:@{
                                              @"name": @"Joseph",
                                              @"age":  @(36),
                                              @"profile_image_url": @"http://0.0.0.0/nyan.png",
                                              }
                                 identifier:@(3)];
    
    XCTAssertEqualObjects(user.name, @"Joseph");
    XCTAssertEqualObjects(user.age,  @(36));
    
    // Mass-assignment Key Translate
    XCTAssertEqualObjects(user.profileImageURL);
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
