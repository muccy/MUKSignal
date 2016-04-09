#import "MUKKVOSignal.h"
#import "MUKSignal+Dispatching.h"
#import "MUKSignal+Subscribing.h"
#import "MUKSignal+Suspending.h"

@implementation MUKKVOSignalChange

- (instancetype)initWithValue:(id)value oldValue:(id)oldValue {
    self = [super init];
    if (self) {
        _oldValue = oldValue;
        _value = value;
    }
    
    return self;
}

- (instancetype)init {
    return [self initWithValue:nil oldValue:nil];
}

@end

#pragma mark -

static void *KVOContext = &KVOContext;

@implementation MUKKVOSignal

- (void)dealloc {
    [self.object removeObserver:self forKeyPath:self.keyPath context:KVOContext];
}

- (instancetype)initWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath
{
    self = [super init];
    if (self) {
        _object = object;
        _keyPath = [keyPath copy];
        
        [object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:KVOContext];
    }
    
    return self;
}

#pragma mark - Overrides

- (instancetype)init {
    NSAssert(NO, @"Use designated initializer");
    return [self initWithObject:[NSObject new] keyPath:@""];
}

- (id)subscribe:(void (^)(MUKKVOSignalChange<id> * _Nonnull))subscriber {
    return [super subscribe:subscriber];
}

- (id)mergedDispatchPayload:(nullable MUKKVOSignalChange *)payload withSuspendedPayload:(nullable MUKKVOSignalChange *)suspendedPayload
{
    if (!payload || !suspendedPayload) {
        return [super mergedDispatchPayload:payload withSuspendedPayload:suspendedPayload];
    }
    
    // Incremental through suspension
    return [[MUKKVOSignalChange alloc] initWithValue:payload.value oldValue:suspendedPayload.oldValue];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)changeDict context:(void *)context
{
    if (context != KVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:changeDict context:context];
        return;
    }
    
    id const oldValue = ({
        id const value = changeDict[NSKeyValueChangeOldKey];
        [value isKindOfClass:[NSNull class]] ? nil : value;
    });
    
    id const newValue = ({
        id const value = changeDict[NSKeyValueChangeNewKey];
        [value isKindOfClass:[NSNull class]] ? nil : value;
    });

    MUKKVOSignalChange *const change = [[MUKKVOSignalChange alloc] initWithValue:newValue oldValue:oldValue];
    [self dispatch:change];
}

@end
