#import "MUKSignal-Base.h"
#import "MUKSignal+Subscribing.h"
#import "MUKSignal+Dispatching.h"
#import "MUKSignal+Suspending.h"

@interface MUKSignal ()
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, MUKSignalSubscriber> *subscriptions;
@property (nonatomic, readonly, nonnull) NSMutableSet *suspendedTokens;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<id, dispatch_block_t> *deferredDispatches;
@end

@implementation MUKSignal
@synthesize subscriptions = _subscriptions;
@synthesize suspendedTokens = _suspendedTokens;
@synthesize deferredDispatches = _deferredDispatches;

#pragma mark - Accessors

- (NSMutableDictionary<NSUUID *,MUKSignalSubscriber> *)subscriptions {
    if (!_subscriptions) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    
    return _subscriptions;
}

- (NSMutableSet *)suspendedTokens {
    if (!_suspendedTokens) {
        _suspendedTokens = [NSMutableSet set];
    }
    
    return _suspendedTokens;
}

- (NSMutableDictionary<id,dispatch_block_t> *)deferredDispatches {
    if (!_deferredDispatches) {
        _deferredDispatches = [NSMutableDictionary dictionary];
    }
    
    return _deferredDispatches;
}

#pragma mark - Subscribing

- (id)subscribe:(void (^)(id _Nonnull))subscriber {
    NSUUID *const token = [NSUUID UUID];
    self.subscriptions[token] = [subscriber copy];
    return token;
}

- (void)unsubscribe:(id)token {
    [_subscriptions removeObjectForKey:token];
    [_deferredDispatches removeObjectForKey:token];
    [_suspendedTokens removeObject:token];
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
    if ([_suspendedTokens containsObject:token]) {
        __weak __typeof__(self) weakSelf = self;
        self.deferredDispatches[token] = [^{
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf dispatchToSubscriber:subscriber withPayload:payload subscriptionToken:token];
        } copy];
    }
    else {
        subscriber(payload);
    }
}

#pragma mark - Suspending

- (void)suspend:(id)token {
    [self.suspendedTokens addObject:token];
}

- (void)resume:(id)token {
    [_suspendedTokens removeObject:token];
    
    dispatch_block_t const deferredDispatch = _deferredDispatches[token];
    
    if (deferredDispatch) {
        deferredDispatch();
        [self cancelDeferredDispatch:token];
    }
}

- (void)cancelDeferredDispatch:(id)token {
    [_deferredDispatches removeObjectForKey:token];
}

@end
