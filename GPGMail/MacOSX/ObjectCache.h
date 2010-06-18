#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

// Replaced by NSCache

#elif defined(SNOW_LEOPARD)

// Replaced by NSCache

#elif defined(LEOPARD)

@interface ObjectCache : NSObject
{
    unsigned int _arrayCapacity;
    struct __CFArray *_keysAndValues;
    BOOL _useIsEqual;
}

- (id)initWithCapacity:(unsigned int)fp8;
- (void)dealloc;
- (void)finalize;
- (void)setCapacity:(unsigned int)fp8;
- (void)setUsesIsEqualForComparison:(BOOL)fp8;
- (void)setObject:(id)fp8 forKey:(id)fp12;
- (id)objectForKey:(id)fp8;
- (void)removeObjectForKey:(id)fp8;
- (void)removeAllObjects;
- (BOOL)isObjectInCache:(id)fp8;
- (id)description;

@end

#elif defined(TIGER)

@interface ObjectCache : NSObject
{
    unsigned int _arrayCapacity;
    struct __CFArray *_keysAndValues;
    BOOL _useIsEqual;
}

- (id)initWithCapacity:(unsigned int)fp8;
- (void)dealloc;
- (void)finalize;
- (void)setCapacity:(unsigned int)fp8;
- (void)setUsesIsEqualForComparison:(BOOL)fp8;
- (void)setObject:(id)fp8 forKey:(id)fp12;
- (id)objectForKey:(id)fp8;
- (void)removeObjectForKey:(id)fp8;
- (void)removeAllObjects;
- (BOOL)isObjectInCache:(id)fp8;

@end

#else

@interface ObjectCache:NSObject
{
    unsigned int _arrayCapacity;	// 4 = 0x4
    struct __CFArray *_keysAndValues;	// 8 = 0x8
    char _useIsEqual;	// 12 = 0xc
}

- initWithCapacity:(unsigned int)fp8;
- (void)dealloc;
- (void)setCapacity:(unsigned int)fp8;
- (void)setUsesIsEqualForComparison:(char)fp8;
- (void)setObject:fp8 forKey:fp12;
- objectForKey:fp8;
- (void)removeObjectForKey:fp8;
- (void)removeAllObjects;
- (char)isObjectInCache:fp8;

@end

#endif
