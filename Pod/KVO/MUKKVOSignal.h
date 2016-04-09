#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKKVOSignalChange<__covariant T> : NSObject
/// Value before change
@property (nonatomic, readonly, nullable) T oldValue;
/// Value after change
@property (nonatomic, readonly, nullable) T value;
@end

@interface MUKKVOSignal<__covariant T> : MUKSignal
/// Observed object
@property (nonatomic, readonly, weak) __kindof NSObject *object;
/// Observed key path
@property (nonatomic, readonly, copy) NSString *keyPath;

/// Designated initializer
- (instancetype)initWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath NS_DESIGNATED_INITIALIZER;

// Redefinition to use MUKKVOSignalChange autocompletion
- (id)subscribe:(void (^)(MUKKVOSignalChange<T> *change))subscriber;
@end

NS_ASSUME_NONNULL_END
