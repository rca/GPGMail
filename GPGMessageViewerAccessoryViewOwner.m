//
//  GPGMessageViewerAccessoryViewOwner.m
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

#import "GPGMessageViewerAccessoryViewOwner.h"
#import "GPGMailBundle.h"
#import "GPGMessageSignature.h"
#import <Message+GPGMail.h>
#import <NSString+Message.h>
#import <NSString+GPGMail.h>


@interface NSView(ColorBackgroundView)
- (void) setTag:(int)tag;
@end

@implementation GPGMessageViewerAccessoryViewOwner

- (id) initWithDelegate:(id)theDelegate
{
    if(self = [self init]){
        delegate = theDelegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesDidChange:) name:GPGPreferencesDidChangeNotification object:[GPGMailBundle sharedInstance]];
    }

    return self;
}

- (NSView *) view
{
    if(authenticationView == nil){
        NSAssert([NSBundle loadNibNamed:@"GPGMessageViewerAccessoryView" owner:self], @"### GPGMail: -[GPGMessageViewerAccessoryViewOwner view]: Unable to load nib named GPGMessageViewerAccessoryView");
        [signatureUpperView retain];
#warning Verify that we no longer need this
#if !defined(LEOPARD) && !defined(TIGER)
        // Very hackish, but we have no other way to retrieve the MessageViewer...
        BOOL    isSingleMessageViewer = ([[[delegate documentView] window] delegate] != nil);
//        BOOL    isSingleMessageViewer = [[[[delegate documentView] window] delegate] isKindOfClass:[NSClassFromString(@"SingleMessageViewer") class]];

        if(!isSingleMessageViewer){
            NSRect  aRect = [authenticationView frame];
            
            aRect.size.height -= 4;
            [authenticationView setFrame:aRect];
            [authenticationView setTag:0];
            aRect = [signatureView frame];
            aRect.size.height -= 4;
            [signatureView setFrame:aRect];
            [signatureView setTag:1];
            aRect = [signatureUpperView frame];
            aRect.size.height -= 4;
            [signatureUpperView setFrame:aRect];
            [signatureUpperView setTag:2];
            aRect = [decryptionView frame];
            aRect.size.height -= 4;
            [decryptionView setFrame:aRect];
            [decryptionView setTag:3];
            aRect = [decryptedInfoView frame];
            aRect.size.height -= 4;
            [decryptedInfoView setFrame:aRect];
            [decryptedInfoView setTag:4];
        }
#endif
        [[disclosureButton cell] setControlSize:NSRegularControlSize];
        [[disclosureButton cell] setBezelStyle:NSDisclosureBezelStyle];
        [[disclosureButton cell] setImage:nil];
        [[disclosureButton cell] setImagePosition:NSNoImage];
        [[disclosureButton cell] setShowsStateBy:NSChangeGrayCellMask | NSChangeBackgroundCellMask];
    }

    switch([self bannerType]){
        case gpgAuthenticationBanner:
            return authenticationView;
        case gpgDecryptionBanner:
            return decryptionView;
        case gpgSignatureInfoBanner:
        case gpgDecryptedSignatureInfoBanner:
            if(isSignatureExtraViewVisible)
                return signatureView;
            else
                return signatureUpperView;
        case gpgDecryptedInfoBanner:
            return decryptedInfoView;
    }

    return nil;
}

- (NSString *)bannerTypeDescription
{
    switch([self bannerType]){
        case gpgAuthenticationBanner:
            return @"Authentication";
        case gpgDecryptionBanner:
            return @"Decryption";
        case gpgSignatureInfoBanner:
            return @"SignatureInfo";
        case gpgDecryptedInfoBanner:
            return @"DecryptedInfo";
        case gpgDecryptedSignatureInfoBanner:
            return @"DecryptedSignatureInfo";
        default:
            return nil;
    }
}

- (void) setBannerType:(int)theBannerType
{
    bannerType = theBannerType;
    if((GPGMailLoggingLevel > 0))
        NSLog(@"[DEBUG] %s => %@", __PRETTY_FUNCTION__, [self bannerTypeDescription]);    
}

- (int) bannerType
{
    return bannerType;
}

- (void) dealloc
{
    [authenticationView release];
    [signatureView release];
    [decryptionView release];
    [signatureUpperView release];
    [decryptedInfoView release];
    [signatureKey release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GPGPreferencesDidChangeNotification object:nil];

    [super dealloc];
}

- (IBAction) toggleSignatureExtraView:(id)sender
{
    if(!isSignatureExtraViewVisible){
        [delegate gpgAccessoryViewOwner:self replaceViewWithView:signatureView];
        [signatureUpperView setFrameOrigin:NSMakePoint(0.0, NSHeight([signatureLowerView frame]))];
        [signatureView addSubview:signatureUpperView];
        [disclosureButton setState:NSOnState];
    }
    else{
        [delegate gpgAccessoryViewOwner:self replaceViewWithView:signatureUpperView];
        [disclosureButton setState:NSOffState];
    }
    isSignatureExtraViewVisible = !isSignatureExtraViewVisible;
    [self setBannerType:gpgSignatureInfoBanner];
}

- (void) fillInUserIDListForKey:(GPGKey *)key
{
    unsigned	aCount = [[userIDsPopDownButton itemArray] count];

    while(aCount-- > 1)
        [userIDsPopDownButton removeItemAtIndex:1];
    if(key){
        NSEnumerator	*anEnum = [[key userIDs] objectEnumerator];
        GPGUserID       *aUserID;
        GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];

        while(aUserID = [anEnum nextObject])
            [userIDsPopDownButton addItemWithTitle:[mailBundle menuItemTitleForUserID:aUserID indent:0]];
    }
}

- (void) loadSignatureInfoViewWithSignature:(GPGSignature *)authenticationSignature
{
    NSCalendarDate	*aDate;
    NSString		*aString;
    NSBundle		*aBundle = [NSBundle bundleForClass:[self class]];
    NSString		*iconName;
    BOOL			hasExtraInfo = YES;
    NSString		*iconToolTip = @"";
    NSArray			*policyURLs = [authenticationSignature policyURLs];
    GPGMailBundle	*mailBundle = [GPGMailBundle sharedInstance];
    BOOL			alertForExpiration = NO;
    BOOL			alertForPolicy = NO;
    BOOL			alertForTrust = NO;
    BOOL			otherAlert = NO;

    [signatureKey release];
    signatureKey = nil;
    aString = [authenticationSignature fingerprint];
    if(aString){
		GPGContext	*aContext = [[GPGContext alloc] init];
		
		@try{
			signatureKey = [[aContext keyFromFingerprint:aString secretKey:NO] retain];
		}@catch(NSException *localException){
			[aContext release];
			[localException raise];
		}
		[aContext release];
    }

    if([authenticationSignature summary] & GPGSignatureSummaryBadPolicyMask){
        aString = NSLocalizedStringFromTableInBundle(@"Bad policy!", @"GPGMail", aBundle, "");
        if([policyURLs count])
            aString = [aString stringByAppendingString:[policyURLs componentsJoinedByString:@", "]];
        alertForPolicy = YES;
    }
    else{
        if([policyURLs count]){
            aString = [NSLocalizedStringFromTableInBundle(@"Policy: ", @"GPGMail", aBundle, "") stringByAppendingString:[policyURLs componentsJoinedByString:@", "]];
            otherAlert = YES;
        }
        else
            aString = @"";
    }
#warning Use setAttributedStringValue: instead, for policy URLs -> clickable
    [signatureBadPolicyAlertTextField setStringValue:aString];
#warning TODO: add support for notations
    
    aDate = [authenticationSignature creationDate];
    if(aDate)
        [signatureCreationDateTextField setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Signed on %@", @"GPGMail", aBundle, ""), [aDate descriptionWithCalendarFormat:NSLocalizedStringFromTableInBundle(@"SIGNATURE_CREATION_DATE_FORMAT", @"GPGMail", aBundle, "") locale:[mailBundle locale]]]];
    else
        [signatureCreationDateTextField setStringValue:NSLocalizedStringFromTableInBundle(@"No signature creation date available", @"GPGMail", aBundle, "")]; // Italicize it?

    [self fillInUserIDListForKey:signatureKey];
    if(signatureKey)
        aString = [signatureKey fingerprint];
    else
        aString = [authenticationSignature fingerprint];
    if([aString length] >= 32){
        aString = [GPGKey formattedFingerprint:aString];
        aString = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Key fingerprint: %@", @"GPGMail", aBundle, ""), aString];
    }
    else{
        if(aString){
            // It's in fact a key ID!
            aString = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Key ID: 0x%@", @"GPGMail", aBundle, ""), aString];
        }
        else
            aString = NSLocalizedStringFromTableInBundle(@"No key fingerprint/ID available", @"GPGMail", aBundle, ""); // Italicize it?
    }
    [signatureKeyFingerprintTextField setStringValue:aString];

    aString = [NSString stringWithFormat:@"Validity=%d", [authenticationSignature validity]];
    [signatureValidityTextField setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Validity: %@", @"GPGMail", aBundle, ""), NSLocalizedStringFromTableInBundle(aString, @"GPGMail", aBundle, "")]];

    aDate = [authenticationSignature expirationDate];
    if(aDate){
        [signatureExpirationDateTextField setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Signature expires on %@", @"GPGMail", aBundle, ""), [aDate descriptionWithCalendarFormat:NSLocalizedStringFromTableInBundle(@"SIGNATURE_EXPIRATION_DATE_FORMAT", @"GPGMail", aBundle, "") locale:[mailBundle locale]]]];
    }
    else{
        [signatureExpirationDateTextField setStringValue:@""];
    }
    // No warning if signature expired after its use; I guess test is useless for mails
//    if([authenticationSignature summary] & GPGSignatureSummarySignatureExpiredMask)
//        alertForExpiration = YES;

    if([authenticationSignature validity] < GPGValidityFull){
        if(![mailBundle trustsAllKeys] || [authenticationSignature validity] != GPGValidityUnknown)
            alertForTrust = YES;
    }

    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] Status: %@,  Summary: 0x%04x, Signer: %@, Signature Date: %@, Expiration Date: %@, Validity: %@, Validity Error: %@, Notations: %@, Policy URLs: %@", GPGErrorDescription([authenticationSignature status]), [authenticationSignature summary], (signatureKey ? [signatureKey userID]:[authenticationSignature fingerprint]), [authenticationSignature creationDate], [authenticationSignature expirationDate], [authenticationSignature validityDescription], GPGErrorDescription([authenticationSignature validityError]), [authenticationSignature notations], [authenticationSignature policyURLs]);

    switch([mailBundle gpgErrorCodeFromError:[authenticationSignature status]]){
        case GPGErrorKeyExpired:
            aDate = [signatureKey expirationDate];
            // Let's consider it an error only if expired key was used for signature
            if([aDate compare:[authenticationSignature creationDate]] <= 0){
                [signatureExpirationDateTextField setStringValue:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Key expired on %@", @"GPGMail", aBundle, ""), [aDate descriptionWithCalendarFormat:NSLocalizedStringFromTableInBundle(@"KEY_EXPIRATION_DATE_FORMAT", @"GPGMail", aBundle, "") locale:[mailBundle locale]]]];
                alertForExpiration = YES;
            }
            // No break here; go on
        case GPGErrorNoError:
        case GPGErrorSignatureExpired: 
            // It's not an error to have an expired signature in a mail, is it?
            // It is an error only if key was expired when making signature
            // TODO: display userID matching sender email?
            // TODO: how to display all userIDs? popup?
            aString = [NSMutableString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Signed by %@.", @"GPGMail", aBundle, ""), [signatureKey userID]];
            iconName = @"gpgSigned";
            iconToolTip = @"SIGNATURE_IS_GOOD";
            break;
        case GPGErrorBadSignature:
            if(signatureKey != nil)
                aString = [NSMutableString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Signature from %@ is bad!", @"GPGMail", aBundle, ""), [signatureKey userID]];
            else
                aString = [NSMutableString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Signature is bad!", @"GPGMail", aBundle, "")];
            iconName = @"gpgUnsigned";
            iconToolTip = @"SIGNATURE_IS_NOT_GOOD";
            break;
        case GPGErrorNoPublicKey:{
            NSArray *fingerprints = [NSArray arrayWithObject:[authenticationSignature fingerprint]];
            NSArray *emails = [NSArray arrayWithObject:[[[delegate gpgMessageForAccessoryViewOwner:self] sender] uncommentedAddress]];
            
            aString = [NSMutableString stringWithFormat:NSLocalizedStringFromTableInBundle(@"MISSING KEY %@.", @"GPGMail", aBundle, ""), [authenticationSignature formattedFingerprint]];
            [[NSNotificationCenter defaultCenter] postNotificationName:GPGMissingKeysNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:fingerprints, @"fingerprints", emails, @"emails", nil]]; // For some key servers, passing the fingerprint does not work, so let's pass the sender's email too
            iconName = @"gpgUnsigned";
            iconToolTip = nil;
            break;
        }
        case GPGErrorGeneralError:
            aString = [NSMutableString stringWithFormat:@"%@: %@", [mailBundle descriptionForError:[authenticationSignature status]], [mailBundle descriptionForError:GPGMakeErrorFromSystemError()]];
            iconName = @"gpgUnsigned";
            iconToolTip = nil;
            break;
        default:
            aString = [NSMutableString stringWithString:[mailBundle descriptionForError:[authenticationSignature status]]];
            NSLog(@"$$$ GPGMail: Summary 0x%04x, status code %u, validity error %d '%@', errno %u '%@'", [authenticationSignature summary], [mailBundle gpgErrorCodeFromError:[authenticationSignature status]], GPGErrorCodeFromError([authenticationSignature validityError]), GPGErrorDescription([authenticationSignature validityError]), GPGErrorCodeFromError(GPGMakeErrorFromSystemError()), GPGErrorDescription(GPGMakeErrorFromSystemError()));
            iconName = @"gpgUnsigned";
            iconToolTip = nil;
    }
    [signatureMessageTextField setStringValue:aString];
    [signatureIconView setImage:[NSImage imageNamed:iconName]];
    [signatureIconView setToolTip:(iconToolTip != nil ? NSLocalizedStringFromTableInBundle(iconToolTip, @"GPGMail", aBundle, ""):nil)];
    [signatureToggleButton setEnabled:hasExtraInfo];
    
    if(alertForTrust || alertForExpiration || alertForPolicy || otherAlert)
        iconName = @"gpgSmallAlert16";
    else
        iconName = @"gpgEmptyImage";
    [generalAlertIconView setImage:[NSImage imageNamed:iconName]];
    if(alertForExpiration)
        iconName = @"gpgSmallAlert12";
    else
        iconName = @"gpgEmptyImage";
    [expirationAlertIconView setImage:[NSImage imageNamed:iconName]];
    if(alertForTrust)
        iconName = @"gpgSmallAlert12";
    else
        iconName = @"gpgEmptyImage";
    [trustAlertIconView setImage:[NSImage imageNamed:iconName]];
    if(alertForPolicy)
        iconName = @"gpgSmallAlert12";
    else
        iconName = @"gpgEmptyImage";
    [policyAlertIconView setImage:[NSImage imageNamed:iconName]];
 
    [signatureToggleButton setState:NSOffState]; // Always closed first
#warning TODO: no information if key has been revoked!
}

- (IBAction) gpgAuthenticate:(id)sender
{
    [authenticationButton performClick:sender];
}

- (IBAction) gpgDecrypt:(id)sender
{
    [decryptionButton performClick:sender];
}

- (IBAction) authenticate:(id)sender
{
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    // TODO: Should be done async, in another thread
#if !defined(LEOPARD) && !defined(TIGER)
    [delegate gpgAccessoryViewOwner:self showStatusMessage:NSLocalizedStringFromTableInBundle(@"AUTHENTICATING", @"GPGMail", [NSBundle bundleForClass:[self class]], "")];
#endif

    @try{
        GPGSignature    *authenticationSignature;
//        BOOL			hasValidSignature;
        
        authenticationSignature = [[delegate gpgMessageForAccessoryViewOwner:self] gpgAuthenticationSignature]; // Can raise an exception
        if(authenticationSignature == nil && [self bannerType] == gpgDecryptedInfoBanner){
        }
        else{
            [self loadSignatureInfoViewWithSignature:authenticationSignature];
            [delegate gpgAccessoryViewOwner:self replaceViewWithView:signatureUpperView];
            [self setBannerType:gpgSignatureInfoBanner];
            isSignatureExtraViewVisible = NO;
            if([[GPGMailBundle sharedInstance] automaticallyShowsAllInfo])
                [self toggleSignatureExtraView:nil];
/*          hasValidSignature = (authenticationSignature != nil && [authenticationSignature validityError] == GPGErrorNoError);
            if(hasValidSignature)
                [message setMessageFlags:[message messageFlags] | 0x00800000];
            else
                [message setMessageFlags:[message messageFlags] & 0xFF7FFFFF];*/
            //[[message messageFlags] setObject:??? forKey:@"GPGAuthenticated"];
        }
    }@catch(NSException *localException){
        NSBeginAlertSheet(NSLocalizedStringFromTableInBundle(@"AUTHENTICATION_TITLE_FAILED", @"GPGMail", [NSBundle bundleForClass:[self class]], ""), nil, nil, nil, [[self view] window], nil, NULL, NULL, NULL, @"%@", [[GPGMailBundle sharedInstance] descriptionForException:localException]);
        //[[message messageFlags] setObject:@"NO" forKey:@"GPGAuthenticated"];
    }

#if !defined(LEOPARD) && !defined(TIGER)
    [delegate gpgAccessoryViewOwner:self showStatusMessage:NSLocalizedStringFromTableInBundle(@"Done.", @"Message", [NSBundle bundleForClass:[Message class]], "")];
#endif
}

- (IBAction) decrypt:(id)sender
{
    if(GPGMailLoggingLevel)
        NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    // TODO: Should be done async, in another thread
    NSMutableArray  *sigs = [NSMutableArray array];
    NSException		*decryptionException = nil, *authenticationException = nil;
    BOOL			decrypted = NO;
    GPGMailBundle   *mailBundle = [GPGMailBundle sharedInstance];

#if !defined(LEOPARD) && !defined(TIGER)
    [delegate gpgAccessoryViewOwner:self showStatusMessage:NSLocalizedStringFromTableInBundle(@"DECRYPTING", @"GPGMail", [NSBundle bundleForClass:[self class]], "")];
#endif
	
    @try{
//        Message	*decryptedMessage = [[delegate gpgMessageForAccessoryViewOwner:self] gpgDecryptedMessageWithPassphraseDelegate:mailBundle signature:(id *)&signature];
        Message	*decryptedMessage = [delegate gpgMessageForAccessoryViewOwner:self];
        [decryptedMessage gpgDecryptMessageWithPassphraseDelegate:mailBundle messageSignatures:sigs];

        if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] Got decrypted message; signatures = %@", sigs);
        NSAssert(decryptedMessage != nil, @"Why is it nil? Which circumstances??"); // Would return nil in case method was called for a message which is not an encrypted one => programmation error
        // Let's support messages which have been signed then encrypted
        if([sigs count] == 0 && [decryptedMessage gpgHasSignature]){ // FIXME: The decryptedMessage we get here is still the original encrypted one -> headers are the encrypted ones, and cannot be the decrypted ones!
#if !defined(LEOPARD) && !defined(TIGER)
            [delegate gpgAccessoryViewOwner:self showStatusMessage:NSLocalizedStringFromTableInBundle(@"AUTHENTICATING", @"GPGMail", [NSBundle bundleForClass:[self class]], "")];
#endif
			
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] Extracting signatures");
            @try{
                GPGSignature    *aSignature = [decryptedMessage gpgEmbeddedAuthenticationSignature]; // Can raise an exception
                
                if(aSignature != nil)
                    [sigs addObject:aSignature];
            }@catch(NSException *localException){
                // Error during verification
                authenticationException = localException;
            }
            if(GPGMailLoggingLevel)
                NSLog(@"[DEBUG] Done");
        }
        else if(GPGMailLoggingLevel)
            NSLog(@"[DEBUG] Not signed");

        if([sigs count] > 0){
            [self loadSignatureInfoViewWithSignature:[sigs objectAtIndex:0]]; // TODO: display all signatures
            [delegate gpgAccessoryViewOwner:self replaceViewWithView:signatureUpperView];
            [self setBannerType:gpgDecryptedSignatureInfoBanner];
        }
        isSignatureExtraViewVisible = NO;
        [delegate gpgAccessoryViewOwner:self displayMessage:decryptedMessage isSigned:([sigs count] > 0)];
    }@catch(NSException *localException){
        decryptionException = localException;
        // Error during decryption
    }

#if !defined(LEOPARD) && !defined(TIGER)
    [delegate gpgAccessoryViewOwner:self showStatusMessage:NSLocalizedStringFromTableInBundle(@"Done.", @"Message", [NSBundle bundleForClass:[Message class]], "")];
#endif
	
    if(decryptionException == nil){
        decrypted = YES;
        if([sigs count] == 0){
#warning OR signature is not a signature... Test signature summary state
            if(authenticationException == nil)
                // Warn user that message was not authenticated
                [decryptedMessageTextField setStringValue:NSLocalizedStringFromTableInBundle(@"DECRYPTED_MSG_NOT_SIGNED", @"GPGMail", [NSBundle bundleForClass:[self class]], "")];
            else
                [decryptedMessageTextField setStringValue:[mailBundle descriptionForException:authenticationException]];
            [decryptedIconView setImage:[NSImage imageNamed:@"gpgUnsigned"]];
            [delegate gpgAccessoryViewOwner:self replaceViewWithView:decryptedInfoView];
            [self setBannerType:gpgDecryptedInfoBanner];
        }
    }
    else{ // Should we use a sheet instead?
        if(![[decryptionException name] isEqualToString:GPGException] || [mailBundle gpgErrorCodeFromError:[[[decryptionException userInfo] objectForKey:GPGErrorKey] unsignedIntValue]] != GPGErrorCancelled){
            // "User canceled" => do not modify view
            [decryptedMessageTextField setStringValue:[mailBundle descriptionForException:decryptionException]];
            [decryptedIconView setImage:[NSImage imageNamed:@"gpgEncrypted"]];
            [delegate gpgAccessoryViewOwner:self replaceViewWithView:decryptedInfoView];
            [self setBannerType:gpgDecryptedInfoBanner];
        }
    }
}

- (void) messageChanged:(Message *)message
{
//    NSLog(@"messageChanged:0x%08x", message);
    if(message != nil){
        isMessagePGPEncrypted = [message gpgIsEncrypted];
        isMessagePGPSigned = [message gpgHasSignature];
    }
    else{
        isMessagePGPEncrypted = NO;
        isMessagePGPSigned = NO;
    }
}

- (BOOL) isMessagePGPEncrypted
{
    return isMessagePGPEncrypted;
}

- (BOOL) isMessagePGPSigned
{
    return isMessagePGPSigned;
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    SEL	anAction = [menuItem action];
    
    if(anAction == @selector(gpgDecrypt:)){
        // Check that there is a selected message in mainWindow, and that message
        // is currently encrypted
        Message	*aMessage = [delegate gpgMessageForAccessoryViewOwner:self];

        if(aMessage != nil){
            return [self isMessagePGPEncrypted];
        }
        else
            return NO;
    }
    else if(anAction == @selector(gpgAuthenticate:)){
        // Check that there is a selected message in mainWindow, and that message
        // is currently signed
        Message	*aMessage = [delegate gpgMessageForAccessoryViewOwner:self];

        if(aMessage != nil){
            /*
            NSMutableDictionary	*aCacheDict = [menuItem representedObject];
            Message				*lastDisplayedMessage = [[aCacheDict objectForKey:@"Message"] nonretainedObjectValue];
            NSNumber			*aNumber = [aCacheDict objectForKey:@"hasSignature"];

            if(!aNumber || lastDisplayedMessage != aMessage){
                if(!aCacheDict)
                    aCacheDict = [NSMutableDictionary dictionary];
                [aCacheDict setObject:[NSValue valueWithNonretainedObject:aMessage] forKey:@"Message"];
                aNumber = [NSNumber numberWithBool:[aMessage gpgHasSignature]];
                [aCacheDict setObject:aNumber forKey:@"hasSignature"];
                [menuItem setRepresentedObject:aCacheDict];
            }
            return [aNumber boolValue];*/
            return [self isMessagePGPSigned];
        }
        else
            return NO;
    }

    return NO;
}

- (BOOL) gpgValidateAction:(SEL)anAction
{
    if(anAction == @selector(gpgDecrypt:))
//        return [self validateMenuItem:[[GPGMailBundle sharedInstance] decryptMenuItem]];
        return [self isMessagePGPEncrypted];
    else if(anAction == @selector(gpgAuthenticate:))
//        return [self validateMenuItem:[[GPGMailBundle sharedInstance] authenticateMenuItem]];
        return [self isMessagePGPSigned];
    else
        return NO;
}

- (void) preferencesDidChange:(NSNotification *)notification
{
    [self fillInUserIDListForKey:signatureKey];
}

@end
