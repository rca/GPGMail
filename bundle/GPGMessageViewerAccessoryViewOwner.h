//
//  GPGMessageViewerAccessoryViewOwner.h
//  GPGMail
//
//  Created by Stéphane Corthésy on Mon Sep 16 2002.
//

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

#import <Cocoa/Cocoa.h>
#import <MacGPGME/MacGPGME.h>


@class Message;


enum {
    gpgAuthenticationBanner,
    gpgDecryptionBanner,
    gpgSignatureInfoBanner,
    gpgDecryptedInfoBanner,
    gpgDecryptedSignatureInfoBanner
};


@interface GPGMessageViewerAccessoryViewOwner : NSObject
{
    id						delegate;
    int						bannerType;
    GPGKey *		signatureKey;

    IBOutlet NSView			*authenticationView;
    IBOutlet NSButton		*authenticationButton;

    IBOutlet NSView			*signatureView;
    IBOutlet NSView			*signatureUpperView;
    IBOutlet NSImageView	*signatureIconView;
    IBOutlet NSTextField	*signatureMessageTextField;
    IBOutlet NSButton		*signatureToggleButton;
    IBOutlet NSView			*signatureLowerView;
    IBOutlet NSTextField	*signatureCreationDateTextField;
    IBOutlet NSTextField	*signatureValidityTextField;
    IBOutlet NSTextField	*signatureExpirationDateTextField;
    IBOutlet NSTextField	*signatureBadPolicyAlertTextField;
    IBOutlet NSTextField	*signatureKeyFingerprintTextField;
    BOOL					isSignatureExtraViewVisible;
    IBOutlet NSImageView	*generalAlertIconView;
    IBOutlet NSImageView	*expirationAlertIconView;
    IBOutlet NSImageView	*policyAlertIconView;
    IBOutlet NSImageView	*trustAlertIconView;
    IBOutlet NSPopUpButton	*userIDsPopDownButton;

    IBOutlet NSView			*decryptionView;
    IBOutlet NSButton		*decryptionButton;

    IBOutlet NSView			*decryptedInfoView;
    IBOutlet NSTextField	*decryptedMessageTextField;
    IBOutlet NSImageView	*decryptedIconView;

    IBOutlet NSButton		*disclosureButton;

    BOOL					isMessagePGPSigned;
    BOOL					isMessagePGPEncrypted;
}

- (id) initWithDelegate:(id)delegate;

- (NSView *) view;

- (IBAction) authenticate:(id)sender;
- (IBAction) decrypt:(id)sender;
- (IBAction) toggleSignatureExtraView:(id)sender;

- (void) setBannerType:(int)bannerType;
- (int) bannerType;
- (NSString *)bannerTypeDescription;

- (BOOL) gpgValidateAction:(SEL)anAction;

- (IBAction) gpgAuthenticate:(id)sender;
- (IBAction) gpgDecrypt:(id)sender;

- (BOOL) isMessagePGPEncrypted;
- (BOOL) isMessagePGPSigned;
- (void) messageChanged:(Message *)message;
- (void)printStackTrace:(NSException *)e;

@end

@interface NSObject(GPGMessageViewerAccessoryViewOwnerDelegate)
- (void) gpgAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner replaceViewWithView:(NSView *)view;
#if !defined(SNOW_LEOPARD) && !defined(LEOPARD) && !defined(TIGER)
- (void) gpgAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner showStatusMessage:(NSString *)messageString;
#endif
- (void) gpgAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner displayMessage:(Message *)message isSigned:(BOOL)isSigned;
- (Message *) gpgMessageForAccessoryViewOwner:(GPGMessageViewerAccessoryViewOwner *)owner;
@end
