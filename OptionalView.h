#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD

@interface OptionalView : NSView
{
    NSButton *_optionSwitch;
    NSView *_primaryView;
    struct CGRect _originalFrame;
    BOOL _isResizing;
}

- (id)initWithFrame:(struct CGRect)arg1;
- (void)dealloc;
- (void)awakeFromNib;
- (void)didAddSubview:(id)arg1;
- (void)willRemoveSubview:(id)arg1;
- (void)subviewFrameDidChange:(id)arg1;
- (id)primaryView;
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (void)drawRect:(struct CGRect)arg1;
- (id)optionSwitch;
- (void)sizeToFit;
- (float)minXIncludingOptionSwitch:(BOOL)arg1;
- (float)minXOffsetIncludingOptionSwitch:(BOOL)arg1;

@end

#elif defined(LEOPARD)

@interface OptionalView : NSView
{
    NSButton *_optionSwitch;
    NSView *_primaryView;
    struct _NSRect _originalFrame;
    BOOL _isResizing;
    BOOL _isCustomizing;
}

- (id)initWithFrame:(struct _NSRect)fp8;
- (void)dealloc;
- (void)awakeFromNib;
- (void)didAddSubview:(id)fp8;
- (void)willRemoveSubview:(id)fp8;
- (void)subviewFrameDidChange:(id)fp8;
- (id)primaryView;
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (void)drawRect:(struct _NSRect)fp8;
- (id)optionSwitch;
- (void)sizeToFit;
- (float)minXIncludingOptionSwitch:(BOOL)fp8;
- (float)minXOffsetIncludingOptionSwitch:(BOOL)fp8;

@end

#elif defined(TIGER)

@interface OptionalView : NSView
{
    NSButton *_optionSwitch;
    NSView *_primaryView;
    struct _NSRect _originalFrame;
    BOOL _isResizing;
    BOOL _isCustomizing;
}

- (id)initWithFrame:(struct _NSRect)fp8;
- (void)dealloc;
- (void)awakeFromNib;
- (void)didAddSubview:(id)fp8;
- (void)willRemoveSubview:(id)fp8;
- (void)subviewFrameDidChange:(id)fp8;
- (id)primaryView;
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (void)drawRect:(struct _NSRect)fp8;
- (id)optionSwitch;
- (void)sizeToFit;
- (float)minXIncludingOptionSwitch:(BOOL)fp8;
- (float)minXOffsetIncludingOptionSwitch:(BOOL)fp8;

@end

#endif
