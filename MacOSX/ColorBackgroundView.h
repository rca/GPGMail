#import <Cocoa/Cocoa.h>

@interface ColorBackgroundView : NSView
{
    int _tag;
    NSColor *_color;
    NSImage *_image;
    NSArray *_colors;
    BOOL _isFlipped;
    float _rowHeight;
    float _rowOffset;
}

- (void)dealloc;
- (BOOL)isOpaque;
- (id)backgroundColor;
- (id)backgroundColors;
- (void)setBackgroundColors:(id)arg1;
- (void)setBackgroundColor:(id)arg1;
- (void)drawRect:(struct CGRect)arg1;
- (id)colorForRow:(unsigned long)arg1;
- (id)backgroundImage;
- (void)setBackgroundImage:(id)arg1;
- (BOOL)isFlipped;
- (void)setFlipped:(BOOL)arg1;
- (float)rowOffset;
- (void)setRowOffset:(float)arg1;
- (float)rowHeight;
- (void)setRowHeight:(float)arg1;
- (long)tag;
- (void)setTag:(long)arg1;

@end