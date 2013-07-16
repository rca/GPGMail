/* GMCodeInjector.m created by Lukas Pitschl (@lukele) on Fri 14-Jun-2013 */

/*
 * Copyright (c) 2000-2013, GPGTools Team <team@gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "CCLog.h"
#import "GPGMail_Prefix.pch"
#import "JRLPSwizzle.h"
#import "GMCodeInjector.h"

@implementation GMCodeInjector

+ (void)injectUsingMethodPrefix:(NSString *)prefix {
	/**
     This method replaces all of Mail's methods which are necessary for GPGMail
     to work correctly.
     
     For each class of Mail that must be extended, a class with the same name
     and suffix _GPGMail (<ClassName>_GPGMail) exists which implements the methods
     to be relaced.
     On runtime, these methods are first added to the original Mail class and
     after that, the original Mail methods are swizzled with the ones of the
     <ClassName>_GPGMail class.
     
     swizzleMap contains all classes and methods which need to be swizzled.
     */
    NSArray *swizzleMap = @[@{@"class": @"MessageHeaderDisplay",
                            @"gpgMailClass": @"MessageHeaderDisplay_GPGMail",
                            @"selectors": @[@"_attributedStringForSecurityHeader",
                             @"textView:clickedOnLink:atIndex:"]},
                           @{@"class": @"ComposeBackEnd",
                            @"gpgMailClass": @"ComposeBackEnd_GPGMail",
                            @"selectors": @[@"_makeMessageWithContents:isDraft:shouldSign:shouldEncrypt:shouldSkipSignature:shouldBePlainText:",
                             @"canEncryptForRecipients:sender:",
                             @"canSignFromAddress:",
                             @"recipientsThatHaveNoKeyForEncryption",
                             @"setEncryptIfPossible:",
                             @"setSignIfPossible:",
                             @"_saveThreadShouldCancel",
                             @"_configureLastDraftInformationFromHeaders:overwrite:",
							 @"sender"]},
                           @{@"class": @"HeadersEditor",
                            @"gpgMailClass": @"HeadersEditor_GPGMail",
                            @"selectors": @[@"securityControlChanged:",
                             @"_updateFromAndSignatureControls:",
                             @"changeFromHeader:",
                             @"dealloc",
                             @"awakeFromNib",
                             @"_updateSignButtonTooltip",
                             @"_updateEncryptButtonTooltip",
							 @"updateSecurityControls",
							 @"_updateSecurityStateInBackgroundForRecipients:sender:"]},
                           @{@"class": @"MailDocumentEditor",
                            @"gpgMailClass": @"MailDocumentEditor_GPGMail",
                            @"selectors": @[@"backEndDidLoadInitialContent:",
                             @"dealloc",
                             //                             @"windowForMailFullScreen",
                             @"backEnd:didCancelMessageDeliveryForEncryptionError:", @"backEnd:didCancelMessageDeliveryForError:"]},
                           @{@"class": @"NSWindow",
                            @"selectors": @[@"toggleFullScreen:"]},
                           @{@"class": @"MessageContentController",
                            @"gpgMailClass": @"MessageContentController_GPGMail",
                            @"selectors": @[@"setMessageToDisplay:"]},
                           @{@"class": @"BannerController",
                            @"gpgMailClass": @"BannerController_GPGMail",
                            @"selectors": @[@"updateBannerForViewingState:"]},
                           // Messages.framework classes. Messages.framework classes can be extended using
                           // categories. No need for a special GPGMail class.
                           @{@"class": @"MimePart",
                            @"selectors": @[@"isEncrypted",
                             @"newEncryptedPartWithData:recipients:encryptedData:",
                             @"newSignedPartWithData:sender:signatureData:",
                             @"verifySignature",
                             @"decodeWithContext:",
                             @"decodeTextPlainWithContext:",
                             @"decodeTextHtmlWithContext:",
                             @"decodeApplicationOctet_streamWithContext:",
                             @"isSigned",
                             @"isMimeSigned",
                             @"isMimeEncrypted",
                             @"usesKnownSignatureProtocol",
                             @"clearCachedDecryptedMessageBody"]},
                           @{@"class": @"MimeBody",
                            @"selectors": @[@"isSignedByMe",
                             @"_isPossiblySignedOrEncrypted"]},
                           @{@"class": @"MessageCriterion",
                            @"selectors": @[@"_evaluateIsDigitallySignedCriterion:",
                             @"_evaluateIsEncryptedCriterion:"]},
                           @{@"class": @"Library",
                            @"gpgMailClass": @"Library_GPGMail",
                            @"selectors": @[@"plistDataForMessage:subject:sender:to:dateSent:dateReceived:dateLastViewed:remoteID:originalMailboxURLString:gmailLabels:flags:mergeWithDictionary:",
                             @"plistDataForMessage:subject:sender:to:dateSent:remoteID:originalMailbox:flags:mergeWithDictionary:"]},
                           @{@"class": @"MailAccount",
                            @"selectors": @[@"accountExistsForSigning"]},
						   @{@"class": @"OptionalView",
							@"gpgMailClass": @"OptionalView_GPGMail",
							@"selectors": @[@"widthIncludingOptionSwitch:"]},
                           @{@"class": @"NSPreferences",
                            @"selectors": @[@"sharedPreferences",
                             @"windowWillResize:toSize:",
                             @"toolbarItemClicked:",
                             @"showPreferencesPanelForOwner:"]}];
	
	NSError *error = nil;
    for(NSDictionary *swizzleInfo in swizzleMap) {
        // If this is a non Messages.framework class, add all methods
        // of the class referenced in gpgMailClass first.
        Class mailClass = NSClassFromString(swizzleInfo[@"class"]);
        if(swizzleInfo[@"gpgMailClass"]) {
            Class gpgMailClass = NSClassFromString(swizzleInfo[@"gpgMailClass"]);
            if(!mailClass) {
                DebugLog(@"WARNING: Class %@ doesn't exist. GPGMail might behave weirdly!", [swizzleInfo objectForKey:@"class"]);
                continue;
            }
            if(!gpgMailClass) {
                DebugLog(@"WARNING: Class %@ doesn't exist. GPGMail might behave weirdly!", [swizzleInfo objectForKey:@"gpgMailClass"]);
                continue;
            }
            [mailClass jrlp_addMethodsFromClass:gpgMailClass error:&error];
            if(error)
                DebugLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
            error = nil;
        }
        for(NSString *method in swizzleInfo[@"selectors"]) {
            error = nil;
            NSString *gpgMethod = [NSString stringWithFormat:@"%@%@%@", prefix, [[method substringToIndex:1] uppercaseString], [method substringFromIndex:1]];
            [mailClass jrlp_swizzleMethod:NSSelectorFromString(method) withMethod:NSSelectorFromString(gpgMethod) error:&error];
            if(error) {
                error = nil;
                // Try swizzling as class method on error.
                [mailClass jrlp_swizzleClassMethod:NSSelectorFromString(method) withClassMethod:NSSelectorFromString(gpgMethod) error:&error];
                if(error)
                    DebugLog(@"[DEBUG] %s Class Error: %@", __PRETTY_FUNCTION__, error);
            }
        }
    }
    
}

@end
