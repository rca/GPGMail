
/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Project Team BE LIABLE FOR ANY
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
#import <MVComposeAccessoryViewOwner.h>
#import <MessageEditor.h>
#import <ComposeHeaderView.h>
#import <Cocoa/Cocoa.h>
#import "Message+GPGMail.h"
#import "HeadersEditor.h"
#import "SegmentedToolbarItem.h"



#ifdef SNOW_LEOPARD_64
@interface GPGMail_HeadersEditor : NSObject
#else
@interface HeadersEditor (GPGMail)
#endif
- (NSMutableArray *)gpgAccessoryViewOwners;
- (NSPopUpButton *)gpgFromPopup;
@end

// asm(".weak_reference _OBJC_CLASS_$_HeadersEditor");
// asm(".weak_reference _OBJC_CLASS_$_MailDocumentEditor");

#ifdef SNOW_LEOPARD_64
@implementation GPGMail_HeadersEditor
#else
@implementation HeadersEditor (GPGMail)
#endif
static IMP HeadersEditor_changeFromHeader = NULL;

+ (void)load {
	HeadersEditor_changeFromHeader = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(changeFromHeader:), NSClassFromString(@"HeadersEditor"), @selector(gpgChangeFromHeader:), [self class]);
}

#warning FIXME: LEOPARD Misses _gpgInitializeOptionsFromMessages

- (NSMutableArray *)gpgAccessoryViewOwners {
	if ([self valueForKey:@"accessoryViewOwners"] == nil || ![[self valueForKey:@"accessoryViewOwners"] isKindOfClass:[NSMutableArray class]]) {
		[self setValue:[[NSMutableArray alloc] init] forKey:@"accessoryViewOwners"];
	}
	return [self valueForKey:@"accessoryViewOwners"];
}

- (NSPopUpButton *)gpgFromPopup {
	return [self valueForKey:@"fromPopup"];
}

- (void)gpgForwardAction:(SEL)action from:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	NSEnumerator *anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
	id anOwner;

	while (anOwner = [anEnum nextObject])
		if ([anOwner respondsToSelector:action]) {
			[anOwner performSelector:action withObject:sender];
		}
}

- (void)gpgChangeFromHeader:(id)sender {
	((void (*)(id, SEL, id))HeadersEditor_changeFromHeader)(self, _cmd, sender);
	if ([GPGMailBundle gpgMailWorks]) {
		[self gpgForwardAction:_cmd from:sender];                          // _cmd = changeFromHeader: !!!
	}
}

@end

#ifdef SNOW_LEOPARD_64
@implementation GPGMail_MailDocumentEditor
#else
@implementation MailDocumentEditor (GPGMail)
#endif

static IMP MailDocumentEditor_backEndDidLoadInitialContent = NULL;
static IMP MailDocumentEditor_backEnd_shouldDeliverMessage = NULL;
// static IMP  MailDocumentEditor_backEnd_shouldSaveMessage = NULL;
static IMP MailDocumentEditor_showOrHideStationery = NULL;
static IMP MailDocumentEditor_animationDidEnd = NULL;
// static IMP  MailDocumentEditor_backEnd_willCreateMessageWithHeaders = NULL; // Invoked only when saving message as draft
static IMP MailDocumentEditor_changeReplyMode = NULL;

+ (void)load {
	MailDocumentEditor_backEndDidLoadInitialContent = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(backEndDidLoadInitialContent:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgBackEndDidLoadInitialContent:), [self class]);
	MailDocumentEditor_backEnd_shouldDeliverMessage = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(backEnd:shouldDeliverMessage:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgBackEnd:shouldDeliverMessage:), [self class]);
	MailDocumentEditor_showOrHideStationery = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(showOrHideStationery:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgShowOrHideStationery:), [self class]);
	MailDocumentEditor_animationDidEnd = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(animationDidEnd:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgAnimationDidEnd:), [self class]);
	MailDocumentEditor_changeReplyMode = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(changeReplyMode:), NSClassFromString(@"MailDocumentEditor"), @selector(gpgChangeReplyMode:), [self class]);
}




- (GPGMailComposeAccessoryViewOwner *)gpgMyComposeAccessoryViewOwner {
	NSEnumerator *theEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
	MVComposeAccessoryViewOwner *anOwner;

	while (anOwner = [theEnum nextObject]) {
		if ([anOwner isKindOfClass:[NSClassFromString (@"GPGMailComposeAccessoryViewOwner")class]]) {
			return (GPGMailComposeAccessoryViewOwner *)anOwner;
		}

	}

	return nil;
}

- (void)gpgShowOrHideStationery:(id)fp8 {
	if ([GPGMailBundle gpgMailWorks]) {
		if (![self stationeryPaneIsVisible]) {
			NSView *accessoryView = [[self gpgMyComposeAccessoryViewOwner] composeAccessoryView];

			if (![accessoryView isHidden]) {
				NSRect aRect = [[self valueForKey:@"composeWebView"] frame];

				aRect.size.height += NSHeight([accessoryView frame]);
				[[self valueForKey:@"composeWebView"] setFrame:aRect];
				[accessoryView setHidden:YES];
			}
		}
	}

	((void (*)(id, SEL, id))MailDocumentEditor_showOrHideStationery)(self, _cmd, fp8);
}

- (void)gpgAnimationDidEnd:(id)fp8 {
	((void (*)(id, SEL, id))MailDocumentEditor_animationDidEnd)(self, _cmd, fp8);

	if ([GPGMailBundle gpgMailWorks]) {
		if (![self stationeryPaneIsVisible]) {
			NSView *accessoryView = [[self gpgMyComposeAccessoryViewOwner] composeAccessoryView];

			if ([accessoryView isHidden]) {
				NSRect aRect = [[self valueForKey:@"composeWebView"] frame];

				[accessoryView setHidden:NO];
				aRect.size.height -= NSHeight([accessoryView frame]);
				[[self valueForKey:@"composeWebView"] setFrame:aRect];
			}
		}
	}
}

- (void)gpgAddAccessoryViewOwner:(MVComposeAccessoryViewOwner *)owner {
	[[(HeadersEditor *)[self headersEditor] gpgAccessoryViewOwners] addObject:owner];
}

- (void)gpgInsertComposeAccessoryViewOfOwner:(MVComposeAccessoryViewOwner *)owner {
	NSView *accessoryView = [owner composeAccessoryView];
	NSView *containerView = [[self valueForKey:@"composeWebView"] superview];
	NSRect aRect = [accessoryView frame];
	float aHeight = NSHeight(aRect);

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

	if ([GPGMailBundle gpgMailWorks]) {
		NSEnumerator *anEnum = [[(HeadersEditor *)[self headersEditor] gpgAccessoryViewOwners] objectEnumerator];
		MVComposeAccessoryViewOwner *eachOwner;
		BOOL createNewAccessoryViewOwner = YES;

		while (eachOwner = [anEnum nextObject]) {
			if ([eachOwner isKindOfClass:NSClassFromString(@"GPGMailComposeAccessoryViewOwner")]) {
				createNewAccessoryViewOwner = NO;
				break;
			}
		}
		if (createNewAccessoryViewOwner) {
			MVComposeAccessoryViewOwner *myComposeAccessoryViewOwner = [NSClassFromString (@"GPGMailComposeAccessoryViewOwner")composeAccessoryViewOwner];

			[self gpgAddAccessoryViewOwner:myComposeAccessoryViewOwner];
			[myComposeAccessoryViewOwner setupUIForMessage:[fp8 message]];                                     // Toolbar already finished
			[self gpgInsertComposeAccessoryViewOfOwner:myComposeAccessoryViewOwner];                           // Must be called after setUIForMessage:, which loads the nib


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

				[(GPGMailComposeAccessoryViewOwner *) myComposeAccessoryViewOwner gpgSetOptions:options];
			}
		}
	}
}

- (BOOL)gpgBackEnd:fp12 shouldDeliverMessage:fp16 {
	if ([GPGMailBundle gpgMailWorks]) {
		MVComposeAccessoryViewOwner *anOwner = [self gpgMyComposeAccessoryViewOwner];

		if (anOwner != nil && ![anOwner messageWillBeDelivered:fp16]) {
			NSBeep();
			return NO;
		}
	}

	return ((BOOL (*)(id, SEL, id, id))MailDocumentEditor_backEnd_shouldDeliverMessage)(self, _cmd, fp12, fp16);
}

/*
 * - (IBAction)gpgToggleEncryptionForNewMessage:(id)sender
 * {
 *  NSEnumerator	*theEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
 *  id				anOwner;
 *
 *  while(anOwner = [theEnum nextObject])
 *      if([anOwner respondsToSelector:_cmd])
 *          [anOwner performSelector:_cmd withObject:sender];
 * }
 *
 * - (IBAction)gpgToggleSignatureForNewMessage:(id)sender
 * {
 *  NSEnumerator	*theEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
 *  id				anOwner;
 *
 *  while(anOwner = [theEnum nextObject])
 *      if([anOwner respondsToSelector:_cmd])
 *          [anOwner performSelector:_cmd withObject:sender];
 * }
 */

- (void)gpgChangeReplyMode:(id)fp8 {
	// Invoked when user clicks the reply/reply to all button in a compose window
	// Let's force reevaluation of PGP rules by accessoryView owner
	((void (*)(id, SEL, id))MailDocumentEditor_changeReplyMode)(self, _cmd, fp8);

	NSEnumerator *anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
	id anOwner;

	while (anOwner = [anEnum nextObject])
		if ([anOwner respondsToSelector:@selector(evaluateRules)]) {
			[anOwner evaluateRules];
		}
}

- (NSArray *)gpgAccessoryViewOwners {
	return [[self headersEditor] gpgAccessoryViewOwners];
}

- (NSPopUpButton *)gpgFromPopup {
	return [[self headersEditor] gpgFromPopup];
}

- (void)gpgSetAccessoryViewOwners:(NSArray *)newOwners {
	[[(HeadersEditor *)[self headersEditor] gpgAccessoryViewOwners] setArray:newOwners];
}

- (BOOL)gpgIsRealEditor {
	return ([self valueForKey:@"_backEnd"] != nil);
}

- (NSToolbar *)gpgToolbar {
	return [self valueForKey:@"_toolbar"];
}

- (BOOL)gpgValidateToolbarItem:(NSToolbarItem *)theItem {
	// Forwarded by GPGMailBundle
	NSEnumerator *anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
	id anOwner;
	// That works because we use only single segment items...
	SEL action = ([theItem isKindOfClass:NSClassFromString(@"SegmentedToolbarItem")] ? [(SegmentedToolbarItem *) theItem actionForSegment:0] : [theItem action]);

	while (anOwner = [anEnum nextObject])
		if ([anOwner respondsToSelector:action]) {
			return [anOwner validateToolbarItem:theItem];
		}
	return NO;
}

- (BOOL)gpgValidateMenuItem:(NSMenuItem *)theItem {
	// Forwarded by GPGMailBundle
	NSEnumerator *anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
	id anOwner;
	SEL action = [theItem action];

	while (anOwner = [anEnum nextObject])
		if ([anOwner respondsToSelector:action]) {
			return [anOwner validateMenuItem:theItem];
		}
	return NO;
}

- (void)gpgForwardAction:(SEL)action from:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	NSEnumerator *anEnum = [[self gpgAccessoryViewOwners] objectEnumerator];
	id anOwner;

	while (anOwner = [anEnum nextObject])
		if ([anOwner respondsToSelector:action]) {
			[anOwner performSelector:action withObject:sender];
		}
}

- (IBAction)gpgToggleEncryptionForNewMessage:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleSignatureForNewMessage:(id)sender;
{
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgChoosePublicKeys:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgChoosePersonalKey:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgChoosePublicKey:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleAutomaticPublicKeysChoice:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleSymetricEncryption:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleUsesOnlyOpenPGPStyle:(id)sender {
	// Forwarded by GPGMailBundle, from menuItem action
	[self gpgForwardAction:_cmd from:sender];
}

@end
