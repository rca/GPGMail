#import <Cocoa/Cocoa.h>

@interface ColorBackgroundView : NSView
{
    int _tag;
    NSColor *_color;
}

- (void)dealloc;
- (int)tag;
- (void)setTag:(int)fp8;
- (id)backgroundColor;
- (void)setBackgroundColor:(id)fp8;
- (void)drawRect:(struct _NSRect)fp8;
- (BOOL)isOpaque;

@end
