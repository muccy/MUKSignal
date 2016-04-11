//
//  MUKSignalExampleTests.m
//  MUKSignalExampleTests
//
//  Created by Marco on 08/04/16.
//  Copyright © 2016 MeLive. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MUKSignal/MUKSignal.h>

@interface MUKSignalExampleTests : XCTestCase
@property (nonatomic, copy) NSString *string;
@end

@implementation MUKSignalExampleTests

- (void)testSubscribing {
    MUKSignal *const signal = [[MUKSignal alloc] init];
    id const token = [signal subscribe:^(id  _Nonnull payload) {}];
    XCTAssertNotNil(token);
}

- (void)testUnsubscribing {
    MUKSignal *const signal = [[MUKSignal alloc] init];
    id const token = [signal subscribe:^(id  _Nonnull payload) {}];
    XCTAssertNoThrow([signal unsubscribe:token]);
    XCTAssertNoThrow([signal unsubscribe:token]); // Also twice
}

- (void)testDispatching {
    MUKSignal *const signal = [[MUKSignal alloc] init];
    
    id const payload = @"!";
    XCTAssertNoThrow([signal dispatch:payload]);
    
    __block id receivedPayload = nil;
    id const token = [signal subscribe:^(id  _Nonnull payload) {
        receivedPayload = payload;
    }];
    
    XCTAssertNil(receivedPayload);
    [signal dispatch:payload];
    XCTAssertEqualObjects(receivedPayload, payload);
    
    [signal unsubscribe:token];
    receivedPayload = nil;
    [signal dispatch:payload];
    XCTAssertNil(receivedPayload);
}

- (void)testSuspending {
    MUKSignal *const signal = [[MUKSignal alloc] init];

    id const payload = @"!";
    XCTAssertNoThrow([signal dispatch:payload]);
    
    __block id receivedPayload = nil;
    id const token = [signal subscribe:^(id  _Nonnull payload) {
        receivedPayload = payload;
    }];
    
    XCTAssertNil(receivedPayload);
    [signal dispatch:payload];
    XCTAssertEqualObjects(receivedPayload, payload);
    
    receivedPayload = nil;
    [signal suspend:token];
    [signal dispatch:payload];
    XCTAssertNil(receivedPayload);
    XCTAssertEqualObjects([signal suspendedDispatchPayload:token], payload);
    
    [signal resume:token];
    XCTAssertEqualObjects(receivedPayload, payload);
    
    receivedPayload = nil;
    [signal suspend:token];
    [signal dispatch:payload];
    [signal unsubscribe:token];
    XCTAssertNoThrow([signal resume:token]);
    XCTAssertNil(receivedPayload);
}

- (void)testNotification {
    NSString *const name = @"Notification";
    MUKNotificationSignal *const signal = [[MUKNotificationSignal alloc] initWithName:name object:nil];
    XCTAssertEqualObjects(signal.name, name);
    XCTAssertNil(signal.object);
    
    __block NSNotification *receivedNotification = nil;
    id const token = [signal subscribe:^(NSNotification * _Nonnull notification) {
        receivedNotification = notification;
    }];
    
    XCTAssertNil(receivedNotification);
    NSDictionary *const userInfo = @{ @"info" : [NSDate date] };
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
    XCTAssertEqualObjects(receivedNotification.name, name);
    XCTAssertEqualObjects(receivedNotification.userInfo, userInfo);
    
    receivedNotification = nil;
    [signal unsubscribe:token];
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
    XCTAssertNil(receivedNotification);
    
    XCTAssertThrows([signal dispatch:@"An object"]);
}

- (void)testKVO {
    MUKKVOSignal<NSString *> *const signal = [[MUKKVOSignal alloc] initWithObject:self keyPath:NSStringFromSelector(@selector(string))];
    
    __block MUKKVOSignalChange<NSString *> *receivedChange = nil;
    id const token = [signal subscribe:^(MUKKVOSignalChange<NSString *> * _Nonnull change) {
        receivedChange = change;
    }];
    
    XCTAssertNil(receivedChange);
    self.string = @"A";
    XCTAssertEqualObjects(receivedChange.value, @"A");
    XCTAssertNil(receivedChange.oldValue);
    
    self.string = nil;
    XCTAssertNil(receivedChange.value);
    XCTAssertEqualObjects(receivedChange.oldValue, @"A");
    
    MUKKVOSignalChange<NSString *> *const changeSnapshot = receivedChange;
    [signal suspend:token];
    self.string = @"A";
    XCTAssertEqual(receivedChange, changeSnapshot);
    self.string = @"B";
    XCTAssertEqual(receivedChange, changeSnapshot);
    
    [signal resume:token];
    XCTAssertEqualObjects(receivedChange.value, @"B");
    XCTAssertNil(receivedChange.oldValue);
    
    [signal unsubscribe:token];
    self.string = @"C";
    XCTAssertEqualObjects(receivedChange.value, @"B");
    
    XCTAssertThrows([signal dispatch:@"An object"]);
}

@end
