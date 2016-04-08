#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A signal which can be observed with a suspendable subscription.
 When a subscriber is suspended, dispatching a signal does not invoke a
 subscriber. When subscriber is resumed it receives the last dispatched payload.
 */
@interface MUKSignal (Suspending)
/**
 Suspend a subscriber
 @param token Subscription token
 */
- (void)suspend:(id)token;
/**
 Resume a subscriber
 @param token A suspended subscriber token
 */
- (void)resume:(id)token;
/**
 Cancel deferred dispatch
 @param token A suspended subscriber token
 */
- (void)cancelDeferredDispatch:(id)token;
@end

NS_ASSUME_NONNULL_END

