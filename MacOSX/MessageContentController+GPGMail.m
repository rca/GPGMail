/*
 * Copyright (c) 2000-2008, Stéphane Corthésy <stephane at sente.ch>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Stéphane Corthésy nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY STÉPHANE CORTHÉSY AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL STÉPHANE CORTHÉSY AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MessageContentController+GPGMail.h"
#import "GPGMessageViewerAccessoryViewOwner.h"
#import "GPGMailBundle.h"
#import "GPGMailPatching.h"
#import "NSObject+GPGMail.h"
#import <MessageViewer+GPGMail.h>
#import <Message+GPGMail.h>
#import <MimePart+GPGMail.h>
#import <AppKit/AppKit.h>
#import "GPGMailPatching.h"
#import <MessageHeaderDisplay.h>
#import <MimeBody.h>
#import <MessageHeaders.h>


@interface MessageContentController(GPGMailPrivate)
- (BOOL) _gpgBannerIsShown;
@end


@implementation MessageContentController(GPGMail)

GPG_DECLARE_EXTRA_IVARS(MessageContentController)


// Posing no longer works correctly on 10.3, that's why we only overload single methods
static IMP MessageContentController__updateDisplay = NULL;
static IMP MessageContentController_validateMenuItem = NULL;
static IMP MessageContentController_setMessage_headerOrder = NULL;
static IMP MessageContentController__setMessage_headerOrder = NULL;
static IMP MessageContentController_fadeToEmpty = NULL;


+ (void) load
{
    [self gpgInitExtraIvars];
    MessageContentController__updateDisplay = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(_updateDisplay), [self class], @selector(gpg_updateDisplay), [self class]);
    MessageContentController_validateMenuItem = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(validateMenuItem:), [self class], @selector(gpgValidateMenuItem:), [self class]);
    MessageContentController_setMessage_headerOrder = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(setMessage:headerOrder:), [self class], @selector(gpgSetMessage:headerOrder:), [self class]);
    MessageContentController__setMessage_headerOrder = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(_setMessage:headerOrder:), [self class], @selector(gpg_setMessage:headerOrder:), [self class]);
    MessageContentController_fadeToEmpty = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(fadeToEmpty), [self class], @selector(gpgFadeToEmpty), [self class]);
}

- (BOOL) gpgMessageWasInFactSigned
{
    NSNumber	*aBoolValue = GPG_GET_EXTRA_IVAR(@"messageWasInFactSigned");
	
    return (aBoolValue != nil ? [aBoolValue boolValue]:NO);
}

- (void) gpgSetMessageWasInFactSigned:(BOOL)flag
{
    GPG_SET_EXTRA_IVAR([NSNumber numberWithBool:flag], @"messageWasInFactSigned");
}

- (BOOL) gpgMessageHasBeenDecrypted
{
    NSNumber	*aBoolValue = GPG_GET_EXTRA_IVAR(@"messageHasBeenDecrypted");
	
    return (aBoolValue != nil ? [aBoolValue boolValue]:NO);
}

- (void) gpgSetMessageHasBeenDecrypted:(BOOL)flag
{
    GPG_SET_EXTRA_IVAR([NSNumber numberWithBool:flag], @"messageHasBeenDecrypted");
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s %@", __PRETTY_FUNCTION__, flag ? @"YES":@"NO");
}

- (BOOL) gpgMessageReadStatusHasChanged
{
    NSNumber	*aBoolValue = GPG_GET_EXTRA_IVAR(@"messageReadStatusHasChanged");
	
    return (aBoolValue != nil ? [aBoolValue boolValue]:NO);
}

- (void) gpgSetMessageReadStatusHasChanged:(BOOL)flag
{
    GPG_SET_EXTRA_IVAR([NSNumber numberWithBool:flag], @"messageReadStatusHasChanged");
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s %@", __PRETTY_FUNCTION__, flag ? @"YES":@"NO");
}

- (BOOL) gpgDoNotResetFlags
{
    NSNumber	*aBoolValue = GPG_GET_EXTRA_IVAR(@"doNotResetFlags");
	
    return (aBoolValue != nil ? [aBoolValue boolValue]:NO);
}

- (void) gpgSetDoNotResetFlags:(BOOL)flag
{
    GPG_SET_EXTRA_IVAR([NSNumber numberWithBool:flag], @"doNotResetFlags");
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s %@", __PRETTY_FUNCTION__, flag ? @"YES":@"NO");
}

#warning FIXME: That method is invoked in another thread! -> Observe notif all along object life
- (void) gpgMessageStoreMessageFlagsChanged:(NSNotification *)notification
{
    if([[[[notification userInfo] objectForKey:@"flags"] objectForKey:@"MessageIsRead"] isEqualToString:@"YES"]){
        NSEnumerator	*anEnum = [[[notification userInfo] objectForKey:@"messages"] objectEnumerator];
        Message			*aMessage;
        Message			*myMessage = [self message];
        
        while(aMessage = [anEnum nextObject]){
            if(aMessage == myMessage){
                if(GPGMailLoggingLevel)
                    NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
                [self gpgSetMessageReadStatusHasChanged:YES];
                break;
            }
        }
    }
}

- (void) gpgFadeToEmpty
{
    if([GPGMailBundle gpgMailWorks]){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
        if(YES/* && ![self gpgDoNotResetFlags]*/)
            [self gpgHideBanner];
    }
    ((void (*)(id, SEL))MessageContentController_fadeToEmpty)(self, _cmd);
}

- (void) gpg_updateDisplay // FIXME: LEOPARD Delayed invocation (from other thread) after decryption -> hides again!
{
    if(![GPGMailBundle gpgMailWorks]){
        ((void (*)(id, SEL))MessageContentController__updateDisplay)(self, _cmd); // will change message flags, if necessary
        return;
    }
        
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];
    Message			*aMessage = [self message];
    BOOL			shouldAuthenticate = NO;
    BOOL			shouldDecrypt = NO;
    BOOL			compareFlags = ([aMessage messageStore] != nil && (([mailBundle decryptsMessagesAutomatically] && [mailBundle decryptsOnlyUnreadMessagesAutomatically]) || ([mailBundle authenticatesMessagesAutomatically] && [mailBundle authenticatesOnlyUnreadMessagesAutomatically])));
    BOOL			readStatusChanged = NO;
    //    NSView          *originalCertifBanner = [certificateView retain];
	
    [[self gpgMessageViewerAccessoryViewOwner] messageChanged:aMessage];
    if(compareFlags){
#if defined(LEOPARD) || defined(TIGER)
        [self gpgSetMessageReadStatusHasChanged:([aMessage messageFlags] & 0x00000001) == 0]; // We check once if message is marked as unread; we will set it as read ourselves, as sometimes Mail does it only asynchronously
         // Since Tiger, MessageStoreMessageFlagsChanged poster is no longer message's messageStore; and flag change is sometimes done async
#else
        [self gpgSetMessageReadStatusHasChanged:NO];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gpgMessageStoreMessageFlagsChanged:) name:@"MessageStoreMessageFlagsChanged" object:[aMessage messageStore]];
#endif
    }
    
    //[super _updateDisplay];
#if 0
    if(aMessage == nil){
        [self gpgHideBanner];
    }
    else if([aMessage gpgIsEncrypted]){ // Do not get cached status from accessoryViewOwner, because it is not yet up-to-date!
        [self gpgShowPGPEncryptedBanner];
        if([mailBundle decryptsMessagesAutomatically])
            shouldDecrypt = YES;
    }
    else if([self gpgMessageWasInFactSigned]){
        [self gpgShowPGPSignatureBanner];
        if(/*![self gpgDoNotResetFlags]*/YES){
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] MessageWasInFactSigned");
            [self gpgSetMessageWasInFactSigned:NO];
            [self gpgSetMessageHasBeenDecrypted:NO];
        }
    }
    else if([self gpgMessageHasBeenDecrypted]){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] MessageHasBeenDecrypted");
        [self gpgShowPGPEncryptedBanner];
        [self gpgSetMessageHasBeenDecrypted:NO];
        if([mailBundle authenticatesMessagesAutomatically])
            shouldAuthenticate = YES;
    }
    else{
        [self gpgHideBanner];
    }
#else
    if(aMessage == nil){
        [self gpgHideBanner];
    }
    else if([self gpgMessageWasInFactSigned]){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] MessageWasInFactSigned");
        [self gpgShowPGPSignatureBanner];
    }
    else if([self gpgMessageHasBeenDecrypted]){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] MessageHasBeenDecrypted");
        [self gpgShowPGPEncryptedBanner];
/*        [self gpgSetMessageHasBeenDecrypted:NO];
        if([mailBundle authenticatesMessagesAutomatically])
            shouldAuthenticate = YES;*/
    }
    else if([aMessage gpgIsEncrypted]){ // Do not get cached status from accessoryViewOwner, because it is not yet up-to-date!
        [self gpgShowPGPEncryptedBanner];
        if([mailBundle decryptsMessagesAutomatically])
            shouldDecrypt = YES;
    }
    else if([aMessage gpgHasSignature]){ // Do not get cached status from accessoryViewOwner, because it is not yet up-to-date!
        [self gpgShowPGPSignatureBanner];
        if([mailBundle authenticatesMessagesAutomatically])
            shouldAuthenticate = YES;
    }
    else{
        [self gpgHideBanner];
    }
#endif
    
    ((void (*)(id, SEL))MessageContentController__updateDisplay)(self, _cmd); // will change message flags, if necessary
    
    if(compareFlags){
        readStatusChanged = [self gpgMessageReadStatusHasChanged];
#if defined(LEOPARD) || defined(TIGER)
        // Ensure 'read' flag has been set...
        if(!([aMessage messageFlags] & 0x00000001)){
#warning CHECK Is this here that we cause problems with the read status??
            [aMessage setMessageFlags:[aMessage messageFlags] | 0x00000001];
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] Changed messageFlags");
        }
#else
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageStoreMessageFlagsChanged" object:[aMessage messageStore]];
#endif
    }
    
	[NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(gpgAuthenticate:) object:nil];
	[NSRunLoop cancelPreviousPerformRequestsWithTarget:self selector:@selector(gpgDecrypt:) object:nil];
    if(shouldAuthenticate && (![mailBundle authenticatesOnlyUnreadMessagesAutomatically] || readStatusChanged)){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] Delaying verification");
        [self performSelector:@selector(gpgAuthenticate:) withObject:nil afterDelay:0.];
    }
    else if(shouldDecrypt && (![mailBundle decryptsOnlyUnreadMessagesAutomatically] || readStatusChanged)){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] Delaying decryption");
        [self performSelector:@selector(gpgDecrypt:) withObject:nil afterDelay:0.];
    }
    //    if(originalCertifBanner){
    //        certificateView = originalCertifBanner;
    ////        [self setCertificateView:originalCertifBanner]; // Has side-effects: resets other attributes
    //        [originalCertifBanner release];
    //    }
}

- (void) gpgForwardAction:(SEL)action from:(id)sender
{
    id	target = [self gpgMessageViewerAccessoryViewOwner];
    
    if(target && [target respondsToSelector:action])
        [target performSelector:action withObject:sender];
}

- (IBAction) gpgDecrypt:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgAuthenticate:(id)sender
{
    [self gpgForwardAction:_cmd from:sender];
}

- (BOOL) gpgValidateAction:(SEL)anAction
{
    if(anAction == @selector(gpgDecrypt:) || anAction == @selector(gpgAuthenticate:)){
        id	target = [self gpgMessageViewerAccessoryViewOwner];
        
        if(target && [target respondsToSelector:anAction])
            return [target gpgValidateAction:anAction];
    }
    
    return NO;
}

- (BOOL) gpgValidateMenuItem:(NSMenuItem *)menuItem
{
    SEL	anAction = [menuItem action];
    
    if(anAction == @selector(gpgDecrypt:) || anAction == @selector(gpgAuthenticate:)){
        return [self gpgValidateAction:anAction];
    }
    
    return ((BOOL (*)(id, SEL, id))MessageContentController_validateMenuItem)(self, _cmd, menuItem);
}
/*
 - (void)viewSource:fp12
 {
     NSLog(@"WILL viewSource:%@", fp12);
     [super viewSource:fp12];
     NSLog(@"DID viewSource:");
 }
 
 - (void)reloadCurrentMessage
 {
     NSLog(@"WILL reloadCurrentMessage");
     [super reloadCurrentMessage];
     NSLog(@"DID reloadCurrentMessage");
 }
 */

- (void)gpgSetMessage:fp8 headerOrder:fp12
{
    if([GPGMailBundle gpgMailWorks]){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] %s %@", __PRETTY_FUNCTION__, fp8);
        //    if(/*![self gpgDoNotResetFlags]*/YES){
        if(fp8 == nil || fp8 != [self message]){
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] Message changed");
            [self gpgSetMessageWasInFactSigned:NO];
            [self gpgSetMessageHasBeenDecrypted:NO];
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] Reset WasInFactSigned and HasBeenDecrypted");
        }
    }
    ((void (*)(id, SEL, id, id))MessageContentController_setMessage_headerOrder)(self, _cmd, fp8, fp12);
}

- (void)gpg_setMessage:fp8 headerOrder:fp12
{
    if([GPGMailBundle gpgMailWorks]){
        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] %s %@", __PRETTY_FUNCTION__, fp8);
        //    if(/*![self gpgDoNotResetFlags]*/YES){
        if(fp8 == nil || fp8 != [self message]){
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] Message changed(2)");
            if([self message] != nil)
                [[(MimeBody *)[[self message] messageBody] topLevelPart] clearCachedDescryptedMessageBody]; // FIXME: problem is that it's not the right part!
            [self gpgSetMessageWasInFactSigned:NO];
            [self gpgSetMessageHasBeenDecrypted:NO];
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] Reset WasInFactSigned and HasBeenDecrypted");
        }
        if(fp8 == nil)
            [[self gpgMessageViewerAccessoryViewOwner] messageChanged:nil];
    }
    ((void (*)(id, SEL, id, id))MessageContentController__setMessage_headerOrder)(self, _cmd, fp8, fp12);
}

// Do not use _gpgAddAccessoryView:, for backwards-compatibility with MailTags
- (void) _gpg2AddAccessoryView:(NSView *)accessoryView
{
    NSRect	aRect;
    NSRect	originalRect;
    float	aHeight;
#if 0
    // Works only for MIME signed, because Mail thinks it's (S/MIME) signed
    certificateView = accessoryView;
#else
    NSView  *resizedView = [[contentContainerView subviews] objectAtIndex:0];
    NSArray *additionalViews = nil;
    int     additionalViewsCount = [[contentContainerView subviews] count] - 1;
    
    if((GPGMailLoggingLevel > 0))
        NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
#ifdef LEOPARD
    // First subview is the NSScrollView or EditingMessageWebView (for notes)
    NSAssert1([resizedView isKindOfClass:[NSScrollView class]] || [resizedView isKindOfClass:NSClassFromString(@"EditingMessageWebView")], @"### GPGMail: views are not ordered the expected way! First view is %@", resizedView);
#else
    // First subview is the NSScrollView
    NSAssert1([resizedView isKindOfClass:[NSScrollView class]], @"### GPGMail: views are not ordered the expected way! First view is %@", resizedView);
#endif
    if(additionalViewsCount > 0)
        additionalViews = [[contentContainerView subviews] subarrayWithRange:NSMakeRange(1, additionalViewsCount)];
    originalRect = aRect = [resizedView frame];
    aHeight = NSHeight([accessoryView frame]);
    // Let's place our view on top (needed, because Junk banner always wants to be just above scrollView!)
    aRect.origin.y = NSHeight([contentContainerView bounds]) + [contentContainerView bounds].origin.y - aHeight;
    if(additionalViewsCount > 0){
        NSEnumerator    *anEnum = [additionalViews objectEnumerator];
        NSView          *currentBannerView = nil;
        float           resizedViewTop = NSMaxY([resizedView frame]);
        
        while(currentBannerView = [anEnum nextObject]){
            // Subview is moved down, when placed above scrollView (#0)
            if(NSMinY([currentBannerView frame]) >= resizedViewTop){
                [currentBannerView setFrameOrigin:NSMakePoint(NSMinX([currentBannerView frame]), NSMinY([currentBannerView frame]) - aHeight)];
                [currentBannerView setNeedsDisplay:YES];
            }
            // Subview is resized down when its top is above scrollview's top (for MailTags)
            else if(NSMaxY([currentBannerView frame]) >= (resizedViewTop - aHeight)){
                [currentBannerView setFrameSize:NSMakeSize(NSWidth([currentBannerView frame]), NSHeight([currentBannerView frame]) - aHeight)];
                [currentBannerView setNeedsDisplay:YES];
            }
        }
    }
    originalRect.size.height -= aHeight;
    aRect.size.height = aHeight;
    [accessoryView setFrame:aRect];
    [[resizedView superview] addSubview:accessoryView];
    [resizedView setFrame:originalRect];
#endif
}

// Do not use _gpgRemoveAccessoryView:redisplay:, for backwards-compatibility with MailTags
- (void) _gpg2RemoveAccessoryView:(NSView *)accessoryView redisplay:(BOOL)flag
{
    NSRect	originalRect;
    NSView  *resizedView = [[contentContainerView subviews] objectAtIndex:0];
    int     additionalViewsCount = [[contentContainerView subviews] count] - 1;
    
    if((GPGMailLoggingLevel > 0))
        NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    NSAssert([accessoryView ancestorSharedWithView:resizedView] != nil, @"Trying to remove unattached view!");
#ifdef LEOPARD
    // First subview is the NSScrollView or EditingMessageWebView
    NSAssert1([resizedView isKindOfClass:[NSScrollView class]] || [resizedView isKindOfClass:NSClassFromString(@"EditingMessageWebView")], @"### GPGMail: views are not ordered the expected way! First view is %@", resizedView);
#else
    NSAssert1([resizedView isKindOfClass:[NSScrollView class]], @"### GPGMail: views are not ordered the expected way! First view is %@", resizedView);
#endif
    originalRect = [resizedView frame];
    originalRect.size.height += NSHeight([accessoryView frame]);
    if(flag)
        [accessoryView removeFromSuperview];
    else
        [accessoryView removeFromSuperviewWithoutNeedingDisplay];
    additionalViewsCount--;
    if(additionalViewsCount > 0){
        // First subview is the NSScrollView
        NSArray         *additionalViews = [[contentContainerView subviews] subarrayWithRange:NSMakeRange(1, additionalViewsCount)];
        NSEnumerator    *anEnum = [additionalViews objectEnumerator];
        NSView          *currentBannerView = nil;
        float           resizedViewTop = NSMaxY([resizedView frame]);
        float           resizedViewBottom = NSMinY([resizedView frame]);
        
        while(currentBannerView = [anEnum nextObject]){
            // Subview is moved up, when already above scrollView (#0)
            if(NSMinY([currentBannerView frame]) >= resizedViewTop){
                [currentBannerView setFrameOrigin:NSMakePoint(NSMinX([currentBannerView frame]), NSMinY([currentBannerView frame]) + NSHeight([accessoryView frame]))];
                [currentBannerView setNeedsDisplay:YES];
            }
            // Subview is resized up, when its top is in middle of scrollView (for MailTags)
            else if(NSMaxY([currentBannerView frame]) >= resizedViewBottom){
                [currentBannerView setFrameSize:NSMakeSize(NSWidth([currentBannerView frame]), NSHeight([currentBannerView frame]) + NSHeight([accessoryView frame]))];
                [currentBannerView setNeedsDisplay:YES];
            }
        }
    }
    [resizedView setFrame:originalRect];
}
/*
 - (GPGMessageViewerAccessoryViewOwner *) _gpgExistingMessageViewerAccessoryViewOwner
 {
     if(_accessoryViewOwnerPerViewer != NULL)
         return NSMapGet(_accessoryViewOwnerPerViewer, self);
     else
         return nil;
 }
 */
- (GPGMessageViewerAccessoryViewOwner *) gpgMessageViewerAccessoryViewOwner
{
    // WARNING: this limits us to 1 accessoryView per viewer
    GPGMessageViewerAccessoryViewOwner	*accessoryViewOwner = GPG_GET_EXTRA_IVAR(@"messageViewerAccessoryViewOwner");
    
    if(accessoryViewOwner == nil){
        accessoryViewOwner = [[GPGMessageViewerAccessoryViewOwner alloc] initWithDelegate:self];
        GPG_SET_EXTRA_IVAR(accessoryViewOwner, @"messageViewerAccessoryViewOwner");
        [accessoryViewOwner release];
    }
    
    return accessoryViewOwner;
}

- (BOOL) _gpgBannerIsShown
{
    return [[[self gpgMessageViewerAccessoryViewOwner] view] superview] != nil;
}

- (void) _gpgShowBannerWithType:(int)bannerType
{
    GPGMessageViewerAccessoryViewOwner	*anOwner = nil;
    
    if(![self _gpgBannerIsShown]){
        anOwner = [self gpgMessageViewerAccessoryViewOwner];
        [anOwner setBannerType:bannerType];
        [self _gpg2AddAccessoryView:[anOwner view]];
    }
    else{
        anOwner = [self gpgMessageViewerAccessoryViewOwner];
        if([anOwner bannerType] != bannerType){
            [self _gpg2RemoveAccessoryView:[anOwner view] redisplay:NO];
            [anOwner setBannerType:bannerType];
            [self _gpg2AddAccessoryView:[anOwner view]];
        }
    }
    //    [anOwner setMessage:[self message]];
    if((GPGMailLoggingLevel > 0))
        NSLog(@"[DEBUG] %s => %@", __PRETTY_FUNCTION__, [anOwner bannerTypeDescription]);    
}

- (void) gpgShowPGPSignatureBanner
{
    // gpgMessageWasInFactSigned: special case where message has been encrypted and signed in one operation
    [self _gpgShowBannerWithType:([self gpgMessageWasInFactSigned] ? gpgDecryptedSignatureInfoBanner:gpgAuthenticationBanner)];
}

- (void) gpgShowPGPEncryptedBanner
{
    // gpgMessageHasBeenDecrypted: special case where message has been encrypted
    [self _gpgShowBannerWithType:([self gpgMessageHasBeenDecrypted] ? gpgDecryptedInfoBanner:gpgDecryptionBanner)];
}

- (void) gpgHideBanner
{
    if([self _gpgBannerIsShown]){
        GPGMessageViewerAccessoryViewOwner	*anOwner = [self gpgMessageViewerAccessoryViewOwner];
        
        [self _gpg2RemoveAccessoryView:[anOwner view] redisplay:YES];
        //        [anOwner setMessage:nil];
    }
}

- (void) gpgAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner replaceViewWithView:(NSView *)view
{
#if 1
    if(![self _gpgBannerIsShown])
        NSLog(@"### GPGMail: banner should already be visible");
    else
#else
		NSAssert([self _gpgBannerIsShown], @"### GPGMail: banner should already be visible");
#endif
    [self _gpg2RemoveAccessoryView:[owner view] redisplay:NO];
    [self _gpg2AddAccessoryView:view];
}

#if defined(LEOPARD) || defined(TIGER)
#else
- (void) gpgAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner showStatusMessage:(NSString *)message
{
    if([[[[self textView] window] delegate] respondsToSelector:@selector(showStatusMessage:)]){
        // Delegate can be a MessageViewer, or a MessageEditor (for standalone viewers!)
        [[[[self textView] window] delegate] showStatusMessage:message];
        if([message length] > 0)
            [[[[self textView] window] delegate] performSelector:@selector(showStatusMessage:) withObject:@"" afterDelay:0.3]; // There is a risk we wipe out something else, but if we don't do that call, the "Done." stays on screen.
    }
}
#endif

- (void) gpgAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner displayMessage:(Message *)message isSigned:(BOOL)isSigned
{
	MessageViewingState *viewingState = [self viewingState];
	
	if(viewingState == nil)
		return;
	
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
#if defined(LEOPARD) || defined(TIGER)
    // WARNING: we must ask to the very part that we set the decrypted message body! - see -[MimePart _gpgDecodePGP]
#ifdef LEOPARD
	MessageBody	*messageBody = [[(MimeBody *)[message messageBody] topLevelPart] decryptedMessageBodyIsEncrypted:NULL isSigned:NULL];
#else
	MessageBody	*messageBody = [[(MimeBody *)[message messageBody] topLevelPart] decryptedMessageBody];
#endif
	Message		*decryptedMessage = message;
	
    viewingState = [MessageHeaderDisplay copyViewingState:viewingState];
	[message gpgSetMayClearCachedDecryptedMessageBody:NO];
	if(!messageBody)
		messageBody = [message messageBody];
	else{
		decryptedMessage = [messageBody message];
	}
	//	MutableMessageHeaders	*customHeaders = [[message headers] mutableCopy]; // Not done by S/MIME
	
	//	[customHeaders]; // we need to add headers in decrypted mart
	//    [viewingState setHeaderAttributedString:[[message headers] attributedStringShowingHeaderDetailLevel:[self headerDetailLevel]]]; // FIXME: Empty, because no headers... -> copy and update headers when decrypting
	//	[customHeaders release];
	//    [viewingState setHeaderAttributedString:[(MessageHeaders *)[decryptedMessage headers] attributedStringShowingHeaderDetailLevel:[self headerDetailLevel]]]; // FIXME: Empty, because no headers... -> copy and update headers when decrypting
    if([[(MessageBody *)messageBody attachments] count] == 0) // numberOfAttachments not up-to-date! Wrapper's
        [viewingState setAttachmentsDescription:nil];
    else
        [viewingState setAttachmentsDescription:[MessageHeaderDisplay formattedAttachmentsSizeForMessage:/*decryptedMessage*/message]];
	//    NSLog(@"$$$ AttachmentsDescription = %@", [viewingState attachmentsDescription]);
    [viewingState setValue:messageBody forKey:@"mimeBody"];
    [self cacheViewingState:viewingState forMessage:message/*decryptedMessage*/]; // decryptedMessage?
    [self setMessage:/*message*/decryptedMessage headerOrder:[viewingState headerOrder]]; // WARNING: will clear decrypted body cache!
    [viewingState setHeaderAttributedString:[[message headers] attributedStringShowingHeaderDetailLevel:[self headerDetailLevel]]]; // FIXME: Empty, because no headers... -> copy and update headers when decrypting; this very call is useless!!!
	[message gpgSetMayClearCachedDecryptedMessageBody:YES];
#else
#if 1
    // Works, but headers are not up-to-date
    //[inViewer clearCache];
    ///////////////////////    [self setMessage:message headerOrder:[[self viewingState] headerOrder]]; // If this line was commented out, no header would appear at all!
    //  [inViewer _setMessage:decodedMessage headerOrder:[[inViewer viewingState] headerOrder]];
    //  [inViewer _fetchContentsForMessage:decodedMessage fromStore:[decodedMessage messageStore] withViewingState:[inViewer viewingState]];
    //  [inViewer viewerPreferencesChanged:nil];
    //  [inViewer _updateDisplay];
    
    viewingState = [MessageHeaderDisplay copyViewingState:viewingState];
    [viewingState setHeaderAttributedString:[(MessageHeaders *)[message headers] attributedStringShowingHeaderDetailLevel:[self headerDetailLevel]]];
	//    NSLog(@"$$$ HeaderAttributedString = %@", [viewingState headerAttributedString]);
    if(/*[message numberOfAttachments]*/[[(MessageBody *)[message messageBody] attachments] count] == 0) // numberOfAttachments not up-to-date! Wrapper's
        [viewingState setAttachmentsDescription:nil];
    else
        [viewingState setAttachmentsDescription:[MessageHeaderDisplay formattedAttachmentsSizeForMessage:message]];
	//    NSLog(@"$$$ AttachmentsDescription = %@", [viewingState attachmentsDescription]);
    [viewingState setValue:[message messageBody] forKey:@"mimeBody"];
	//    viewingState->preferredAlternative = -1; // Does nothing
	//    ((MessageViewingState *)[self viewingState])->preferredAlternative = -1; // Does nothing
	/////////////    viewingState->preferredEncoding = ((MessageViewingState *)[self viewingState])->preferredEncoding; // Because it was not copied
    [self cacheViewingState:viewingState forMessage:message];
    [self setMessage:message headerOrder:[viewingState headerOrder]];
#else
    //  id  viewingState = [MessageHeaderDisplay copyViewingState:[inViewer viewingState]];
    //  id  viewingState = [[inViewer viewingState] retain];
    
    //  [inViewer->headerDisplay displayAttributedString:[MessageHeaderDisplay copyHeadersForMessage:decodedMessage viewingState:viewingState]];
    //  [inViewer setMessage:decodedMessage headerOrder:[viewingState headerOrder]];
    //  inViewer->_message = [decodedMessage retain];
    //  inViewer->textDisplay->messageBody = [decodedMessage messageBody];
    //  inViewer->textDisplay->needsSetUp = YES;
    [inViewer->headerDisplay setUp];
    //  [inViewer->headerDisplay display:[[decodedMessage headers] attributedStringShowingHeaderDetailLevel:[inViewer headerDetailLevel]]];
    [inViewer->headerDisplay displayAttributedString:[[decodedMessage headers] attributedStringShowingHeaderDetailLevel:[inViewer headerDetailLevel]]];
    //  [inViewer->textDisplay displayAttributedString:[decodedMessage attributedString]];
    //  [MessageHeaderDisplay setUpEncryptionAndSignatureImageForMessage:decodedMessage viewingState:viewingState];
    //  [viewingState release];
    //  inViewer->_viewingState = viewingState;
    //  [inViewer setMostRecentHeaderOrder:[viewingState headerOrder]];
    //  [viewingState release];
#endif
#endif

    // Now update messageView content
    // If we want to add a fade-out effect, we'll need to wait to the fade-out effect
    // being done before we call [viewer _loadMessageIntoTextView].
    // Fade-out effect is launched by [viewer fadeToEmpty]
	//    if([[message messageBody] isKindOfClass:[MimeBody class]])
	//        [(MimeBody *)[message messageBody] setPreferredAlternative:0];
	//    [self showFirstAlternative:nil];
    // FIXME: on LEOPARD, always YES, even when not the case, e.g. for encrypted MIME message!
#if 0
    if([[message messageBody] isHTML]){
        NSLog(@"HTML message -> do not reset flags");
        [self gpgSetDoNotResetFlags:YES];
    }
#endif
#if defined(LEOPARD) || defined(TIGER)
	// reloadDocument does quite nothing
	//	[self _updateDisplay];
	//	[self clearCache];
		[self reloadCurrentMessage]; // Needed, to get flag change notif via _updateDisplay
	//	((void (*)(id, SEL))MessageContentController__updateDisplay)(self, _cmd);
	//  [self setMessage:decryptedMessage headerOrder:[[self viewingState] headerOrder]]; // will display decrypted one, but without headers!
#else
    [self reloadCurrentMessage];
#endif

    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] Callback from accessoryViewOwner");
    [self gpgSetMessageWasInFactSigned:isSigned];
    [self gpgSetMessageHasBeenDecrypted:YES];
    // FIXME: on LEOPARD, always YES, even when not the case, e.g. for encrypted MIME message!
#if 0
   if([[message messageBody] isHTML]){
#warning TESTME Was not working, but now, is it?
        // We cannot use delay = 0!
        // New bug: banner is no longer visible...
        [self performSelector:@selector(gpg_showFirstAlternative:) withObject:nil afterDelay:0.1];
    }
#endif

    /*    if([[message messageBody] isHTML]){
        _messageWasInFactSigned = isSigned;
    _messageHasBeenDecrypted = YES;
    [self showFirstAlternative:nil];
    } DOES NOTHING... */
    // Will post MessageWillBeDisplayed notification; we need to call this method anyway,
    // to be sure that URLs are parsed by textView and clickable
}

- (void) gpg_showFirstAlternative:(id)sender
{
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] First alternative -> do not reset flags");
    [self gpgSetDoNotResetFlags:YES];
    [self showFirstAlternative:sender]; // Performs -_updateDisplay invocation, delayed!
										//    [self performSelector:@selector(gpg_resetFlags:) withObject:nil afterDelay:0.1];
}

- (void) gpg_resetFlags:(id)sender
{
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    [self gpgSetDoNotResetFlags:NO];
    [self gpgSetMessageWasInFactSigned:NO];
    [self gpgSetMessageHasBeenDecrypted:NO];
}

- (Message *) gpgMessageForAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner
{
    return [self message];
}

- (Message *) gpgMessage
{
    // On MacOS X, [self message] sometimes returns zombies!
    return _message;
}

/*#if 0
// Patch in MailTags by Scott Morrison
-(void) _showBannerView:(id)view{
    old__showBannerView_IMP(self,_cmd,view);
    
    float contentViewWidth =NSWidth([contentContainerView frame]);
    int viewCount = [[contentContainerView subviews] count] ;
    int viewIndex = 0;
    NSView *sideBarView = nil;
    for (viewIndex = 1; viewIndex <viewCount; viewIndex++){
        NSView *thisView = [[contentContainerView subviews] objectAtIndex:viewIndex];
        if ([thisView isKindOfClass:[MailTagsSideBarView class]])
          {
            if (viewIndex==1){ 
                //  MailTags Side Panel view Was added first -- make note of it for later resizeing 
                sideBarView = thisView;
            }
          }
        else{
            if (sideBarView){
                // thisView is a banner view and MailTags side bar view has already been draw as too tall.
                // resize MailTags SideBar View and redirect pointer to nil;
                NSRect sideBarViewRect = [sideBarView frame];
                sideBarViewRect.size.height -= NSHeight([thisView frame]);
                [sideBarView setFrame: sideBarViewRect];
                [sideBarView setNeedsDisplay:YES];
                sideBarView=nil;
                
            }
            if (NSWidth([thisView frame]) < contentViewWidth) {
                // need to widen view to span top
                [thisView setFrameSize:NSMakeSize(contentViewWidth,NSHeight([thisView frame]))];
            } //if 
        } //else
    }// for
}
#end
*/
@end
