Radial Entity
============

Radial Entity is Memory-based ValueObject Library.  

Example:

```  objective-c

#import "RadialEntity.h"

@interface User : REAbstractEntity
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

@interface RadialEntityTests : XCTestCase
@end

@implementation RadialEntityTests

- (void)testAssign
{
    User *user = [User entityWithIdentifier:@(1)];
    user.name = @"Jake";
    
    XCTAssertEqualObjects(user.name, @"Jake");
}

- (void)testSynchronize
{
    __block NSString *name = @"John";
    
    User *user = [User entityWithIdentifier:@(2)];
    user.name = name;
    
    // setup `Synchronized Scope` and call the block at once 
    [user synchronizedScopeWithOwner:self block:^{
        name = user.name;
    }];
    
    user.name = @"Jeremy";
    
    XCTAssertEqualObjects(name, @"Jeremy");
    
    User *user2 = [User entityWithIdentifier:@(2)];
    user2.name = @"Jack"; // call Synchronized Scope automatically in setter
    
    XCTAssertEqualObjects(name, @"Jack"); // Modified
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

- (void)testScopeLifetime
{
    User *user = [User entityWithIdentifier:@(2)];
    user.name = @"Jacob";
    user.age  = @(10);
    
    __block NSInteger counter = 0;
    
    @autoreleasepool {
        NSObject *owner = [[NSObject alloc] init];
        
        [user synchronizedScopeWithOwner:owner block:^{
            counter++;
        }];
        
        XCTAssertEqual(counter, 1);
        
        user.age = @(11);
        
        XCTAssertEqual(counter, 2);
    }

    // Synchronized scope lifetime are same as owner
    
    user.age = @(12);
    
    XCTAssertEqual(counter, 2); // This is not typo.
}

@end

```

## Getting Started

``` Podfile
pod 'RadialEntity', git: 'https://github.com/Limbate/RadialEntity.git'
```

## License

RadialEntity is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](LICENSE) file for full details.

## Credits

RadialEntity is written by [うーねこ](http://twitter.com/ne_ko_o).
