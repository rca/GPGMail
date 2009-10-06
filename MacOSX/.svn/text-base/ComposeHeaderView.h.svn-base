#ifdef LEOPARD

#import <Cocoa/Cocoa.h>

@class OptionalView;

@interface ComposeHeaderView : NSView
{
    id _delegate;
    NSPopUpButton *_disclosureButton;
    NSMenu *_actionMenu;
    OptionalView *_toOptionalView;
    OptionalView *_ccOptionalView;
    OptionalView *_subjectOptionalView;
    OptionalView *_bccOptionalView;
    OptionalView *_replyToOptionalView;
    OptionalView *_accountOptionalView;
    OptionalView *_signatureOptionalView;
    OptionalView *_priorityOptionalView;
    OptionalView *_securityOptionalView;
    OptionalView *_deliveryOptionalView;
    NSView *_messageContentView;
    NSPopUpButton *_signaturePopUp;
    NSPopUpButton *_accountPopUp;
    NSPopUpButton *_deliveryPopUp;
    NSButton *_cancelButton;
    NSButton *_okButton;
    NSImage *borderImage;
    unsigned int _showCcView:1;
    unsigned int _showBccView:1;
    unsigned int _showReplyToView:1;
    unsigned int _showAccountView:1;
    unsigned int _showSignatureView:1;
    unsigned int _showPriorityView:1;
    unsigned int _showSecurityView:1;
    unsigned int _showDeliveryView:1;
    BOOL _tempShowDeliveryView;
    unsigned int _accountFieldEnabled:1;
    unsigned int _deliveryFieldEnabled:1;
    unsigned int _signatureFieldEnabled:1;
    unsigned int _securityFieldEnabled:1;
    unsigned int _resizingViews:1;
    unsigned int _customizing:1;
    unsigned int _changesCancelled:1;
    NSViewAnimation *_animation;
    float _nextShownFrameOrigin;
    float _nextHiddenFrameOrigin;
    float _heightDelta;
    id _lastFirstResponder;
    float _signaturePopUpMaxWidth;
    float _accountPopUpMaxWidth;
    OptionalView *_togglingOptionalView;
    BOOL _customizationShouldStick;
}

- (id)delegate;
- (void)setDelegate:(id)fp8;
- (id)messageContentView;
- (void)setMessageContentView:(id)fp8;
- (BOOL)isFlipped;
- (BOOL)isOpaque;
- (void)viewWillMoveToWindow:(id)fp8;
- (BOOL)isCustomizing;
- (void)dealloc;
- (void)_restoreFirstResponder;
- (void)_noteCurrentFirstResponder;
- (void)_popDisclosureButtonToFront;
- (void)_readVisibleStateFromOptionCheckboxes;
- (void)beginListeningForChildFrameChangeNotifications;
- (void)_setupMenuItemWithAction:(SEL)fp8 withState:(BOOL)fp12;
- (void)_setupActionMenuItemState;
- (void)awakeFromNib;
- (float)_positionView:(id)fp8 yOffset:(float)fp12;
- (BOOL)_shouldShowSecurityViewWhenNotCustomizing;
- (BOOL)_shouldShowSecurityViewWhenCustomizing;
- (BOOL)_shouldShowSecurityView;
- (BOOL)_shouldShowAccountViewWhenNotCustomizing;
- (BOOL)_shouldShowAccountViewWhenCustomizing;
- (BOOL)_shouldShowAccountView;
- (BOOL)_shouldShowSignatureViewWhenNotCustomizing;
- (BOOL)_shouldShowSignatureViewWhenCustomizing;
- (BOOL)_shouldShowSignatureView;
- (BOOL)_shouldShowDeliveryViewWhenNotCustomizing;
- (void)_deliveryViewAppearanceConditionsDidChange:(id)fp8;
- (void)_recomputeShowDeliveryView;
- (BOOL)_shouldShowDeliveryViewWhenCustomizing;
- (BOOL)_shouldShowDeliveryView;
- (BOOL)_shouldShowPriorityViewWhenNotCustomizing;
- (BOOL)_shouldShowPriorityViewWhenCustomizing;
- (BOOL)_shouldShowPriorityView;
- (struct _NSRect)_calculatePriorityFrame:(struct _NSRect)fp8;
- (void)_calculateAccountFrame:(struct _NSRect *)fp8 deliveryFrame:(struct _NSRect *)fp12 signatureFrame:(struct _NSRect *)fp16;
- (void)subviewFrameDidChange:(id)fp8;
- (BOOL)isDisplayingBottomControls;
- (BOOL)isDisplayingFatBottomControls;
- (void)fixupTabRing;
- (void)tile;
- (void)_addView:(id)fp8 toList:(id)fp12 isVisible:(BOOL)fp16 adjustYOrigin:(BOOL)fp20;
- (void)_recordUserCustomization;
- (void)_customizeHeaders:(BOOL)fp8 duration:(float)fp12;
- (void)resizeWithOldSuperviewSize:(struct _NSSize)fp8;
- (void)_enableActionMenu:(BOOL)fp8;
- (void)sanityCheckHiddenessOfViewsInAnimationList:(id)fp8;
- (void)animationDidEnd:(id)fp8;
- (void)drawRect:(struct _NSRect)fp8;
- (void)_finishCustomizingSavingChanges:(BOOL)fp8;
- (void)done:(id)fp8;
- (void)_toggleCcOrBccOrReplyToField:(id)fp8;
- (void)toggleCcFieldVisibility:(id)fp8;
- (void)toggleBccFieldVisibility:(id)fp8;
- (void)toggleReplyToFieldVisibility:(id)fp8;
- (void)temporarilyToggleCcFieldVisibility;
- (void)temporarilyToggleBccFieldVisibility;
- (void)temporarilyToggleReplyToFieldVisibility;
- (void)_toggleAccountOrDeliveryOrSignatureOrPriorityOrSecurityField:(id)fp8;
- (void)togglePriorityFieldVisibility:(id)fp8;
- (void)temporarilyTogglePriorityFieldVisibility;
- (void)configureHeaders:(id)fp8;
- (void)configureAccountPopUpSize;
- (void)configureSignaturePopUpSize;
- (void)setCcFieldVisible:(BOOL)fp8 andSetDefault:(BOOL)fp12;
- (void)setCcFieldVisible:(BOOL)fp8;
- (void)setBccFieldVisible:(BOOL)fp8 andSetDefault:(BOOL)fp12;
- (void)setBccFieldVisible:(BOOL)fp8;
- (void)setReplyToFieldVisible:(BOOL)fp8 andSetDefault:(BOOL)fp12;
- (void)setReplyToFieldVisible:(BOOL)fp8;
- (void)setAccountFieldVisible:(BOOL)fp8;
- (void)setSignatureFieldVisible:(BOOL)fp8;
- (void)setDeliveryFieldVisible:(BOOL)fp8;
- (void)setPriorityFieldVisible:(BOOL)fp8 andSetDefault:(BOOL)fp12;
- (void)setPriorityFieldVisible:(BOOL)fp8;
- (void)setSecurityFieldVisible:(BOOL)fp8;
- (BOOL)securityFieldVisible;
- (BOOL)showCcHeader;
- (BOOL)showBccHeader;
- (BOOL)showReplyToHeader;
- (void)setAccountFieldEnabled:(BOOL)fp8;
- (void)setSignatureFieldEnabled:(BOOL)fp8;
- (void)setDeliveryFieldEnabled:(BOOL)fp8;
- (void)setSecurityFieldEnabled:(BOOL)fp8;

@end

#else
#error Missing definition of ComposeHeaderView
#endif
