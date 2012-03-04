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

@implementation MailDocumentEditor_GPGMail

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
    
    BOOL shouldEncrypt = [[backEnd getIvar:@"shouldEncrypt"] boolValue];
    BOOL shouldSign = [[backEnd getIvar:@"shouldSign"] boolValue];
    
    GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).guessedSecurityMethod;
    if(((ComposeBackEnd_GPGMail *)backEnd).securityMethod)
        securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).securityMethod;
    
    accessoryView.securityMethod = securityMethod;
    
    if(shouldEncrypt || shouldSign)
        accessoryView.active = YES;
    else
        accessoryView.active = NO;
    
    [[((MailDocumentEditor *)self) headersEditor] fromHeaderDisplaySecretKeys:(securityMethod == GPGMAIL_SECURITY_METHOD_OPENPGP ? YES : NO)];
}

- (void)updateSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod {
    GMSecurityMethodAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    accessoryView.securityMethod = securityMethod;
}

- (void)MABackEndDidLoadInitialContent:(id)content {
    [(NSNotificationCenter *)[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringUpdated:) name:GPGMailKeyringUpdatedNotification object:nil];
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
    
    if(((MailDocumentEditor *)self).isModal || ((MailDocumentEditor *)self).possibleFullScreenViewerParent)
       [accessoryView configureForFullScreenWindow:window];
    else
        [accessoryView configureForWindow:window];
                                                    
    [self setIvar:@"SecurityMethodHintAccessoryView" value:accessoryView];
    [accessoryView release];
}

- (void)hideSecurityMethodAccessoryView {
    GMSecurityMethodAccessoryView *accessoryView = [self getIvar:@"SecurityMethodHintAccessoryView"];
    accessoryView.hidden = YES;
}

- (void)keyringUpdated:(NSNotification *)notification {
    // Reset the security method, since it might change due to the updated keyring.
    ((ComposeBackEnd_GPGMail *)[((MailDocumentEditor *)self) backEnd]).securityMethod = 0;
	[[(MailDocumentEditor *)self headersEditor] updateSecurityControls];
}

- (void)securityMethodAccessoryView:(GMSecurityMethodAccessoryView *)accessoryView didChangeSecurityMethod:(GPGMAIL_SECURITY_METHOD)securityMethod {
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).securityMethod = securityMethod;
    ((ComposeBackEnd_GPGMail *)((MailDocumentEditor *)self).backEnd).userDidChooseSecurityMethod = YES;
    [[(MailDocumentEditor *)self headersEditor] updateSecurityControls];
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

- (void)MABackEnd:(id)arg1 didCancelMessageDeliveryForEncryptionError:(MFError *)error {
	if ([[(NSDictionary *)error.userInfo objectForKey:@"GPGErrorCode"] integerValue] == GPGErrorCancelled) {
		return;
	}
	[self MABackEnd:arg1 didCancelMessageDeliveryForEncryptionError:error];
}

@end
