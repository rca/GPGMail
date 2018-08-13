/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



#import "AccountInfoTabOwner-Protocol.h"
#import "NSDatePickerCellDelegate-Protocol.h"

@class ColorBackgroundView, EWSAccount, EditingWebMessageController, NSButton, NSDate, NSDatePicker, NSPopUpButton, NSProgressIndicator, NSView, WebView;

@interface OofPanelController : NSObject <AccountInfoTabOwner, NSDatePickerCellDelegate>
{
    NSView *_view;
    NSButton *_oofEnabledCheckbox;
    NSButton *_okButton;
    NSProgressIndicator *_getOofSettingsIndicator;
    NSPopUpButton *_scheduleMenu;
    NSDatePicker *_startTimePicker;
    NSDatePicker *_endTimePicker;
    ColorBackgroundView *_internalWebViewBackground;
    ColorBackgroundView *_externalWebViewBackground;
    WebView *_internalWebView;
    WebView *_externalWebView;
    EditingWebMessageController *_internalController;
    EditingWebMessageController *_externalController;
    EWSAccount *_account;
    NSDate *_startTime;
    NSDate *_endTime;
}

- (id)initWithAccount:(id)arg1;
- (id)init;
- (void)awakeFromNib;
- (void)dealloc;
- (void)toggleOofEnabled:(id)arg1;
- (void)scheduleMenuChanged:(id)arg1;
- (void)showOutOfOfficeSettings;
- (void)_handleOutOfOfficeSettings:(id)arg1;
- (void)_setEnabledForInterfaceElements:(BOOL)arg1;
- (void)_updateWebView:(id)arg1 content:(id)arg2;
- (void)accountInfoWillHideView:(id)arg1;
- (void)accountInfoWillShowView:(id)arg1;
- (id)view;
- (void)webView:(id)arg1 didFailLoadWithError:(id)arg2 forFrame:(id)arg3;
- (void)webView:(id)arg1 didFailProvisionalLoadWithError:(id)arg2 forFrame:(id)arg3;
- (void)datePickerCell:(id)arg1 validateProposedDateValue:(id *)arg2 timeInterval:(double *)arg3;
@property(retain) NSDate *endTime; // @synthesize endTime=_endTime;
@property(retain) NSDate *startTime; // @synthesize startTime=_startTime;
@property(retain) EWSAccount *account; // @synthesize account=_account;

@end

