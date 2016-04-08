#import "MUKSuspendableSignal.h"

@interface MUKSuspendableSignal ()
@property (nonatomic, readonly, nonnull) NSMutableSet *suspendedTokens;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<id, dispatch_block_t> *deferredDispatches;
@end

@implementation MUKSuspendableSignal
@synthesize suspendedTokens = _suspendedTokens;
@synthesize deferredDispatches = _deferredDispatches;

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

#pragma mark - Accessors

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

#pragma mark - Overrides

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
        [super dispatchToSubscriber:subscriber withPayload:payload subscriptionToken:token];
    }
}

- (void)unsubscribe:(id)token {
    [super unsubscribe:token];
    [self cancelDeferredDispatch:token];
    [self resume:token];
}

@end
