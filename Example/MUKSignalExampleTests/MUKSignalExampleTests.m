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
@property (nonatomic) id payload;
@end

@implementation MUKSignalExampleTests

- (void)testSubscribing {
    MUKSignal *const signal = [[MUKSignal alloc] init];
    id token = [signal subscribe:^(id  _Nonnull payload) {}];
    XCTAssertNotNil(token);
    
    token = [signal subscribeWithTarget:self action:@selector(setPayload:)];
    XCTAssertNotNil(token);
}

- (void)testUnsubscribing {
    MUKSignal *const signal = [[MUKSignal alloc] init];
    id token = [signal subscribe:^(id  _Nonnull payload) {}];
    XCTAssertNoThrow([signal unsubscribe:token]);
    XCTAssertNoThrow([signal unsubscribe:token]); // Also twice
    
    token = [signal subscribeWithTarget:self action:@selector(setPayload:)];
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
    
    id const anotherToken = [signal subscribeWithTarget:self action:@selector(setPayload:)];
    
    XCTAssertNil(receivedPayload);
    self.payload = nil;

    [signal dispatch:payload];
    XCTAssertEqualObjects(receivedPayload, payload);
    XCTAssertEqualObjects(self.payload, payload);
    
    [signal unsubscribe:token];
    [signal unsubscribe:anotherToken];
    
    receivedPayload = nil;
    self.payload = nil;
    
    [signal dispatch:payload];
    XCTAssertNil(receivedPayload);
    XCTAssertNil(self.payload);
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
    
    XCTAssertThrows([signal dispatch:(id)@"An object"]);
}

- (void)testCompound {    
    MUKSignal *const subsignal1 = [[MUKSignal alloc] init];
    MUKSignal *const subsignal2 = [[MUKSignal alloc] init];
    
    MUKCompoundSignal *const compoundSignal = [[MUKCompoundSignal alloc] initWithSubsignals:@[ subsignal1, subsignal2 ]];
    XCTAssertEqualObjects(compoundSignal.subsignals, (@[ subsignal1, subsignal2 ]));
    
    __block MUKCompoundSignalPayload *receivedPayload = nil;
    id const token = [compoundSignal subscribe:^(MUKCompoundSignalPayload * _Nullable payload)
    {
        receivedPayload = payload;
    }];
    
    XCTAssertNil(receivedPayload);
    [subsignal1 dispatch:@"Hi"];
    XCTAssertEqualObjects(receivedPayload.subsignal, subsignal1);
    XCTAssertEqualObjects(receivedPayload.subpayload, @"Hi");
    
    [subsignal2 dispatch:@"there"];
    XCTAssertEqualObjects(receivedPayload.subsignal, subsignal2);
    XCTAssertEqualObjects(receivedPayload.subpayload, @"there");
    
    receivedPayload = nil;
    [compoundSignal unsubscribe:token];
    [subsignal1 dispatch:@"!"];
    XCTAssertNil(receivedPayload);
    
    XCTAssertThrows([compoundSignal dispatch:(id)@"An object"]);
}

@end
