#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// A simple signal with T-typed payload
@interface MUKSignal<__covariant T> : NSObject
@end

@interface MUKSignal<__covariant T> (Subscribing)
/// The subscriber is a block with accepts a T-typed payload
typedef void (^MUKSignalSubscriber)(T payload);
/**
 Subscribe to a signal
 @param subscriber The handler which will be invoked
 @returns A token which could be used to unsubscribe from signal
 */
- (id)subscribe:(MUKSignalSubscriber)subscriber;
/**
 Unsubscribe from a signal
 @param token The token acquired when subscribed
 */
- (void)unsubscribe:(id)token;
@end

@interface MUKSignal<__covariant T> (Dispatching)
/**
 Dispatch a signal
 @param payload A T-typed payload
 */
- (void)dispatch:(nullable T)payload;
@end

NS_ASSUME_NONNULL_END
