#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

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
- (double)minXIncludingOptionSwitch:(BOOL)arg1;
- (double)minXOffsetIncludingOptionSwitch:(BOOL)arg1;

@end

#elif defined(SNOW_LEOPARD)

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


#endif
