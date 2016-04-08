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

@end
