
/*
 * Copyright (c) 2000-2010, GPGMail Project Team <gpgmail-devel@lists.gpgmail.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGMail Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGMAIL PROJECT TEAM ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGMAIL PROJECT TEAM BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MessageEditor+GPGMail.h"
#import "GPGMailBundle.h"
#import "GPGMailPatching.h"
#import "GPGMailComposeAccessoryViewOwner.h"
#import <MailToolbarItem.h>
#import <MVComposeAccessoryViewOwner.h>
#import <MessageEditor.h>
#import <ComposeHeaderView.h>
#import <Cocoa/Cocoa.h>
#import "Message+GPGMail.h"


#ifdef TIGER
#warning Copy LEOPARD code
#endif
#if defined(SNOW_LEOPARD) || defined(LEOPARD)

#ifdef SNOW_LEOPARD_64
@interface GPGMail_HeadersEditor : NSObject
#else
@interface HeadersEditor(GPGMail)
#endif
- (NSMutableArray *)gpgAccessoryViewOwners;
- (NSPopUpButton *) gpgFromPopup;
@end

//asm(".weak_reference _OBJC_CLASS_$_HeadersEditor");
//asm(".weak_reference _OBJC_CLASS_$_MailDocumentEditor");

#ifdef SNOW_LEOPARD_64
@implementation GPGMail_HeadersEditor
#else
@implementation HeadersEditor(GPGMail)
#endif
static IMP  HeadersEditor_changeFromHeader = NULL;

+ (void) load
{
    HeadersEditor_changeFromHeader = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(changeFromHeader:), NSClassFromString(@"HeadersEditor"), @selector(gpgChangeFromHeader:), [self class]);
}

#warning FIXME: LEOPARD Misses _gpgInitializeOptionsFromMessages

- (NSMutableArray *)gpgAccessoryViewOwners
{
	if([self valueForKey:@"accessoryViewOwners"] == nil || ![[self valueForKey:@"accessoryViewOwners"] isKindOfClass:[NSMutableArray class]])
		[self setValue:[[NSMutableArray alloc] init] forKey:@"accessoryViewOwners"];
	return [self valueForKey:@"accessoryViewOwners"];
}

- (NSPopUpButton *) gpgFromPopup
{
    return [self valueForKey:@"fromPopup"];
}

- (void) gpgForwardAction:(SEL)action from:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    NSEnumerator	*anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    id				anOwner;
    
    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:action])
            [anOwner performSelector:action withObject:sender];
}

- (void) gpgChangeFromHeader:(id)sender
{	
    ((void (*)(id, SEL, id))HeadersEditor_changeFromHeader)(self, _cmd, sender);
    if([GPGMailBundle gpgMailWorks])
        [self gpgForwardAction:_cmd from:sender]; // _cmd = changeFromHeader: !!!
}

@end

#ifdef SNOW_LEOPARD_64
@implementation GPGMail_MailDocumentEditor
#else
@implementation MailDocumentEditor(GPGMail)
#endif

static IMP  MailDocumentEditor_backEndDidLoadInitialContent = NULL;
static IMP  MailDocumentEditor_backEnd_shouldDeliverMessage = NULL;
//static IMP  MailDocumentEditor_backEnd_shouldSaveMessage = NULL;
static IMP  MailDocumentEditor_showOrHideStationery = NULL;
static IMP  MailDocumentEditor_animationDidEnd = NULL;
//static IMP  MailDocumentEditor_backEnd_willCreateMessageWithHeaders = NULL; // Invoked only when saving message as draft
static IMP  MailDocumentEditor_changeReplyMode = NULL;

+ (void)load {
	MailDocumentEditor_backEndDidLoadInitialContent = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(backEndDidLoadInitialContent:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgBackEndDidLoadInitialContent:), [self class]);
	MailDocumentEditor_backEnd_shouldDeliverMessage = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(backEnd:shouldDeliverMessage:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgBackEnd:shouldDeliverMessage:), [self class]);
	MailDocumentEditor_showOrHideStationery = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(showOrHideStationery:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgShowOrHideStationery:), [self class]);
	MailDocumentEditor_animationDidEnd = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(animationDidEnd:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgAnimationDidEnd:), [self class]);
	MailDocumentEditor_changeReplyMode = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(changeReplyMode:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgChangeReplyMode:), [self class]);
}




- (GPGMailComposeAccessoryViewOwner *)gpgMyComposeAccessoryViewOwner {
    NSEnumerator				*theEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    MVComposeAccessoryViewOwner	*anOwner;

    while(anOwner = [theEnum nextObject]){
        if([anOwner isKindOfClass:[NSClassFromString(@"GPGMailComposeAccessoryViewOwner") class]])
            return (GPGMailComposeAccessoryViewOwner *)anOwner;

    }
    
    return nil;
}

- (void)gpgShowOrHideStationery:(id)fp8 {
    if([GPGMailBundle gpgMailWorks]){
        if(![self stationeryPaneIsVisible]){
            NSView  *accessoryView = [[self gpgMyComposeAccessoryViewOwner] composeAccessoryView];
            
            if(![accessoryView isHidden]){
                NSRect  aRect = [[self valueForKey:@"composeWebView"] frame];
                
                aRect.size.height += NSHeight([accessoryView frame]);
                [[self valueForKey:@"composeWebView"] setFrame:aRect];
                [accessoryView setHidden:YES];
            }
        }
    }

    ((void (*)(id, SEL, id))MailDocumentEditor_showOrHideStationery)(self, _cmd, fp8);
}

- (void)gpgAnimationDidEnd:(id)fp8
{
    ((void (*)(id, SEL, id))MailDocumentEditor_animationDidEnd)(self, _cmd, fp8);
    
    if([GPGMailBundle gpgMailWorks]){
        if(![self stationeryPaneIsVisible]){
            NSView  *accessoryView = [[self gpgMyComposeAccessoryViewOwner] composeAccessoryView];
            
            if([accessoryView isHidden]){
                NSRect  aRect = [[self valueForKey:@"composeWebView"] frame];
                
                [accessoryView setHidden:NO];
                aRect.size.height -= NSHeight([accessoryView frame]);
                [[self valueForKey:@"composeWebView"] setFrame:aRect];
            }
        }
    }
}

- (void) gpgAddAccessoryViewOwner:(MVComposeAccessoryViewOwner *)owner {
	[[(HeadersEditor *)[self headersEditor] gpgAccessoryViewOwners] addObject:owner];
}

- (void)gpgInsertComposeAccessoryViewOfOwner:(MVComposeAccessoryViewOwner *)owner {
    NSView  *accessoryView = [owner composeAccessoryView];
    NSView  *containerView = [[self valueForKey:@"composeWebView"] superview];
    NSRect  aRect = [accessoryView frame];
    float   aHeight = NSHeight(aRect);
    
    // Place accessory view just above composeWebView
    aRect.size.width = NSWidth([containerView bounds]);
    aRect.origin.x = 0;
    aRect.origin.y = NSMaxY([containerView bounds]) - aHeight;
    [accessoryView setFrame:aRect];
    [accessoryView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [containerView addSubview:accessoryView];
    aRect = [[self valueForKey:@"composeWebView"] frame];
    aRect.size.height -= aHeight;
    [[self valueForKey:@"composeWebView"] setFrame:aRect];
}

- (void)gpgBackEndDidLoadInitialContent:(id)fp8 {
    // WARNING That method can be invoked more than once, when message is created by AppleScript (bug?).
	((void (*)(id, SEL, id))MailDocumentEditor_backEndDidLoadInitialContent)(self, _cmd, fp8);

    if([GPGMailBundle gpgMailWorks]){
        NSEnumerator                *anEnum = [[(HeadersEditor *)[self headersEditor] gpgAccessoryViewOwners] objectEnumerator];
        MVComposeAccessoryViewOwner *eachOwner;
        BOOL                        createNewAccessoryViewOwner = YES;
        
        while(eachOwner = [anEnum nextObject]){
            if([eachOwner isKindOfClass:NSClassFromString(@"GPGMailComposeAccessoryViewOwner")]){
                createNewAccessoryViewOwner = NO;
                break;
            }
        }
        if(createNewAccessoryViewOwner){
            MVComposeAccessoryViewOwner	*myComposeAccessoryViewOwner = [NSClassFromString(@"GPGMailComposeAccessoryViewOwner") composeAccessoryViewOwner];
			
            [self gpgAddAccessoryViewOwner:myComposeAccessoryViewOwner];
            [myComposeAccessoryViewOwner setupUIForMessage:[fp8 message]]; // Toolbar already finished
            [self gpgInsertComposeAccessoryViewOfOwner:myComposeAccessoryViewOwner]; // Must be called after setUIForMessage:, which loads the nib	
			
			
			Message *originalMessage = [fp8 originalMessage];
			if (originalMessage) {
				GPGMailBundle *mailBundle = [GPGMailBundle sharedInstance];
				NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:3];
				
				BOOL shouldEncrypted = [mailBundle signsReplyToSignedMessage] && [originalMessage gpgIsEncrypted];
				BOOL shouldSigned = [mailBundle encryptsReplyToEncryptedMessage] && [originalMessage gpgHasSignature];
				BOOL shouldMIME = ([originalMessage gpgIsEncrypted] || [originalMessage gpgHasSignature]) && [originalMessage gpgIsPGPMIMEMessage];
				
				[options setObject:[NSNumber numberWithBool:shouldEncrypted] forKey:@"encrypted"];
				[options setObject:[NSNumber numberWithBool:shouldSigned] forKey:@"signed"];
				[options setObject:[NSNumber numberWithBool:shouldMIME] forKey:@"MIME"];
				
				[(GPGMailComposeAccessoryViewOwner*)myComposeAccessoryViewOwner gpgSetOptions:options];
			}
		}
    }
}

- (BOOL)gpgBackEnd:fp12 shouldDeliverMessage:fp16
{
    if([GPGMailBundle gpgMailWorks]){
        MVComposeAccessoryViewOwner	*anOwner = [self gpgMyComposeAccessoryViewOwner];

        if(anOwner != nil && ![anOwner messageWillBeDelivered:fp16]){
            NSBeep();
            return NO;
        }
    }

	return ((BOOL (*)(id, SEL, id, id))MailDocumentEditor_backEnd_shouldDeliverMessage)(self, _cmd, fp12, fp16);
}

/*
- (IBAction)gpgToggleEncryptionForNewMessage:(id)sender
{
    NSEnumerator	*theEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    id				anOwner;
    
    while(anOwner = [theEnum nextObject])
        if([anOwner respondsToSelector:_cmd])
            [anOwner performSelector:_cmd withObject:sender];
}

- (IBAction)gpgToggleSignatureForNewMessage:(id)sender
{
    NSEnumerator	*theEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    id				anOwner;
    
    while(anOwner = [theEnum nextObject])
        if([anOwner respondsToSelector:_cmd])
            [anOwner performSelector:_cmd withObject:sender];
}
*/

- (void)gpgChangeReplyMode:(id)fp8
{
    // Invoked when user clicks the reply/reply to all button in a compose window
    // Let's force reevaluation of PGP rules by accessoryView owner
    ((void (*)(id, SEL, id))MailDocumentEditor_changeReplyMode)(self, _cmd, fp8);
    
    NSEnumerator	*anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    id				anOwner;
    
    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:@selector(evaluateRules)])
            [anOwner evaluateRules];
}

- (NSArray *)gpgAccessoryViewOwners
{
    return [[self headersEditor] gpgAccessoryViewOwners];
}

- (NSPopUpButton *) gpgFromPopup
{
    return [[self headersEditor] gpgFromPopup];
}

- (void)gpgSetAccessoryViewOwners:(NSArray *)newOwners
{
	[[(HeadersEditor *)[self headersEditor] gpgAccessoryViewOwners] setArray:newOwners];
}

- (BOOL)gpgIsRealEditor
{
    return ([self valueForKey:@"_backEnd"] != nil);
}

- (NSToolbar *)gpgToolbar
{
    return [self valueForKey:@"_toolbar"];
}

- (BOOL) gpgValidateToolbarItem:(NSToolbarItem *)theItem
{
    // Forwarded by GPGMailBundle
    NSEnumerator	*anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    id				anOwner;
#if defined(SNOW_LEOPARD) || defined(LEOPARD)
	// That works because we use only single segment items...
    SEL				action = ([theItem isKindOfClass:NSClassFromString(@"SegmentedToolbarItem")] ? [(SegmentedToolbarItem *)theItem actionForSegment:0] : [theItem action]);
#else
    SEL				action = [theItem action];
#endif
    
    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:action])
            return [anOwner validateToolbarItem:theItem];
    return NO;
}

- (BOOL) gpgValidateMenuItem:(NSMenuItem *)theItem
{
    // Forwarded by GPGMailBundle
    NSEnumerator	*anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    id				anOwner;
    SEL				action = [theItem action];
    
    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:action])
            return [anOwner validateMenuItem:theItem];
    return NO;
}

- (void) gpgForwardAction:(SEL)action from:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    NSEnumerator	*anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    id				anOwner;
    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:action])
            [anOwner performSelector:action withObject:sender];
}

- (IBAction) gpgToggleEncryptionForNewMessage:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleSignatureForNewMessage:(id)sender;
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePublicKeys:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePersonalKey:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePublicKey:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleAutomaticPublicKeysChoice:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleSymetricEncryption:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleUsesOnlyOpenPGPStyle:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

@end

#else

@implementation MessageEditor(GPGMail)

static IMP  MessageEditor_changeFromHeader = NULL;
static IMP  MessageEditor_backEnd_didCompleteLoadForEditorSettings = NULL;
static IMP  MessageEditor_backEnd_shouldDeliverMessage = NULL;
//static IMP  MessageEditor_backEnd_shouldSaveMessage = NULL;
#ifdef TIGER
static IMP  MessageEditor_composeHeaderViewWillBeginCustomization = NULL;
static IMP  MessageEditor_composeHeaderViewDidEndCustomization = NULL;
static IMP  MessageEditor_initWithType_settings = NULL;
#else
static IMP  MessageEditor_initWithType_message_showAllHeaders = NULL;
#endif

+ (void) load
{
    MessageEditor_changeFromHeader = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(changeFromHeader:), [MessageEditor class], @selector(gpg_changeFromHeader:), [MessageEditor class]);
	MessageEditor_backEnd_didCompleteLoadForEditorSettings = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(backEnd:didCompleteLoadForEditorSettings:), [MessageEditor class], @selector(gpgBackEnd:didCompleteLoadForEditorSettings:), [MessageEditor class]);
	MessageEditor_backEnd_shouldDeliverMessage = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(backEnd:shouldDeliverMessage:), [MessageEditor class], @selector(gpgBackEnd:shouldDeliverMessage:), [MessageEditor class]);
//	MessageEditor_backEnd_shouldSaveMessage = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(backEnd:shouldSaveMessage:), [MessageEditor class], @selector(gpgBackEnd:shouldSaveMessage:), [MessageEditor class]);
#ifdef TIGER
    MessageEditor_composeHeaderViewWillBeginCustomization = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(composeHeaderViewWillBeginCustomization:), [MessageEditor class], @selector(gpgComposeHeaderViewWillBeginCustomization:), [MessageEditor class]);
    MessageEditor_composeHeaderViewDidEndCustomization = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(composeHeaderViewDidEndCustomization:), [MessageEditor class], @selector(gpgComposeHeaderViewDidEndCustomization:), [MessageEditor class]);
    MessageEditor_initWithType_settings = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(initWithType:settings:), [MessageEditor class], @selector(gpgInitWithType:settings:), [MessageEditor class]);
#else
    MessageEditor_initWithType_message_showAllHeaders = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(initWithType:message:showAllHeaders:), [MessageEditor class], @selector(gpgInitWithType:message:showAllHeaders:), [MessageEditor class]);
#endif
}

#ifdef TIGER
- (void) gpgAddAccessoryViewOwner:(MVComposeAccessoryViewOwner *)owner
{
	if(!accessoryViewOwners)
		accessoryViewOwners = [[NSMutableArray alloc] init];
	[accessoryViewOwners addObject:owner];
}
#endif

- (BOOL)gpgBackEnd:fp12 shouldDeliverMessage:fp16
{
    if([GPGMailBundle gpgMailWorks]){
        NSEnumerator				*anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
        MVComposeAccessoryViewOwner	*anOwner;
        
        while(anOwner = [anEnum nextObject]){
            // We pass the -messageWillBeDelivered: method only to our own
            // own accessory view controller, because if there are more than
            // one poser (like MailPriority), then the method would be invoked
            // by each poser!
            if([anOwner isKindOfClass:[GPGMailComposeAccessoryViewOwner class]]){
                if([anOwner messageWillBeDelivered:fp16])
                    break;
                else{
                    NSBeep();
                    return NO;
                }
            }
        }
    }
    
    return ((BOOL (*)(id, SEL, id, id))MessageEditor_backEnd_shouldDeliverMessage)(self, _cmd, fp12, fp16);
}

#if 0
// No longer needed, because MessageEditor does it that way
- (char)gpgBackEnd:fp12 shouldSaveMessage:fp16
{
    NSEnumerator				*anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
    MVComposeAccessoryViewOwner	*anOwner;
    
#warning Is it not sent anyway??
    while(anOwner = [anEnum nextObject]){
        // We pass the -messageWillBeSaved: method only to our own
        // own accessory view controller, because if there are more than
        // one poser (like MailPriority), then the method would be invoked
        // by each poser!
        if([anOwner isKindOfClass:[GPGMailComposeAccessoryViewOwner class]]){
            if([anOwner messageWillBeSaved:fp16])
                break;
            else{
                NSBeep();
                return NO;
            }
        }
    }
    
    return ((char (*)(id, SEL, id, id))MessageEditor_backEnd_shouldSaveMessage)(self, _cmd, fp12, fp16);
}
#endif

- (void)gpgBackEnd:(id)fp8 didCompleteLoadForEditorSettings:(id)fp12
{
    if(![GPGMail gpgMailWorks]){
        ((void (*)(id, SEL, id, id))MessageEditor_backEnd_didCompleteLoadForEditorSettings)(self, _cmd, fp8, fp12);
        return;
    }
    
#warning FIXME
#ifdef TIGER
    NSView	*editorView = [self mainContentView];
    BOOL    editorWasCreatedByAppleScript = [editorView isKindOfClass:NSClassFromString(@"MessageTextView")];
#endif
    
    // WARNING When a message is composed via an AppleScript, that method is invoked multiple times!!!
    if(accessoryViewOwners != nil){
        NSEnumerator    *existingOwnersEnum = [accessoryViewOwners objectEnumerator];
        id              anOwner;
        
        while(anOwner = [existingOwnersEnum nextObject]){
            if([anOwner isKindOfClass:[GPGMailComposeAccessoryViewOwner class]]){
                ((void (*)(id, SEL, id, id))MessageEditor_backEnd_didCompleteLoadForEditorSettings)(self, _cmd, fp8, fp12);
                return;
            }
        }
    }
    
	GPGMailComposeAccessoryViewOwner	*myComposeAccessoryViewOwner;
	NSRect                              aRect;
    //	NSView                              *parentView;
    //	NSSize                              aSize;
	
	// WARNING OptionalViews are already hidden
	// FIXME: Try to do that earlier, and support multiple accessoryView owners (one per bundle)
	myComposeAccessoryViewOwner = [GPGMailComposeAccessoryViewOwner composeAccessoryViewOwner];
	[self gpgAddAccessoryViewOwner:myComposeAccessoryViewOwner];
#ifdef TIGER
#warning FIXME: Temporary workaround - disabled accessoryView when composer window generated by AppleScript
    if(editorWasCreatedByAppleScript)
        [myComposeAccessoryViewOwner setDisplaysButtonsInComposeWindow:NO];
#endif
	[myComposeAccessoryViewOwner setupUIForMessage:[fp8 message]]; // too late: toolbar already finished
#if 1
#if 0
	// Not so easy to participate to the animation: see ComposeHeaderView class
	NSRect	containerRect = [(NSView *)_composeHeaderView frame];
	float	addedHeight = NSHeight([[myComposeAccessoryViewOwner composeAccessoryView] frame]);
	
    NSLog(@"%s - headerView: %@, mainContentView: %@, accView: %@", __PRETTY_FUNCTION__, NSStringFromRect([(NSView *)_composeHeaderView frame]), NSStringFromRect([[self mainContentView] frame]), NSStringFromRect([[myComposeAccessoryViewOwner composeAccessoryView] frame]));
	[(NSView *)_composeHeaderView setFrame:NSMakeRect(NSMinX(containerRect), NSMinY(containerRect) - addedHeight, NSWidth(containerRect), NSHeight(containerRect) + addedHeight)];
	// WARNING OptionalView is flipped!
	[[myComposeAccessoryViewOwner composeAccessoryView] setFrame:NSMakeRect(0, NSHeight(containerRect), NSWidth(containerRect), addedHeight)];
    //	[[myComposeAccessoryViewOwner composeAccessoryView] setFrame:NSMakeRect(0, 0, NSWidth(containerRect), addedHeight)];
	[(NSView *)_composeHeaderView addSubview:[myComposeAccessoryViewOwner composeAccessoryView]];
	[editorView setFrameSize:NSMakeSize(NSWidth([editorView frame]), NSHeight([editorView frame]) - addedHeight)];
    //    [[myComposeAccessoryViewOwner composeAccessoryView] setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    NSLog(@"==> headerView: %@, mainContentView: %@, accView: %@", NSStringFromRect([(NSView *)_composeHeaderView frame]), NSStringFromRect([[self mainContentView] frame]), NSStringFromRect([[myComposeAccessoryViewOwner composeAccessoryView] frame]));
#else
    float	addedHeight = NSHeight([[myComposeAccessoryViewOwner composeAccessoryView] frame]);
    
    // 2 cases: message created manually, or message created by Applescript (e.g. from iPhoto)
    if(![editorView isKindOfClass:NSClassFromString(@"MessageTextView")]){
        // 1) manually: editorView = EditingMessageWebView, superview = NSView
        aRect = [editorView frame];
        [[myComposeAccessoryViewOwner composeAccessoryView] setFrame:NSMakeRect(NSMinX(aRect), NSMaxY(aRect) - addedHeight, NSWidth(aRect), addedHeight)];
        [[editorView superview] addSubview:[myComposeAccessoryViewOwner composeAccessoryView]];
        [editorView setFrameSize:NSMakeSize(NSWidth([editorView frame]), NSHeight([editorView frame]) - addedHeight)];
    }
    else{
        // 2) by Applescript: editorView = MessageTextView, superview = NSClipView
        NSScrollView  *aMovedView = [editorView enclosingScrollView];
        
        aRect = [aMovedView frame];
        [[myComposeAccessoryViewOwner composeAccessoryView] setFrame:NSMakeRect(NSMinX(aRect), NSMaxY(aRect) - addedHeight, NSWidth(aRect), addedHeight)];
        [[aMovedView superview] addSubview:[myComposeAccessoryViewOwner composeAccessoryView]];
        [aMovedView setFrameSize:NSMakeSize(NSWidth([aMovedView frame]), NSHeight([aMovedView frame]) - addedHeight)];
        // FIXME: Our horizontal separator line should be moved to the top in that case
    }
    [[myComposeAccessoryViewOwner composeAccessoryView] setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
#endif
#else
	aRect = [[myComposeAccessoryViewOwner composeAccessoryView] frame];
	parentView = [[self window] contentView];
	aRect.size.width = NSWidth([parentView bounds]);
	aRect.origin.x = 0;
	aRect.origin.y = NSMinY([[[parentView subviews] objectAtIndex:0] frame]) - aRect.size.height;
	aSize = [[[parentView subviews] objectAtIndex:1] frame].size;
	aSize.height -= aRect.size.height;
	[[[parentView subviews] objectAtIndex:1] setFrameSize:aSize];
	[[myComposeAccessoryViewOwner composeAccessoryView] setFrame:aRect];
	[parentView addSubview:[myComposeAccessoryViewOwner composeAccessoryView]];
#endif
    ((void (*)(id, SEL, id, id))MessageEditor_backEnd_didCompleteLoadForEditorSettings)(self, _cmd, fp8, fp12);
}

- (void) gpgForwardAction:(SEL)action from:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    NSEnumerator	*anEnum = [accessoryViewOwners objectEnumerator];
    id				anOwner;

    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:action])
            [anOwner performSelector:action withObject:sender];
}

- (IBAction) gpgToggleEncryptionForNewMessage:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleSignatureForNewMessage:(id)sender;
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePublicKeys:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePersonalKey:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgChoosePublicKey:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleAutomaticPublicKeysChoice:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleSymetricEncryption:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (IBAction) gpgToggleUsesOnlyOpenPGPStyle:(id)sender
{
    // Forwarded by GPGMailBundle, from menuItem action
    [self gpgForwardAction:_cmd from:sender];
}

- (NSArray *) gpgAccessoryViewOwners
{
    return accessoryViewOwners;
}

- (void) gpgSetAccessoryViewOwners:(NSArray *)newOwners
{
    newOwners = [[NSMutableArray alloc] initWithArray:newOwners];
    [accessoryViewOwners release];
    accessoryViewOwners = (NSMutableArray *)newOwners;
}

- (BOOL) gpgIsRealEditor
{
#ifdef TIGER
    return (_backEnd != nil);
#else
    return (backEnd != nil);
#endif
}

- (NSToolbar *) gpgToolbar
{
    return _toolbar;
}

- (BOOL) gpgValidateToolbarItem:(NSToolbarItem *)theItem
{
    // Forwarded by GPGMailBundle
    NSEnumerator	*anEnum = [accessoryViewOwners objectEnumerator];
    id				anOwner;
#ifdef TIGER
	// That works because we use only single segment items...
    SEL				action = ([theItem isKindOfClass:[MailToolbarItem class]] ? [(MailToolbarItem *)theItem actionForSegment:0] : [theItem action]);
#else
    SEL				action = [theItem action];
#endif

    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:action])
            return [anOwner validateToolbarItem:theItem];
    return NO;
}

- (BOOL) gpgValidateMenuItem:(NSMenuItem *)theItem
{
    // Forwarded by GPGMailBundle
    NSEnumerator	*anEnum = [accessoryViewOwners objectEnumerator];
    id				anOwner;
    SEL				action = [theItem action];

    while(anOwner = [anEnum nextObject])
        if([anOwner respondsToSelector:action])
            return [anOwner validateMenuItem:theItem];
    return NO;
}

- (NSPopUpButton *) gpgFromPopup
{
    return fromPopup;
}

- (void) gpg_changeFromHeader:(id)sender
{
    ((void (*)(id, SEL, id))MessageEditor_changeFromHeader)(self, _cmd, sender);
    if([GPGMail gpgMailWorks])
        [self gpgForwardAction:_cmd from:sender]; // _cmd = changeFromHeader: !!!
}

- (void) gpgSetOptions:(NSDictionary *)options
{
    [self gpgForwardAction:_cmd from:options];
}

/*
 + createEditorWithType:(int)fp12 originalMessage:fp16 forwardedText:fp20 showAllHeaders:(char)fp24
 {
 // Is not invoked when user double-clicked message, then replied to it
 // Only invoked when direct reply/forward/redirect
 NSLog(@"$$$ [MessageEditor createEditorWithType:%d originalMessage:%@ forwardedText:%@ showAllHeaders:%@]", fp12, fp16, fp20, (fp24 ? @"YES":@"NO"));
 return [super createEditorWithType:fp12 originalMessage:fp16 forwardedText:fp20 showAllHeaders:fp24];
 }
 */

- (void) _gpgInitializeOptionsFromMessages:(NSArray *)messages
{
	if([messages count]){
#if 0
		BOOL                signedReplyToSignedMessage = [[GPGMailBundle sharedInstance] signsReplyToSignedMessage];
		BOOL                encryptedReplyToEncryptedMessage = [[GPGMailBundle sharedInstance] encryptsReplyToEncryptedMessage];
		NSEnumerator		*anEnum = [messages objectEnumerator];
		Message				*aMessage;
		BOOL                messageWasEncrypted = NO;
		BOOL                messageWasSigned = NO;
		BOOL                messageUsedPGPMIME = NO;
		NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:3];
		
		while((aMessage = [anEnum nextObject])){
			messageWasEncrypted = messageWasEncrypted || ([aMessage gpgIsEncrypted] || ([aMessage messageFlags] & 0x08));
			messageWasSigned = messageWasSigned || ([aMessage gpgHasSignature] || ([aMessage messageFlags] & 0x800000));
			messageUsedPGPMIME = messageUsedPGPMIME || (messageWasEncrypted || messageWasSigned) && [aMessage gpgIsPGPMIMEMessage];
            //			NSLog(@"$$$ messageFlags = %08X", [aMessage messageFlags]);
		}
        
		if(messageWasEncrypted && encryptedReplyToEncryptedMessage)
			[options setObject:[NSNumber numberWithBool:YES] forKey:@"encrypted"];
		if(messageWasSigned && signedReplyToSignedMessage)
			[options setObject:[NSNumber numberWithBool:YES] forKey:@"signed"];
		if(messageWasSigned || messageWasEncrypted)
			[options setObject:[NSNumber numberWithBool:messageUsedPGPMIME] forKey:@"MIME"];
#warning TODO: Retrieve signer key and pass it for encryption (or hint)
		
		if([options count])
			[self performSelector:@selector(gpgSetOptions:) withObject:options afterDelay:0];
#else
		NSEnumerator		*anEnum = [messages objectEnumerator];
		Message				*aMessage;
		BOOL                messageWasEncrypted = NO;
		BOOL                messageWasSigned = NO;
		BOOL                messageUsedPGPMIME = NO;
		NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:3];
        BOOL                logging = (GPGMailLoggingLevel > 0);
		
		while((aMessage = [anEnum nextObject])){
            // We no longer check messageFlags, because we're not interested by S/MIME info
			messageWasEncrypted = messageWasEncrypted || ([aMessage gpgIsEncrypted] /*|| ([aMessage messageFlags] & 0x08)*/);
			messageWasSigned = messageWasSigned || ([aMessage gpgHasSignature] /*|| ([aMessage messageFlags] & 0x800000)*/);
			messageUsedPGPMIME = messageUsedPGPMIME || (messageWasEncrypted || messageWasSigned) && [aMessage gpgIsPGPMIMEMessage];
            if(logging)
                NSLog(@"[DEBUG] %@", [aMessage gpgDescription]);
		}
        
        [options setObject:[NSNumber numberWithBool:messageWasEncrypted] forKey:@"encrypted"];
        [options setObject:[NSNumber numberWithBool:messageWasSigned] forKey:@"signed"];
        [options setObject:[NSNumber numberWithBool:messageUsedPGPMIME] forKey:@"MIME"];
#warning TODO: Retrieve signer key and pass it for encryption (or hint)
        if(logging)
            NSLog(@"[DEBUG] Options for reply: %@", options);
		
		if([options count])
			[self performSelector:@selector(gpgSetOptions:) withObject:options afterDelay:0];
#endif
	}
}

#ifdef TIGER
- (id)gpgInitWithType:(int)fp8 settings:(id)fp12
{
	// Settings is a dict with array of messages ('Messages')
	if(((id (*)(id, SEL, int, id))MessageEditor_initWithType_settings)(self, _cmd, fp12, fp16) && [GPGMailBundle gpgMailWorks]){
		[self _gpgInitializeOptionsFromMessages:[fp12 objectForKey:@"Messages"]];
	}
	
	return self;
}

#else
- gpgInitWithType:(int)fp8 message:(Message *)message showAllHeaders:(char)fp16
{
    if(self = ((id (*)(id, SEL, int, id, char))MessageEditor_initWithType_message_showAllHeaders)(self, _cmd, fp8, message, fp16) && [GPGMailBundle gpgMailWorks]){
#warning Does not work for detached viewers, because passed message is the decrypted one, not the original one
		// I should keep a ref from decrypted to original (and backwards?)
		// Or use same technique as in Tiger...
		[self _gpgInitializeOptionsFromMessages:[NSArray arrayWithObjects:message, nil]];
    }
    
    return self;
}
#endif

#ifdef TIGER

- (void)gpgComposeHeaderViewWillBeginCustomization:(id)fp8
{
    if([GPGMailBundle gpgMailWorks]){
        //    NSLog(@"%s - headerView: %@, mainContentView: %@", __PRETTY_FUNCTION__, NSStringFromRect([(NSView *)_composeHeaderView frame]), NSStringFromRect([[self mainContentView] frame]));
        NSEnumerator				*anEnum = [accessoryViewOwners objectEnumerator];
        MVComposeAccessoryViewOwner	*eachOwner;
        
        while((eachOwner = [anEnum nextObject])){
            if([eachOwner isKindOfClass:[GPGMailComposeAccessoryViewOwner class]] && [[eachOwner composeAccessoryView] window] != nil){
                [[eachOwner composeAccessoryView] setHidden:YES];
                //            NSLog(@"accView: %@", NSStringFromRect([[eachOwner composeAccessoryView] frame]));
            }
        }
	}
    ((void (*)(id, SEL, id))MessageEditor_composeHeaderViewWillBeginCustomization)(self, _cmd, fp8);
    //    NSLog(@"==> headerView: %@, mainContentView: %@", NSStringFromRect([(NSView *)_composeHeaderView frame]), NSStringFromRect([[self mainContentView] frame]));
}

- (void)gpgComposeHeaderViewDidEndCustomization:(id)fp8
{
    //    NSLog(@"%s - headerView: %@, mainContentView: %@", __PRETTY_FUNCTION__, NSStringFromRect([(NSView *)_composeHeaderView frame]), NSStringFromRect([[self mainContentView] frame]));
    ((void (*)(id, SEL, id))MessageEditor_composeHeaderViewDidEndCustomization)(self, _cmd, fp8);
    
    if([GPGMailBundle gpgMailWorks]){
        NSEnumerator				*anEnum = [accessoryViewOwners objectEnumerator];
        MVComposeAccessoryViewOwner	*eachOwner;
        
        while((eachOwner = [anEnum nextObject])){
            if([eachOwner isKindOfClass:[GPGMailComposeAccessoryViewOwner class]] && [[eachOwner composeAccessoryView] window] != nil){
                NSView	*editorView = [self mainContentView];
                float	aHeight = NSHeight([[eachOwner composeAccessoryView] frame]);
                
                if(NSMaxY([editorView frame]) != NSMinY([[eachOwner composeAccessoryView] frame])){
                    [editorView setFrameSize:NSMakeSize(NSWidth([editorView frame]), NSHeight([editorView frame]) - aHeight)];
                    NSRect	aRect = [editorView frame];
                    [[eachOwner composeAccessoryView] setFrame:NSMakeRect(0, NSMaxY(aRect), NSWidth(aRect), aHeight)];
                }
                [[eachOwner composeAccessoryView] setHidden:NO];
                //            NSLog(@"accView: %@", NSStringFromRect([[eachOwner composeAccessoryView] frame]));
            }
        }
    }
    //    NSLog(@"==> headerView: %@, mainContentView: %@", NSStringFromRect([(NSView *)_composeHeaderView frame]), NSStringFromRect([[self mainContentView] frame]));
}
#endif

@end

#endif
