#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@interface ColorBackgroundView : NSView
{
	long long _tag;
	NSColor * _color;
	NSImage * _image;
	NSArray * _colors;
	BOOL _isFlipped;
	double _rowHeight;
	double _rowOffset;
}

- (void)dealloc;
- (BOOL)isOpaque;
@property (retain) NSColor * backgroundColor;
@property (retain) NSArray * backgroundColors;
- (void)drawRect:(struct CGRect)arg1;
- (id)colorForRow:(unsigned long long)arg1;
@property (retain) NSImage * backgroundImage; // @synthesize backgroundImage=_image;
@property (setter = setFlipped:) BOOL isFlipped; // @synthesize isFlipped=_isFlipped;
@property double rowOffset; // @synthesize rowOffset=_rowOffset;
@property double rowHeight; // @synthesize rowHeight=_rowHeight;
@property long long tag; // @synthesize tag=_tag;

@end

#elif defined(SNOW_LEOPARD)

@interface ColorBackgroundView : NSView
{
	int _tag;
	NSColor * _color;
	NSImage * _image;
	NSArray * _colors;
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


#endif // ifdef SNOW_LEOPARD_64
