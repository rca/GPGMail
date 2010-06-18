#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@interface SafeObserver : NSObject
{
    unsigned long long _retainCount;
    BOOL _inDealloc;
}

+ (void)initialize;
+ (void)lockSafeObservers;
+ (void)unlockSafeObservers;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)retain;
- (id)willDealloc;
- (void)release;
- (unsigned long long)retainCount;

@end

#elif defined(SNOW_LEOPARD)

@interface SafeObserver : NSObject
{
    unsigned int _retainCount;
    BOOL _inDealloc;
}

+ (void)initialize;
+ (void)lockSafeObservers;
+ (void)unlockSafeObservers;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)retain;
- (id)willDealloc;
- (void)release;
- (unsigned int)retainCount;

@end

#elif defined(LEOPARD)

@interface SafeObserver : NSObject
{
    unsigned int _retainCount;
    BOOL _inDealloc;
}

+ (void)initialize;
+ (void)lockSafeObservers;
+ (void)unlockSafeObservers;
- (id)init;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (id)retain;
- (id)willDealloc;
- (void)release;
- (unsigned int)retainCount;

@end

#elif defined(TIGER)

@interface SafeObserver : NSObject
{
    unsigned int _retainCount;
}

+ (void)initialize;
+ (id)allocWithZone:(struct _NSZone *)fp8;
+ (void)lockSafeObservers;
+ (void)unlockSafeObservers;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (id)retain;
- (id)willBeReleased;
- (void)release;
- (unsigned int)retainCount;

@end

#endif
