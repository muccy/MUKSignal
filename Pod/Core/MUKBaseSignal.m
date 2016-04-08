#import "MUKBaseSignal.h"

@interface MUKSignal ()
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, MUKSignalSubscriber> *subscriptions;
@end

@implementation MUKSignal
@synthesize subscriptions = _subscriptions;

#pragma mark - Accessors

- (NSMutableDictionary<NSUUID *,MUKSignalSubscriber> *)subscriptions {
    if (!_subscriptions) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    
    return _subscriptions;
}

#pragma mark - Subscribing

- (id)subscribe:(void (^)(id _Nonnull))subscriber {
    NSUUID *const token = [NSUUID UUID];
    self.subscriptions[token] = [subscriber copy];
    return token;
}

- (void)unsubscribe:(id)token {
    [_subscriptions removeObjectForKey:token];
}

#pragma mark - Dispatching

- (void)dispatch:(id)payload {
    [[_subscriptions copy] enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, MUKSignalSubscriber _Nonnull obj, BOOL * _Nonnull stop)
    {
        [self dispatchToSubscriber:obj withPayload:payload subscriptionToken:key];
    }];
}

- (void)dispatchToSubscriber:(MUKSignalSubscriber)subscriber withPayload:(id)payload subscriptionToken:(nonnull id)token
{
    subscriber(payload);
}

@end
