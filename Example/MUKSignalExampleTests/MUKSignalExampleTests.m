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
    XCTAssertEqual(receivedPayload, payload);
    
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
    XCTAssertEqual(receivedPayload, payload);
    
    receivedPayload = nil;
    [signal suspend:token];
    [signal dispatch:payload];
    XCTAssertNil(receivedPayload);
    
    [signal resume:token];
    XCTAssertEqual(receivedPayload, payload);
    
    receivedPayload = nil;
    [signal suspend:token];
    [signal dispatch:payload];
    [signal cancelDeferredDispatch:token];
    [signal resume:token];
    XCTAssertNil(receivedPayload);
    
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
    XCTAssertEqual(signal.name, name);
    XCTAssertNil(signal.object);
    
    __block NSNotification *receivedNotification = nil;
    id const token = [signal subscribe:^(NSNotification * _Nonnull notification) {
        receivedNotification = notification;
    }];
    
    XCTAssertNil(receivedNotification);
    NSDictionary *const userInfo = @{ @"info" : [NSDate date] };
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
    XCTAssertEqual(receivedNotification.name, name);
    XCTAssertEqual(receivedNotification.userInfo, userInfo);
    
    receivedNotification = nil;
    [signal unsubscribe:token];
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
    XCTAssertNil(receivedNotification);
}

@end
