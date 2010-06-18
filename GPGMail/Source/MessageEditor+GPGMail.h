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


#import <MessageEditor.h>

#import <AppKit/NSNibDeclarations.h>


#if defined(SNOW_LEOPARD) || defined(LEOPARD)

#ifdef SNOW_LEOPARD_64
@interface GPGMail_MailDocumentEditor : NSObject
#else
@interface MailDocumentEditor(GPGMail)
#endif
- (IBAction) gpgToggleEncryptionForNewMessage:(id)sender;
- (IBAction) gpgToggleSignatureForNewMessage:(id)sender;
- (IBAction) gpgChoosePublicKeys:(id)sender;
- (IBAction) gpgChoosePersonalKey:(id)sender;
- (IBAction) gpgChoosePublicKey:(id)sender;
- (IBAction) gpgToggleAutomaticPublicKeysChoice:(id)sender;
- (IBAction) gpgToggleSymetricEncryption:(id)sender;
- (IBAction) gpgToggleUsesOnlyOpenPGPStyle:(id)sender;
- (NSArray *) gpgAccessoryViewOwners;
- (void) gpgSetAccessoryViewOwners:(NSArray *)newOwners;
- (BOOL) gpgIsRealEditor;
- (NSToolbar *) gpgToolbar;
- (BOOL) gpgValidateMenuItem:(NSMenuItem *)theItem;
- (BOOL) gpgValidateToolbarItem:(NSToolbarItem *)theItem;
- (NSPopUpButton *) gpgFromPopup;
@end

#else

@interface MessageEditor(GPGMail)

- (IBAction) gpgToggleEncryptionForNewMessage:(id)sender;
- (IBAction) gpgToggleSignatureForNewMessage:(id)sender;
- (IBAction) gpgChoosePublicKeys:(id)sender;
- (IBAction) gpgChoosePersonalKey:(id)sender;
- (IBAction) gpgChoosePublicKey:(id)sender;
- (IBAction) gpgToggleAutomaticPublicKeysChoice:(id)sender;
- (IBAction) gpgToggleSymetricEncryption:(id)sender;
- (IBAction) gpgToggleUsesOnlyOpenPGPStyle:(id)sender;
- (NSArray *) gpgAccessoryViewOwners;
- (void) gpgSetAccessoryViewOwners:(NSArray *)newOwners;
- (BOOL) gpgIsRealEditor;
- (NSToolbar *) gpgToolbar;
- (BOOL) gpgValidateMenuItem:(NSMenuItem *)theItem;
- (BOOL) gpgValidateToolbarItem:(NSToolbarItem *)theItem;
- (NSPopUpButton *) gpgFromPopup;

@end

#endif
