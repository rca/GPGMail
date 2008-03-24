#import <Cocoa/Cocoa.h>

#ifdef LEOPARD

@interface SegmentedToolbarItem : NSToolbarItemGroup
{
}

- (id)initWithItemIdentifier:(id)fp8;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (void)configureForDisplayMode:(unsigned int)fp8 andSizeMode:(unsigned int)fp12;
- (void)validate;
- (id)control;
- (void)controlAction:(id)fp8;
- (void)setSegmentCount:(int)fp8;
- (id)methodSignatureForSelector:(SEL)fp8;
- (void)forwardInvocation:(id)fp8;
- (id)labelForSegment:(int)fp8;
- (void)setLabel:(id)fp8 forSegment:(int)fp12;
- (void)setAlternateLabel:(id)fp8 forSegment:(int)fp12;
- (id)paletteLabelForSegment:(int)fp8;
- (void)setPaletteLabel:(id)fp8 forSegment:(int)fp12;
- (SEL)actionForSegment:(int)fp8;
- (void)setAction:(SEL)fp8 forSegment:(int)fp12;
- (id)targetForSegment:(int)fp8;
- (void)setTarget:(id)fp8 forSegment:(int)fp12;
- (void)setTag:(int)fp8 forSegment:(int)fp12;
- (void)setToolTip:(id)fp8 forSegment:(int)fp12;
- (void)setMenu:(id)fp8 forSegment:(int)fp12;

@end

@interface SegmentedToolbarItemSegmentItem : NSToolbarItem
{
    SegmentedToolbarItem *parent;
    int segmentNumber;
}

- (id)menuFormRepresentation;
- (void)setToolTip:(id)fp8;
- (void)_setToolTip:(id)fp8;
- (void)setTag:(int)fp8;
- (void)_setTag:(int)fp8;
- (void)setImage:(id)fp8;
- (int)segmentNumber;
- (void)setSegmentNumber:(int)fp8;
- (id)parent;
- (void)setParent:(id)fp8;

@end

#elif defined(TIGER)

@interface MailToolbarItem : NSToolbarItem
{
    NSArray *_segments;
    unsigned int _extraSegmentWidth;
    unsigned int _extraHorizontalPadding;
    unsigned int _borderless:1;
}

- (id)initWithItemIdentifier:(id)fp8;
- (id)initWithItemIdentifier:(id)fp8 segments:(id)fp12 bordered:(BOOL)fp16 toolbar:(id)fp20;
- (void)dealloc;
- (id)segments;
- (unsigned int)segmentCount;
- (id)segmentAtIndex:(int)fp8;
- (id)itemView;
- (void)setLabel:(id)fp8 forSegment:(int)fp12;
- (id)labelForSegment:(int)fp8;
- (void)setPaletteLabel:(id)fp8 forSegment:(int)fp12;
- (id)paletteLabelForSegment:(int)fp8;
- (void)setToolTip:(id)fp8 forSegment:(int)fp12;
- (id)toolTipForSegment:(int)fp8;
- (void)setTag:(int)fp8 forSegment:(int)fp12;
- (int)tagForSegment:(int)fp8;
- (void)setTarget:(id)fp8 forSegment:(int)fp12;
- (id)targetForSegment:(int)fp8;
- (void)setAction:(SEL)fp8 forSegment:(int)fp12;
- (SEL)actionForSegment:(int)fp8;
- (void)setEnabled:(BOOL)fp8 forSegment:(int)fp12;
- (BOOL)isEnabledForSegment:(int)fp8;
- (void)setImage:(id)fp8 forSegment:(int)fp12;
- (id)imageForSegment:(int)fp8;
- (void)setInactiveImage:(id)fp8 forSegment:(int)fp12;
- (id)inactiveImageForSegment:(int)fp8;
- (void)setPressedImage:(id)fp8 forSegment:(int)fp12;
- (id)pressedImageForSegment:(int)fp8;
- (BOOL)bordered;
- (void)setExtraSegmentWidth:(unsigned int)fp8;
- (unsigned int)extraSegmentWidth;
- (void)setExtraHorizontalPadding:(unsigned int)fp8;
- (unsigned int)extraHorizontalPadding;
- (void)performActionForSegment:(int)fp8;
- (void)_validateSegment:(int)fp8 forToolbarItem:(id)fp12;
- (void)setEnabled:(BOOL)fp8;
- (void)configureForDisplayMode:(int)fp8 andSizeMode:(int)fp12;
- (id)menuFormRepresentation;
- (void)_validateAsCustomItem:(id)fp8;
- (id)_copyOfCustomView;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (BOOL)usesMenuFormRepresentationInDisplayMode:(int)fp8;
- (BOOL)wantsToDrawIconIntoLabelAreaInDisplayMode:(int)fp8;
- (BOOL)wantsToDrawIconInDisplayMode:(int)fp8;
- (BOOL)wantsToDrawLabelInDisplayMode:(int)fp8;
- (BOOL)wantsToDrawLabelInPalette;

@end

@interface MailToolbarItemSegment : NSObject <NSCopying>
{
    NSImage *_image;
    NSImage *_inactiveImage;
    NSImage *_pressedImage;
    NSString *_label;
    NSString *_paletteLabel;
    NSString *_altLabel;
    NSString *_toolTip;
    int _tag;
    id _target;
    SEL _action;
}

- (id)initWithImage:(id)fp8 label:(id)fp12 paletteLabel:(id)fp16 altLabel:(id)fp20 tooltip:(id)fp24 tag:(int)fp28 target:(id)fp32 action:(SEL)fp36;
- (id)copyWithZone:(struct _NSZone *)fp8;
- (void)dealloc;
- (id)image;
- (void)setImage:(id)fp8;
- (void)setInactiveImage:(id)fp8;
- (id)inactiveImage;
- (void)setPressedImage:(id)fp8;
- (id)pressedImage;
- (id)label;
- (BOOL)setLabel:(id)fp8;
- (BOOL)hasCustomPaletteLabel;
- (id)paletteLabel;
- (id)altLabel;
- (void)setPaletteLabel:(id)fp8;
- (id)toolTip;
- (void)setToolTip:(id)fp8;
- (int)tag;
- (void)setTag:(int)fp8;
- (id)target;
- (void)setTarget:(id)fp8;
- (SEL)action;
- (void)setAction:(SEL)fp8;
- (id)menuFormRepresentation;

@end

#endif
