#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD

@interface Subdata : NSData
{
    struct _NSRange subrange;
    NSData *parentData;
}

- (unsigned int)length;
- (const void *)bytes;
- (id)copyWithZone:(struct _NSZone *)arg1;
- (id)initWithParent:(id)arg1 range:(struct _NSRange)arg2;
- (void)dealloc;

@end

#elif defined(LEOPARD)

@interface Subdata : NSData
{
    struct _NSRange subrange;
    NSData *parentData;
}

- (unsigned int)length;
- (const void *)bytes;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (id)initWithParent:(id)fp8 range:(struct _NSRange)fp12;
- (void)dealloc;

@end

#else
#error Misses Subdata definition
#endif
