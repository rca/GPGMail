//
//  MessageHeaderDisplay+GPGMail.m
//  GPGMail
//
//  Created by Lukas Pitschl on 31.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MFError.h>
#import <MimePart.h>
#import <MimeBody.h>
#import <NSAttributedString-FontAdditions.h>
#import <MessageHeaderDisplay.h>
#import <MessageViewingState.h>
#import <NSAlert-MFErrorSupport.h>
#import "CCLog.h"
#import "NSObject+LPDynamicIvars.h"
#import "GPGSignatureView.h"
#import "GPGMailBundle.h"
#import "MimePart+GPGMail.h"
#import "NSAttributedString+GPGMail.h"
#import "MessageHeaderDisplay+GPGMail.h"
#import "MessageContentController+GPGMail.h"

@implementation MessageHeaderDisplay_GPGMail

- (BOOL)MATextView:(id)textView clickedOnLink:(id)link atIndex:(unsigned long long)index {
    if(![link isEqualToString:@"gpgmail://show-signature"] && ![link isEqualToString:@"gpgmail://decrypt"])
        return [self MATextView:textView clickedOnLink:link atIndex:index];
    if([link isEqualToString:@"gpgmail://decrypt"]) {
        [self _decryptMessage];
        return YES;
    }
    if([link isEqualToString:@"gpgmail://show-signature"]) {
        [self _showSignaturePanel];
    }
    return YES;
}

- (void)_showSignaturePanel {
    NSArray *messageSigners = [self getIvar:@"messageSigners"];
    if(![messageSigners count])
        return;
    BOOL notInKeychain = NO;
    for(GPGSignature *signature in messageSigners) {
        if(!signature.userID) {
            notInKeychain = YES;
            break;
        }
    }
    if(notInKeychain) {
        NSBundle *gpgMailBundle = [NSBundle bundleForClass:[GPGMailBundle class]];
        NSString *title = NSLocalizedStringFromTableInBundle(@"MESSAGE_ERROR_ALERT_PGP_VERIFY_NOT_IN_KEYCHAIN_TITLE", @"GPGMail", gpgMailBundle, @"");
        NSString *message = NSLocalizedStringFromTableInBundle(@"MESSAGE_ERROR_ALERT_PGP_VERIFY_NOT_IN_KEYCHAIN_MESSAGE", @"GPGMail", gpgMailBundle, @"");
        
        MFError *error = [MFError errorWithDomain:@"MFMessageErrorDomain" code:1035 localizedDescription:message title:title helpTag:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:title, @"_MFShortDescription", message, @"NSLocalizedDescription", nil]];
        NSAlert *alert = [NSAlert alertForError:error defaultButton:@"OK" alternateButton:nil otherButton:nil];
        [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
        return;
    }
    GPGSignatureView *signatureView = [GPGSignatureView signatureView];
    signatureView.keyList = [[GPGMailBundle sharedInstance] allGPGKeys];
    signatureView.signatures = messageSigners; 
    [signatureView beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        DebugLog(@"Signature panel was closed: %d", result);
    }];
}

- (void)_decryptMessage {
    [[[((MessageHeaderDisplay *)self) parentController] parentController] decryptPGPMessage];
}

- (id)MA_attributedStringForSecurityHeader {
    // This is also called if the message is neither signed nor encrypted.
    // In that case the empty string is returned.
    // Internally this method checks the message's messageFlags
    // to determine if the message is signed or encrypted and
    // based on that information creates the encrypted symbol
    // and calls copySingerLabels on the topLevelPart.
    MessageViewingState *viewingState = [((MessageHeaderDisplay *)self) viewingState];
    MimePart *topPart = [[viewingState mimeBody] topLevelPart];
    // Check if the securityHeader is already set.
    // If so, out of here!
    DebugLog(@"[DEBUG] %s viewingState security string: %@", __PRETTY_FUNCTION__, viewingState.headerSecurityString);
    if(viewingState.headerSecurityString)
        return viewingState.headerSecurityString;
    
    BOOL isPGPSigned = [topPart isPGPSigned];
    BOOL isPGPEncrypted = [topPart isPGPEncrypted];
    BOOL isSigned = [topPart isSigned];
    
    if(!(isPGPSigned || isPGPEncrypted)) {
        // If for example the signature attachment was stripped from the message
        // it still appears as signed, but doesn't have any signature information.
        // In that case, don't show the security header.
        // in that case isSigned is true, but since isPGPSigned checks the number of signers
        // isPGPSigned will be false.
        // Unfortunately Mail.app would still think the message is signed and add
        // the security header which would result in signed being shown.
        // To fix this, the copySigners are checked again.
        NSAttributedString *securityHeader = [NSAttributedString attributedStringWithString:@""];
        if(![(NSArray *)[topPart copySignerLabels] count]) {
            return securityHeader;
        }
        return [self MA_attributedStringForSecurityHeader];
    }
        
    
    // After checking the message flags the top level part is checked for being signed.
    // After that checking if the message is encrypted. If it is, request the decrypted message
    // body and check again if that body is signed.
    char is_encrypted, is_signed;
    MFError *error;
    NSArray *signerLabels = nil; 
    MimeBody *decryptedMessageBody = nil;
    if(isPGPEncrypted) {
        decryptedMessageBody = [topPart decryptedMessageBodyIsEncrypted:&is_encrypted isSigned:&is_signed error:&error];
        MimePart *decryptedTopPart = [decryptedMessageBody topLevelPart];
        // If it's encrypted, only the decrypted part is of interest.
        topPart = decryptedTopPart;
        isPGPSigned = [decryptedTopPart isPGPSigned];
    }
    
    NSMutableAttributedString *securityHeader = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\t%@\t", NSLocalizedStringFromTableInBundle(@"SECURITY_HEADER", @"Encryption", [NSBundle mainBundle], @"")]];
    [securityHeader addAttributes:[NSAttributedString boldGrayHeaderAttributes] range:NSMakeRange(0, [securityHeader length])];
    
    // Add the encrypted part to the security header.
    if(isPGPEncrypted) {
        NSImage *encryptedBadge = decryptedMessageBody ? [NSImage imageNamed:@"decryptedBadge"] : [NSImage imageNamed:@"Encrypted_Glyph"];
        NSAttributedString *encryptAttachmentString = [NSAttributedString attributedStringWithAttachment:[[[NSTextAttachment alloc] init] autorelease] 
                                                                                                   image:encryptedBadge
                                                                                                    link:decryptedMessageBody ? nil : @"gpgmail://decrypt"];
        [securityHeader appendAttributedString:[NSAttributedString attributedStringWithString:@"\t"]];
        [securityHeader appendAttributedString:encryptAttachmentString];
        [securityHeader appendAttributedString:[NSAttributedString attributedStringWithString:NSLocalizedStringFromTableInBundle(@"ENCRYPTED", @"Encryption", [NSBundle mainBundle], @"")]];
    }
    if(isPGPSigned) {
        signerLabels = [topPart copySignerLabels];
        // Set the message signers on the message header display, so they are available
        // for the signature view.
        NSArray *messageSigners = [topPart copyMessageSigners];
        [self setIvar:@"messageSigners" value:messageSigners];
        [messageSigners release];
        NSAttributedString *signedAttachmentString = [NSAttributedString attributedStringWithAttachment:[[[NSTextAttachment alloc] init] autorelease] 
                                                                                                  image:[NSImage imageNamed:@"Signed_Glyph"] 
                                                                                                   link:@"gpgmail://show-signature"];
        // Only add, if message was encrypted.
        if(isPGPEncrypted)
            [securityHeader appendAttributedString:[NSAttributedString attributedStringWithString:@", "]];
        [securityHeader appendAttributedString:signedAttachmentString];
        NSString *signerLabelsString = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedStringFromTableInBundle(@"SIGNED", 
                                                                                                                 @"Alerts", 
                                                                                                                 [NSBundle mainBundle], @""), 
                                        [signerLabels componentsJoinedByString:@", "]];
        [securityHeader appendAttributedString:[NSAttributedString attributedStringWithString:signerLabelsString]];
        [signerLabels release];
    }
    // And last but not least, add a new line.
    [securityHeader appendAttributedString:[NSAttributedString attributedStringWithString:@"\n"]];
    viewingState.headerSecurityString = securityHeader;
    
    return [securityHeader autorelease];
}

@end
