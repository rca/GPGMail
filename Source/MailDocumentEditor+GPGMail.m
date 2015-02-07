/* MailDocumentEditor+GPGMail.m re-created by Lukas Pitschl (@lukele) on Sat 27-Aug-2011 */

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

#import <Libmacgpg/Libmacgpg.h>
#import "NSObject+LPDynamicIvars.h"
#import <MailAccount.h>
#import <HeadersEditor.h>
#import "ComposeBackEnd.h"
#import <MailDocumentEditor.h>
#import <MailNotificationCenter.h>
#import "GMSecurityMethodAccessoryView.h"
#import "NSWindow+GPGMail.h"
#import "Message+GPGMail.h"
#import "HeadersEditor+GPGMail.h"
#import "MailDocumentEditor+GPGMail.h"
#import "ComposeBackEnd+GPGMail.h"
#import "GPGMailBundle.h"
#import <MFError.h>

static const NSString *kUnencryptedReplyToEncryptedMessage = @"unencryptedReplyToEncryptedMessage";

@implementation MailDocumentEditor_GPGMail

- (id)MAInitWithBackEnd:(id)backEnd {
    /* On Yosemite, when Mail is invoked from an AppleScript the backEnd is not fully initiated at the time when the security properties queue is first used.
       This method however is called in between, so it makes sense to setup the queue in here, if it's not already setup.
	   -[GPGMail_ComposeBackEnd setupSecurityPropertiesQueues] takes care of checking whether the queue needs
	   to be setup, so there's no need to perform a check here.
     */
    [backEnd setupSecurityPropertiesQueue];
	
    return [self MAInitWithBackEnd:backEnd];
}

- (void)didExitFullScreen:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(configureSecurityMethodAccessoryViewForNormalMode) withObject:nil waitUntilDone:NO];
}

- (void)configureSecurityMethodAccessoryViewForNormalMode {
    GMSecurityMethodAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    [accessoryView configureForWindow:[self valueForKey:@"_window"]];
}

- (void)updateSecurityMethodHighlight {
    GMSecurityMethodAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    ComposeBackEnd *backEnd = ((MailDocumentEditor *)self).backEnd;
    NSDictionary *securityProperties = ((ComposeBackEnd_GPGMail *)backEnd).securityProperties;
    
	GPGMAIL_SECURITY_METHOD oldSecurityMethod = accessoryView.securityMethod;
	
    BOOL shouldEncrypt = [securityProperties[@"shouldEncrypt"] boolValue];
    BOOL shouldSign = [securityProperties[@"shouldSign"] boolValue];
	BOOL shouldSymmetric = [securityProperties[@"shouldSymmetric"] boolValue];
    
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)backEnd).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).securityMethod;
    
    accessoryView.securityMethod = securityMethod;
    
    if(shouldEncrypt || shouldSign || (shouldSymmetric && securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP))
        accessoryView.active = YES;
    else
        accessoryView.active = NO;
    
	if(oldSecurityMethod != securityMethod)
		[[((MailDocumentEditor *)self) headersEditor] updateFromAndAddSecretKeysIfNecessary:@(securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP ? YES : NO)];
}

- (void)updateSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod {
    GMSecurityMethodAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    accessoryView.securityMethod = securityMethod;
}

- (void)MABackEndDidLoadInitialContent:(id)content {
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullScreen:) name:@"NSWindowDidExitFullScreenNotification" object:nil];
    
    // Setup security method hint accessory view in top right corner of the window.
    [self setupSecurityMethodHintAccessoryView];
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).securityMethod;
    [self updateSecurityMethod:securityMethod];
    [self MABackEndDidLoadInitialContent:content];
    // Set backend was initialized, so securityMethod changes will start to send notifications.
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).wasInitialized = YES;
}

- (void)setupSecurityMethodHintAccessoryView {
    GMSecurityMethodAccessoryView *accessoryView = [[GMSecurityMethodAccessoryView alloc] init];
    accessoryView.delegate = self;
    NSWindow *window = [self valueForKey:@"_window"];
	
   if([NSApp mainWindow].styleMask & NSFullScreenWindowMask) // Only check the mein window to detect fullscreen.
       [accessoryView configureForFullScreenWindow:window];
   else
       [accessoryView configureForWindow:window];
    
    [self setIvar:@"SecurityMethodHintAccessoryView" value:accessoryView];
}

- (void)hideSecurityMethodAccessoryView {
    GMSecurityMethodAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    accessoryView.hidden = YES;
}

- (void)securityMethodAccessoryView:(GMSecurityMethodAccessoryView *)accessoryView didChangeSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod {
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).securityMethod = securityMethod;
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).userDidChooseSecurityMethod = YES;
    if(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        [[(MailDocumentEditor *)self headersEditor] _updateSecurityControls];
    }
    else {
        [[(MailDocumentEditor *)self headersEditor] updateSecurityControls];
    }
    
}

- (void)MADealloc {
    // Sometimes this fails, so simply ignore it.
    @try {
		[(NSNotificationCenter *)[NSNotificationCenter defaultCenter] removeObserver:self];
        [(MailNotificationCenter *)[NSClassFromString(@"MailNotificationCenter") defaultCenter] removeObserver:self];
    }
    @catch(NSException *e) {
        
    }
	[self MADealloc];
}

- (BOOL)isUnencryptedReplyToEncryptedMessageWithChecklist:(NSMutableArray *)checklist {
	// While Mail.app internally removes objects from the checklist, we instead add one
	// if the user explicitly told us to continue with sending.
	// We have to handle it this way, since sendMessageAfterChecking is called for each failing
	// check and we can't determine which one is the first call, to correctly add our own item to the checklist,
	// and later remove it, when the check has cleared.
	// So instead we add an item.
	BOOL shouldWarn = NO;

	ComposeBackEnd *backEnd = (ComposeBackEnd *)[(MailDocumentEditor *)self backEnd];
	NSDictionary *securityProperties = [(ComposeBackEnd_GPGMail *)backEnd securityProperties];

	BOOL isReply = [(ComposeBackEnd_GPGMail *)backEnd messageIsBeingReplied];
	BOOL originalMessageIsEncrypted = ((Message_GPGMail *)[backEnd originalMessage]).PGPEncrypted;
	BOOL replyShouldBeEncrypted = [(ComposeBackEnd_GPGMail *)[(MailDocumentEditor *)self backEnd] GMEncryptIfPossible] && [securityProperties[@"shouldEncrypt"] boolValue];

	if(isReply && originalMessageIsEncrypted && !replyShouldBeEncrypted && ![checklist containsObject:kUnencryptedReplyToEncryptedMessage])
		shouldWarn = YES;

	// If checklist no longer contains the unencryptedReplyToEncryptedMessage item, it means
	// that the user decided to send the message regardless of our warning.
	if(!shouldWarn)
		return NO;

	// Otherwise perform the check.
	return YES;
}

- (void)displayWarningForUnencryptedReplyToEncryptedMessageUpdatingChecklist:(NSMutableArray *)checklist {
	NSArray *recipientsMissingCertificates = [(ComposeBackEnd *)[(MailDocumentEditor *)self backEnd] recipientsThatHaveNoKeyForEncryption];

	NSMutableString *recipientWarning = [NSMutableString new];
	for(NSString *recipient in recipientsMissingCertificates) {
		[recipientWarning appendFormat:@"- %@\n", recipient];
	}

	NSMutableString *explanation = [NSMutableString new];
	if([recipientsMissingCertificates count]) {
		NSString *missingKeysString = [GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_MISSING_KEYS"];
		if([recipientsMissingCertificates count] == 1)
			missingKeysString = [GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_MISSING_KEYS_SINGULAR"];
		[explanation appendFormat:@"%@\n", [NSString stringWithFormat:missingKeysString, recipientWarning]];
	}

	[explanation appendString:[GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_EXPLANATION"]];

	NSMutableString *solutionProposals = [NSMutableString new];
	[solutionProposals appendString:[GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_SOLUTION_REMOVE_PREVIOUS_CORRESPONDENCE"]];

	if([recipientsMissingCertificates count]) {
		[solutionProposals appendString:@"\n"];
		if([recipientsMissingCertificates count] == 1)
			[solutionProposals appendString:[GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_SOLUTION_IMPORT_KEYS_SINGULAR"]];
		else
			[solutionProposals appendString:[GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_SOLUTION_IMPORT_KEYS"]];
	}
	[explanation appendString:solutionProposals];
	[explanation appendString:@"\n"];

	NSAlert *unencryptedReplyAlert = [NSAlert new];
	[unencryptedReplyAlert setMessageText:[GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_TITLE"]];
	[unencryptedReplyAlert setInformativeText:explanation];
	[unencryptedReplyAlert addButtonWithTitle:[GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_BUTTON_CANCEL"]];
	[unencryptedReplyAlert addButtonWithTitle:[GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_BUTTON_SEND_ANYWAY"]];
	[unencryptedReplyAlert setIcon:[NSImage imageNamed:@"GPGMail"]];

	// On Mavericks and later we can use, beginSheetModalForWindow:.
	// Before that, we have to use NSBeginAlertSheet.
	if(floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
		id __weak weakSelf = self;
		[unencryptedReplyAlert beginSheetModalForWindow:[(DocumentEditor *)self window] completionHandler:^(NSModalResponse returnCode) {
			id __strong strongSelf = weakSelf;

			if(returnCode == NSAlertSecondButtonReturn) {
				// The user pressed send anyway, so add the kUnencryptedReplyToEncryptedMessage item
				// to the checklist, so the next time around sendMessageAfterChecking: is called,
				// we no longer check if the message is sent unencrypted.
				[checklist addObject:kUnencryptedReplyToEncryptedMessage];
				[strongSelf sendMessageAfterChecking:checklist];
			}
			else {
				[[strongSelf headersEditor] setAGoodFirstResponder];
			}
		}];
	}
	else {
		NSDictionary *contextInfo = @{@"ThingsToCheck": checklist};
		NSBeginAlertSheet([GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_TITLE"], [GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_BUTTON_CANCEL"], [GPGMailBundle localizedStringForKey:@"UNENCRYPTED_REPLY_TO_ENCRYPTED_MESSAGE_BUTTON_SEND_ANYWAY"], nil, [(MailDocumentEditor *)self window], self, nil, @selector(warnAboutUnecryptedReplySheetClosed:returnCode:contextInfo:), (__bridge_retained void *)contextInfo, @"%@", explanation);
	}
}

- (void)warnAboutUnecryptedReplySheetClosed:(NSWindow *)sheet returnCode:(long long)returnCode contextInfo:(void *)contextInfo {
	NSDictionary *_contextInfo = (__bridge_transfer NSDictionary *)contextInfo;
	if(returnCode == NSAlertAlternateReturn) {
		NSMutableArray *checklist = _contextInfo[@"ThingsToCheck"];
		[checklist addObject:kUnencryptedReplyToEncryptedMessage];
		[(MailDocumentEditor *)self sendMessageAfterChecking:checklist];
	}
}


- (void)MASendMessageAfterChecking:(NSMutableArray *)checklist {
	// If this is an unencrypted reply to an encrypted message, display a warning
	// to the user and simply return. The message won't be sent until the checklist is cleared.
	// Otherwise call sendMessageAfterChecking so that Mail.app can perform its internal checks.
	if([self isUnencryptedReplyToEncryptedMessageWithChecklist:checklist]) {
		[self displayWarningForUnencryptedReplyToEncryptedMessageUpdatingChecklist:checklist];
		return;
	}

	[self MASendMessageAfterChecking:checklist];
}

- (void)MABackEnd:(id)backEnd didCancelMessageDeliveryForEncryptionError:(MFError *)error {
	if ([((NSDictionary *)error.userInfo)[@"GPGErrorCode"] integerValue] == GPGErrorCancelled) {
		return;
	}
	[self MABackEnd:backEnd didCancelMessageDeliveryForEncryptionError:error];
}

- (void)MABackEnd:(id)backEnd didCancelMessageDeliveryForError:(MFError *)error {
	if ([((NSDictionary *)error.userInfo)[@"GPGErrorCode"] integerValue] == GPGErrorCancelled) {
		return;
	}
	[self MABackEnd:backEnd didCancelMessageDeliveryForError:error];
}



@end
