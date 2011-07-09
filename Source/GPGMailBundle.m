/* GPGMailBundle.m created by dave on Thu 29-Jun-2000 */

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

#import "GPGMailBundle.h"
#import "MessageContentController+GPGMail.h"
#import "MessageViewer+GPGMail.h"
#import "MessageBody+GPGMail.h"
#import "Message+GPGMail.h"
#import "GPGMailPatching.h"

#import <Message.h>
#import <MessageHeaders.h>
#import <MessageBody.h>
#import <NSDataMessageStore.h>
#import <_NSDataMessageStoreMessage.h>
#import <MimeBody.h>
#import <MimePart.h>

#import "MessageEditor+GPGMail.h"
#import "GPG.subproj/GPGPassphraseController.h"
#import "GPG.subproj/GPGProgressIndicatorController.h"
#import "GPGMailPreferences.h"
#import "TableViewManager+GPGMail.h"
#import "GPGKeyDownload.h"
#import "SegmentedToolbarItem.h"
#import "SegmentedToolbarItemSegmentItem.h"

#import <ExceptionHandling/NSExceptionHandler.h>
#import <AppKit/AppKit.h>
#include <mach-o/dyld.h>

#include <Sparkle/Sparkle.h>
#import <AddressBook/AddressBook.h>
#import <Libmacgpg/Libmacgpg.h>
#import "NSSet+Functional.h"

#import "GPGDefaults.h"
#import "JRSwizzle.h"
#import "CCLog.h"
#import "OutgoingMessage.h"
#import "_OutgoingMessageBody.h"
#import "MessageWriter.h"
#import "MutableMessageHeaders.h"
#import "MFKeychainManager.h"
#import "ComposeBackEnd.h"
#import "MVMailBundle.h"
#import "OptionalView.h"
#import "LPDynamicIvars.h"
#import "DocumentEditor.h"

//asm("\t.weak_import _OBJC_CLASS_$_ComposeBackEnd\n");

// The following strings are used as toolbarItem identifiers and userDefault keys (value is the position index)
NSString *GPGAuthenticateMessageToolbarItemIdentifier = @"GPGAuthenticateMessageToolbarItem";
NSString *GPGDecryptMessageToolbarItemIdentifier = @"GPGDecryptMessageToolbarItem";
NSString *GPGSignMessageToolbarItemIdentifier = @"GPGGPGSignMessageToolbarItemIdentifier";
NSString *GPGEncryptMessageToolbarItemIdentifier = @"GPGEncryptMessageToolbarItem";

NSString *GPGKeyListWasInvalidatedNotification = @"GPGKeyListWasInvalidatedNotification";
NSString *GPGPreferencesDidChangeNotification = @"GPGPreferencesDidChangeNotification";
NSString *GPGKeyGroupsChangedNotification = @"GPGKeyGroupsChangedNotification";
NSString *GPGMissingKeysNotification = @"GPGMissingKeysNotification";

NSString *GPGMailException = @"GPGMailException";



int GPGMailLoggingLevel = 1;


static BOOL gpgMailWorks = YES;

@interface NSObject (GPGMailBundle)
// Service implemented by Mail.app
- (void)mailTo:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error;
@end

@interface NSApplication (GPGMailBundle_Revealed)
- (NSArray *)messageEditors;
@end

//@interface GPGEngine (GPGMailBundle_Revealed)
//- (NSString *)debugDescription;
//@end

// If we use bodyWasDecoded:forMessage:, other bundles, like SWUrlification, may
// not have the possibility to modify the body (replacing smileys/URLs with icons)
// If we use bodyWillBeDecoded:forMessage:, we have other problems:
// Problems: called when rebuilding mbox, in another thread => exceptions...
// When new mail is sent, also called in another thread. If we do nothing here, mail is NOT encoded too...
// Plus, decrypted will be indexed.


@interface GPGMailBundle (Private)
- (void)refreshPersonalKeysMenu;
- (void)refreshPublicKeysMenu;
- (void)flushKeyCache:(BOOL)flag;
@end

#include <objc/objc.h>
#include <objc/objc-class.h>

@implementation GPGMail_MessageViewingState

- (BOOL)GPGIsSigned {
    // If MimePart.isSigned is true, Mail calls the _attributedStringForSecurityHeader method,
    // which is used to insert our encryption UI. That's isSigned must be true, even
    // if it's not known yet, whether or not the mime part is really encrypted.
    
    // If this is not a topLevelPart, it's not of interest and the original method return value
    // is returned.
    if([self parentPart] != nil)
        return [self GPGIsSigned];
    
    // This method is often called before it's known whether the part is encrypted
    // or not, therefore the gpgIsMIMEEncrypted is invoked to gather the information.
    [self gpgIsMIMEEncrypted];
    
    // If it is indeed a GPG MIME encrypted message, return YES.
    if([self ivarExists:@"isEncrypted"])
        return YES;
    
    // Otherwise run the original method.
    return [self GPGIsSigned];
}

- (BOOL)GPGIsEncrypted {
    NSLog(@"[DEBUG] %s isEncrypted: %d", __PRETTY_FUNCTION__, [self GPGIsEncrypted]);
    return YES;
}

+ (id)GPGAttributedStringWithAttachment:(NSTextAttachment *)attach {
    NSLog(@"[DEBUG] %s attach: %@", __PRETTY_FUNCTION__, attach);
    NSAttributedString *str = [self GPGAttributedStringWithAttachment:attach];
    NSLog(@"[DEBUG] %s str: %@", __PRETTY_FUNCTION__, str);
    return str;
}

- (struct CGRect)GPGcellFrameForAttachment:(id)arg1 atCharIndex:(long long)arg2 {
    NSLog(@"[DEBUG] %s forAttachment: %@", __PRETTY_FUNCTION__, arg1);
    NSLog(@"[DEBUG] %s atCharIndex: %d", __PRETTY_FUNCTION__, arg2);
    [self GPGcellFrameForAttachment:arg1 atCharIndex:arg2];
}

/**
 * For some stupid reason, it's not easy to make a NSTextAttachment clickable,
 * especially in _attributedStringForSecurityHeader.
 * So the easiest solution is to hijack the SignedTextAttachment, which is used
 * by Mail to display the signature dialog.
 *
 * Using extra ivars the action which should be executed is determined.
 */
- (void)GPG_securityButtonClicked:(id)arg1 {
    NSLog(@"[DEBUG] %s buttonClicked: %@", __PRETTY_FUNCTION__, arg1);
    NSLog(@"[DEBUG] %s gpgAction: %@", __PRETTY_FUNCTION__, [[self delegate] getIvar:@"gpgAction"]);
    NSLog(@"[DEBUG] %s gpgAttachmentRef: %@", __PRETTY_FUNCTION__, [[self delegate] getIvar:@"gpgAttachmentRef"]);
    // Changing the Attachment image to an open keylog works this way, but
    // we need a designer who makes an image for it.
    //[[[[self delegate] getIvar:@"gpgAttachmentRef"] attachmentCell] setImage:[NSImage imageNamed:@"Encryption_Off"]];
    if([[[self delegate] getIvar:@"gpgAction"] isEqualToString:@"decrypt"]) {
        [[[[self delegate] parentController] parentController] gpgDecryptMessage];
        //[[[self delegate] parentController] loadMessageBody];
    }
    [self GPG_securityButtonClicked:arg1]; 
}

- (void)GPGmouseDown:(id)arg1 {
//    NSLog(@"[DEBUG] %s mouseDown: %@", __PRETTY_FUNCTION__, arg1);
//    NSPoint local_point = [self convertPoint:[arg1 locationInWindow] fromView:nil];
//    
    [self GPGmouseDown:arg1];
}


//
//- (id)GPGinitWithAddress:(id)arg1 record:(id)arg2 type:(int)arg3 showComma:(BOOL)arg4 {
//    NSLog(@"[DEBUG] %s address: %@", __PRETTY_FUNCTION__, arg1);
//    NSLog(@"[DEBUG] %s record: %@", __PRETTY_FUNCTION__, arg2);
//    NSLog(@"[DEBUG] %s type: %@", __PRETTY_FUNCTION__, arg3);
//    NSLog(@"[DEBUG] %s show-comma: %d", __PRETTY_FUNCTION__, arg4);
//    return [self GPGinitWithAddress:arg1 record:arg2 type:arg3 showComma:arg4];
////    return  [GPGMailSwizzler originalMethodForName:@"AddressAttachment.initWithAddress:record:type:showComma:"](self, @selector(initWithAddress:record:type:showComma:), 
////                                                                                                               arg1, arg2, arg3, arg4);
//} 

- (id)GPGInit {
    return [self GPGInit];
}

@end

@interface GPGTextAttachmentCell : NSTextAttachmentCell

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView untilMouseUp:(BOOL)flag;

@end

@implementation GPGTextAttachmentCell

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)aView {
    [super highlight:flag withFrame:cellFrame inView:aView];
}

- (void)setAttachment:(NSTextAttachment *)anAttachment {
    NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    [super setAttachment:anAttachment];
}

- (BOOL)wantsToTrackMouse {
    NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    return YES;
}

- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex {
    NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    return [super wantsToTrackMouseForEvent:theEvent inRect:cellFrame ofView:controlView atCharacterIndex:charIndex];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag {
    NSLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    return [super trackMouse:theEvent inRect:cellFrame ofView:aTextView atCharacterIndex:charIndex untilMouseUp:flag];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView untilMouseUp:(BOOL)flag {
    NSLog(@"[DEBUG] %s theEvent: %@", __PRETTY_FUNCTION__, theEvent);
    NSLog(@"[DEBUG] %s ofView: %@", __PRETTY_FUNCTION__, aTextView);
    NSLog(@"[DEBUG] %s untilMousUp: %d", __PRETTY_FUNCTION__, flag);
    return [super trackMouse:theEvent inRect:cellFrame ofView:aTextView untilMouseUp:flag];
}

@end

@implementation GPGMail_MessageHeaderDisplay

- (BOOL)GPGTextView:(id)arg1 clickedOnLink:(id)arg2 atIndex:(unsigned long long)arg3 {
    NSLog(@"[DEBUG] %s textView: %@", __PRETTY_FUNCTION__, arg1);
    NSLog(@"[DEBUG] %s clickedOnLink: %@", __PRETTY_FUNCTION__, arg2);
    NSLog(@"[DEBUG] %s atIndex: %llu", __PRETTY_FUNCTION__, arg3);
    return [self GPGTextView:arg1 clickedOnLink:arg2 atIndex:arg3];
}

- (void)GPG_textView:(id)arg1 clickedOnCell:(id)arg2 event:(id)arg3 inRect:(struct CGRect)arg4 atIndex:(unsigned long long)arg5 {
    NSLog(@"[DEBUG] %s textView: %@", __PRETTY_FUNCTION__, arg1);
    NSLog(@"[DEBUG] %s clickedOnLink: %@", __PRETTY_FUNCTION__, arg2);
    NSLog(@"[DEBUG] %s event: %@", __PRETTY_FUNCTION__, arg3);
    NSLog(@"[DEBUG] %s atIndex: %llu", __PRETTY_FUNCTION__, arg5);
    [self GPG_textView:arg1 clickedOnCell:arg2 event:arg3 inRect:arg4 atIndex:arg5];
}

/**
 * This function is hijacked to simulate the standard S/MIME encryption/signed UI.
 */
- (id)GPG_attributedStringForSecurityHeader {
    // This is also called if the message is neither signed nor encrypted.
    // In that case the empty string is returned.
//    CCLog(@"[DEBUG] %s entering", __PRETTY_FUNCTION__); 
    NSMutableAttributedString *securityHeader = [[self GPG_attributedStringForSecurityHeader] mutableCopy];
    if([securityHeader length] == 0) {
        securityHeader = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\t%@", NSLocalizedStringFromTableInBundle(@"SECURITY_HEADER", @"Encryption", [NSBundle mainBundle], @"")]];
        [securityHeader addAttribute:@"header label" value:@"yes" range:NSMakeRange(0, [securityHeader length])];
        [securityHeader addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0f] range:NSMakeRange(0, [securityHeader length])];
        [securityHeader addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithDeviceRed:0.5f green:0.5f blue:0.5f alpha:1.0f] range:NSMakeRange(0, [securityHeader length])];
        
    }

    // Only add the encrypted attachment if the message is GPG/Mime encrypted.
    if([[[[[self viewingState] message] messageBody] topLevelPart] gpgIsMIMEEncrypted] && 
       [[[[[self viewingState] message] messageBody] topLevelPart] ivarExists:@"isEncrypted"]) {
        //NSLog(@"[DEBUG] %s security header: %@", __PRETTY_FUNCTION__, securityHeader);
        NSFileWrapper *wrapper = [[NSFileWrapper alloc] init];
        [wrapper setIcon:[NSImage imageNamed:@"Encrypted_Glyph"]];
        NSTextAttachment *attachment = [[NSClassFromString(@"SignedTextAttachment") alloc] init];
        [(NSObject *)self setIvar:@"gpgAction" value:@"decrypt"];
        [(NSObject *)self setIvar:@"gpgAttachmentRef" value:attachment];
        [[attachment attachmentCell] setImage:[NSImage imageNamed:@"Encrypted_Glyph"]];
        //GPGTextAttachmentCell *gpgCell = [[GPGTextAttachmentCell alloc] init];
        //NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        //[[attachment attachmentCell] setImage:[NSImage imageNamed:@"Encrypted_Glyph"]];
        /*[gpgCell setImage:[NSImage imageNamed:@"Encrypted_Glyph"]];
        [attachment setAttachmentCell:gpgCell];
        [gpgCell setAttachment:attachment];*/
        NSAttributedString *icon = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *mutableIcon = [icon mutableCopy];
        [mutableIcon addAttribute:NSBaselineOffsetAttributeName 
                     value:[NSNumber numberWithFloat:-1.0]
                     range:NSMakeRange(0,[icon length])];
        NSAttributedString *tab = [[NSAttributedString alloc] initWithString:@"\t"];
        [securityHeader insertAttributedString:tab atIndex:[securityHeader length]];
        [securityHeader insertAttributedString:mutableIcon atIndex:[securityHeader length]];    
        
        [mutableIcon release];
        [wrapper release];
        [attachment release];
        [tab release];
    }
    
    //NSLog(@"[DEBUG] %s security header: %@", __PRETTY_FUNCTION__, securityHeader);
    return securityHeader;
}

@end

@implementation GPGMail_MailNotificationCenter

- (void)GPGPostNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 {
    if(![arg1 isEqualToString:@"NSApplicationDidUpdateNotification"] && 
       ![arg1 isEqualToString:@"NSApplicationDidResignActiveNotification"] &&
       ![arg1 isEqualToString:@"NSApplicationWillUpdateNotification"] &&
       ![arg1 isEqualToString:@"NSWindowDidUpdateNotification"] &&
       ![arg1 isEqualToString:@"NSMouseMovedNotification"] &&
       ![arg1 isEqualToString:@"NSViewDidUpdateTrackingAreasNotification"] &&
       ![arg1 isEqualToString:@"NSWindowDidResignMainNotification"] &&
//       ![arg1 isEqualToString:@"NSViewFrameDidChangeNotification"] &&
       ![arg1 isEqualToString:@"NSTextStorageWillProcessEditingNotification"]) {
        NSLog(@"[DEBUG] %s name: %@", __PRETTY_FUNCTION__, arg1);
        NSLog(@"[DEBUG] %s object: %@", __PRETTY_FUNCTION__, arg2);
        NSLog(@"[DEBUG] %s userInfo: %@", __PRETTY_FUNCTION__, arg3);
    }
    
    [self GPGPostNotificationName:arg1 object:arg2 userInfo:arg3];
}

- (void)GPG_postNotificationWithMangledName:(id)arg1 object:(id)arg2 userInfo:(id)arg3 {
    if(![arg1 isEqualToString:@"NSApplicationDidUpdateNotification"] && 
       ![arg1 isEqualToString:@"NSApplicationDidResignActiveNotification"] &&
       ![arg1 isEqualToString:@"NSApplicationWillUpdateNotification"] &&
       ![arg1 isEqualToString:@"NSWindowDidUpdateNotification"] &&
       ![arg1 isEqualToString:@"NSMouseMovedNotification"] &&
       ![arg1 isEqualToString:@"NSViewDidUpdateTrackingAreasNotification"] &&
       ![arg1 isEqualToString:@"NSWindowDidResignMainNotification"] &&
       //       ![arg1 isEqualToString:@"NSViewFrameDidChangeNotification"] &&
       ![arg1 isEqualToString:@"NSTextStorageWillProcessEditingNotification"]) {
        NSLog(@"[DEBUG] %s name: %@", __PRETTY_FUNCTION__, arg1);
        NSLog(@"[DEBUG] %s object: %@", __PRETTY_FUNCTION__, arg2);
        NSLog(@"[DEBUG] %s userInfo: %@", __PRETTY_FUNCTION__, arg3);
    }
    
    [self GPG_postNotificationWithMangledName:arg1 object:arg2 userInfo:arg3];
}


@end

@implementation GPGMailBundle_WebMessageDocument 

- (id)GPGInitWithMimeBody:(id)arg1 forDisplay:(BOOL)arg2 {
    CCLog(@"[DEBUG] %s Enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s mimeBody: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s forDisplay: %d", __PRETTY_FUNCTION__, arg2);
    id ret = [self GPGInitWithMimeBody:arg1 forDisplay:arg2];
    CCLog(@"[DEBUG] %s exit: %@", __PRETTY_FUNCTION__, ret);
    
    return ret;
}

@end

@implementation GPGMailBundle_ParsedMessage

- (id)GPGInitWithWebArchive:(id)arg1 {
    CCLog(@"[DEBUG] %s Enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s web archive: %@", __PRETTY_FUNCTION__, arg1);
    //CCLog(@"[DEBUG] %s archiveIsMailInternal: %d", __PRETTY_FUNCTION__, arg2);
    id ret = [self GPGInitWithWebArchive:arg1];
    CCLog(@"[DEBUG] %s exit: %@", __PRETTY_FUNCTION__, ret);
    
    return ret;
}

- (id)GPGInitWithWebArchive:(id)arg1 archiveIsMailInternal:(BOOL)arg2 {
    CCLog(@"[DEBUG] %s Enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s web archive: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s archiveIsMailInternal: %d", __PRETTY_FUNCTION__, arg2);
    id ret = [self GPGInitWithWebArchive:arg1 archiveIsMailInternal:arg2];
    CCLog(@"[DEBUG] %s exit: %@", __PRETTY_FUNCTION__, ret);
    
    return ret;
}

+ (id)GPGParsedMessageWithWebArchive:(id)arg1 archiveIsMailInternal:(BOOL)arg2 {
    CCLog(@"[DEBUG] %s Enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s web archive: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s archiveIsMailInternal: %d", __PRETTY_FUNCTION__, arg2);
    id ret = [self GPGParsedMessageWithWebArchive:arg1 archiveIsMailInternal:arg2];
    CCLog(@"[DEBUG] %s exit: %@", __PRETTY_FUNCTION__, ret);
    
    return ret;
}

- (id)GPGInit {
    return [self GPGInit];
}

- (void)GPGSetHtml:(id)arg1 {
    CCLog(@"[DEBUG] %s Enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s html: %@", __PRETTY_FUNCTION__, arg1);
    [self GPGSetHtml:arg1];
}

- (void)GPGAddAttachment:(id)arg1 forURL:(id)arg2 {
    CCLog(@"[DEBUG] %s Enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s attachment: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s forURL: %@", __PRETTY_FUNCTION__, arg2);
    [self GPGAddAttachment:arg1 forURL:arg2];
}

- (void)GPGSetAttachmentsByURL:(id)arg1 {
    CCLog(@"[DEBUG] %s Enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s attachments: %@", __PRETTY_FUNCTION__, arg1);
    [self GPGSetAttachmentsByURL:arg1];
}

@end

@implementation GPGMailBundle_MessageStore

- (void)GPGSetNumberOfAttachments:(unsigned int)arg1 isSigned:(BOOL)arg2 isEncrypted:(BOOL)arg3 forMessage:(id)arg4 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s nr. of attachments: %d", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s isSigned: %d", __PRETTY_FUNCTION__, arg2);
    CCLog(@"[DEBUG] %s isEncrypted: %d", __PRETTY_FUNCTION__, arg3);
    CCLog(@"[DEBUG] %s forMessage: %@", __PRETTY_FUNCTION__, arg4);
    [self GPGSetNumberOfAttachments:arg1 isSigned:arg2 isEncrypted:arg3 forMessage:arg4];
}

- (id)GPG_setOrGetBody:(id)arg1 forMessage:(id)arg2 updateFlags:(BOOL)arg3 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s body: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s forMessage: %@", __PRETTY_FUNCTION__, arg2);
    CCLog(@"[DEBUG] %s updateFlags: %d", __PRETTY_FUNCTION__, arg3);
    id ret = [self GPG_setOrGetBody:arg1 forMessage:arg2 updateFlags:arg3];
    CCLog(@"[DEBUG] %s return value: %@", __PRETTY_FUNCTION__, ret);
    return ret;
}

@end

@implementation GPGMailBundle_NSDataMessageStore

- (id)GPGInitWithData:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:arg1 encoding:NSUTF8StringEncoding]);
    return [self GPGInitWithData:arg1];
}

- (id)GPG_cachedBodyForMessage:(id)arg1 valueIfNotPresent:(id)arg2 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s message: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s valueIfNotPresent: %@", __PRETTY_FUNCTION__, arg2);
    id ret = [self GPG_cachedBodyForMessage:arg1 valueIfNotPresent:arg2];
    CCLog(@"[DEBUG] %s mime body: %@", __PRETTY_FUNCTION__, ret);
    CCLog(@"[DEBUG] %s mime data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:[ret bodyData] encoding:NSUTF8StringEncoding]);
    return ret;
}

@end

@interface GPGMailBundle_BannerController : NSObject

@end

@implementation GPGMailBundle_BannerController

- (void)GPGSendMessage:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] message: %@", arg1);
    [self GPGSendMessage:arg1];
}

@end

@interface GPGMailBundle_ComposeBackEnd : NSObject {
    NSArray *_extraRecipients;
}

//@property (nonatomic, readonly) NSArray *extraRecipients;

@end

@implementation GPGMailBundle_ComposeBackEnd

//@synthesize extraRecipients;

- (void)GPGSetGPGState:(id)sender {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s sender: %@", __PRETTY_FUNCTION__, sender);
    NSInteger state = [(NSButton *)sender state];
    CCLog(@"[DEBUG] %s state: %@", __PRETTY_FUNCTION__, state == NSOnState ? @"Checked" : @"Unchecked");
    [self setIvar:@"GPGEnabled" value:[NSNumber numberWithBool:state == NSOnState]];
}

- (id)GPG_makeMessageWithContents:(id)arg1 isDraft:(BOOL)arg2 shouldSign:(BOOL)arg3 shouldEncrypt:(BOOL)arg4 shouldSkipSignature:(BOOL)arg5 shouldBePlainText:(BOOL)arg6 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] with contents: %@", arg1);
    CCLog(@"[DEBUG] is draft: %d", arg2);
    CCLog(@"[DEBUG] should sign: %d", arg3);
    CCLog(@"[DEBUG] should encrypt: %d", arg4);
    CCLog(@"[DEBUG] should skip signature: %d", arg5);
    CCLog(@"[DEBUG] should be plain text: %d", arg6);
    // The encryption part is a little tricky that's why
    // Mail.app is gonna do the heavy lifting with our GPG encryption method
    // instead of the S/MIME one.
    // After that's done, we only have to extract the encrypted part.
    BOOL shouldGPGEncrypt = NO;
    BOOL shouldGPGSign = NO;
    if([self ivarExists:@"GPGEnabled"] && [[self getIvar:@"GPGEnabled"] boolValue])
        shouldGPGEncrypt = YES;
    OutgoingMessage *outgoingMessage = [self GPG_makeMessageWithContents:arg1 isDraft:arg2 shouldSign:arg3 shouldEncrypt:shouldGPGEncrypt shouldSkipSignature:arg5 shouldBePlainText:arg6];
    // GPG not enabled, or neither encrypt nor sign are checked, let's get the shit out of here.
    if(!shouldGPGEncrypt && !shouldGPGSign)
        return outgoingMessage;
    
    CCLog(@"[DEBUG] Outgoing message: %@", 
          [[NSString alloc] initWithData:[outgoingMessage bodyData] encoding:NSUTF8StringEncoding]);
    CCLog(@"[DEBUG] Encrypted data should be in here?: %@", 
          [[NSString alloc] initWithData:[[outgoingMessage messageBody] rawData] encoding:NSUTF8StringEncoding]);
    // outgoingMessage contains the encrypted part.
    NSData *encryptedData = [[outgoingMessage messageBody] rawData];
    NSString *boundary = [MimeBody newMimeBoundary];
    MessageWriter *messageWriter = [[MessageWriter alloc] init];
    [messageWriter setCreatesMimeAlternatives:YES];
    [messageWriter setCreatesMimeAlternatives:YES];
    [messageWriter setAllows8BitMimeParts:YES];
    [messageWriter setAllowsBinaryMimeParts:YES];
    [messageWriter setAllowsAppleDoubleAttachments:YES];
    // 1. Create the top level part.
    MimePart *topPart = [[MimePart alloc] init];
    [topPart setType:@"multipart"];
    [topPart setSubtype:@"encrypted"];
    [topPart setBodyParameter:@"application/pgp-encrypted" forKey:@"protocol"];
    // It's extremely important to set the boundaries for the parts
    // that need them, otherwise the body data will not be properly generated
    // by appendDataForMimePart.
    [topPart setBodyParameter:boundary forKey:@"boundary"];
    topPart.contentTransferEncoding = @"7bit";
    // 2. Create the first subpart - the version.
    MimePart *versionPart = [[MimePart alloc] init];
    [versionPart setType:@"application"];
    [versionPart setSubtype:@"pgp-encrypted"];
    [versionPart setContentDescription:@"PGP/MIME Versions Identification"];
    versionPart.contentTransferEncoding = @"7bit";
    // 3. Create the pgp data subpart.
    MimePart *dataPart = [[MimePart alloc] init];
    [dataPart setType:@"application"];
    [dataPart setSubtype:@"octet-stream"];
    [dataPart setBodyParameter:@"PGP.asc" forKey:@"name"];
    dataPart.contentTransferEncoding = @"7bit";
    [dataPart setDisposition:@"inline"];
    [dataPart setDispositionParameter:@"PGP.asc" forKey:@"filename"];
    [dataPart setContentDescription:@"Message encrypted with OpenPGP using GPGMail"];
    // 4. Append both parts to the top level part.
    [topPart addSubpart:versionPart];
    [topPart addSubpart:dataPart];
    
    // Again Mail.app will do the heavy lifting for us, only thing we need to do
    // is create a map of mime parts and body data.
    // The problem with that is, mime part can't be used a as a key with
    // a normal NSDictionary, since that wants to copy all keys.
    // So instad we use a CFDictionary which only retains keys.
    NSData *versionData = [@"Version: 1\r\n" dataUsingEncoding:NSASCIIStringEncoding];
    NSRange versionRange = {0, [versionData length]};
    [versionPart setRange:versionRange];
    NSRange dataRange = {0, [encryptedData length]};
    [dataPart setRange:dataRange];
    NSData *topData = [@"This is an OpenPGP/MIME encrypted message (RFC 2440 and 3156)" dataUsingEncoding:NSASCIIStringEncoding];
    NSRange topRange = {0, [topData length]};
    [topPart setRange:topRange];
    
    CFMutableDictionaryRef partBodyMapRef = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    CFDictionaryAddValue(partBodyMapRef, versionPart, versionData);
    CFDictionaryAddValue(partBodyMapRef, dataPart, encryptedData);
    CFDictionaryAddValue(partBodyMapRef, topPart, topData);
    
    NSMutableDictionary *partBodyMap = (NSMutableDictionary *)partBodyMapRef;
    CCLog(@"[DEBUG] %s part body map: %@", __PRETTY_FUNCTION__, partBodyMap);
    CCLog(@"[DEBUG] %s headers: %@", __PRETTY_FUNCTION__, [[outgoingMessage headers] class]);
    CCLog(@"[DEBUG] %s encodedHeadersIncludingFromSpace: %@", __PRETTY_FUNCTION__, [[outgoingMessage headers]encodedHeadersIncludingFromSpace:YES]);
    CCLog(@"[DEBUG] %s encodedHeadersIncludingFromSpace string: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:[[outgoingMessage headers] encodedHeadersIncludingFromSpace:YES] encoding:NSUTF8StringEncoding]);
    // Now on to creating the complete message body.
//    NSData *bodyData = [[NSMutableData alloc] initWithData:[[outgoingMessage headers] encodedHeadersIncludingFromSpace:YES]];
    NSData *bodyData = [[NSMutableData alloc] init];
    [messageWriter appendDataForMimePart:topPart toData:bodyData withPartData:partBodyMap];
    // Now let's see what's in there.
    CCLog(@"[DEBUG] %s body data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding]);
    // So, last step, well... fixing the headers and adding our special GPGMail header.
    MutableMessageHeaders *headers = [outgoingMessage headers];
    [headers setHeader:[[[NSString alloc] initWithFormat:@"multipart/encrypted; protocol=\"application/pgp-encrypted\";\r\n\tboundary=\"%@\"", boundary] dataUsingEncoding:NSUTF8StringEncoding] forKey:@"content-type"];
    [headers setHeader:@"GPGMail 1.4" forKey:@"x-pgp-agent"];
    [headers setHeader:@"7bit" forKey:@"content-transfer-encoding"];
    [headers removeHeaderForKey:@"content-disposition"];
    CCLog(@"[DEBUG] %s headers: %@", __PRETTY_FUNCTION__, headers);
    OutgoingMessage *encryptedOutgoingMessage = [messageWriter newMessageWithBodyData:bodyData headers:headers];
    CCLog(@"[DEBUG] %s body data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:[encryptedOutgoingMessage messageDataIncludingFromSpace:YES] encoding:NSUTF8StringEncoding]);
    CCLog(@"[DEBUG] outgoing message: %d", [encryptedOutgoingMessage retainCount]);
    CCLog(@"[DEBUG] delegate: %@", [self delegate]);
    CCLog(@"[DEBUG] EXIT!");
    
    CCLog(@"[DEBUG] %s what happens here", __PRETTY_FUNCTION__);
    [self setEncryptIfPossible:NO];
//    BackEndFlags *flags = (BackEndFlags *)[self valueForKey:@"_flags"];
//    CCLog(@"[DEBUG] %s encryptIfPossible: %d", flags->encryptIfPossible);
    CCLog(@"[DEBUG] %s and outta here...", __PRETTY_FUNCTION__);
    
    return encryptedOutgoingMessage;
}

- (id)GPGOutgoingMessageUsingWriter:(id)arg1 contents:(id)arg2 headers:(id)arg3 isDraft:(BOOL)arg4 shouldBePlainText:(BOOL)arg5 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s writer: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s contents: %@", __PRETTY_FUNCTION__, arg2);
    CCLog(@"[DEBUG] %s headers: %@", __PRETTY_FUNCTION__, arg3);
    CCLog(@"[DEBUG] %s isDraft: %d", __PRETTY_FUNCTION__, arg4);
    CCLog(@"[DEBUG] %s shouldBePlainText: %d", __PRETTY_FUNCTION__, arg5);
    id outgoingMessage = [self GPGOutgoingMessageUsingWriter:arg1 contents:arg2 headers:arg3 isDraft:arg4 shouldBePlainText:arg5];
    CCLog(@"[DEBUG] %s outgoing message contents: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:[outgoingMessage bodyData] encoding:NSUTF8StringEncoding]);
    return outgoingMessage;
}

- (BOOL)GPGCanEncryptForRecipients:(id)arg1 sender:(id)arg2 {
    CCLog(@"[DEBUG] %s recipients: %@", __PRETTY_FUNCTION__,
          arg1);
    CCLog(@"[DEBUG] %s sender: %@", __PRETTY_FUNCTION__,
          arg2);
    BOOL canEncrypt = [self GPGCanEncryptForRecipients:arg1 sender:arg2];
    CCLog(@"[DEBUG] %s canEncrypt: %d", __PRETTY_FUNCTION__, canEncrypt);
    
    return NO;
    return canEncrypt;
}

- (BOOL)GPGCanSignFromAddress:(id)arg1 {
    CCLog(@"[DEBUG] %s Adress: %@", __PRETTY_FUNCTION__, arg1);
    BOOL canSign = [self GPGCanSignFromAddress:arg1];
    CCLog(@"[DEBUG] %s canSign: %d", __PRETTY_FUNCTION__, canSign);
    return NO;
    return canSign;
}

- (id)GPGRecipientsThatHaveNoKeyForEncryption {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    id ret = [self GPGRecipientsThatHaveNoKeyForEncryption];
    CCLog(@"[DEBUG] %s recipients: %@", __PRETTY_FUNCTION__, ret);
    return ret;
}

- (void)GPGSetSignIfPossible:(BOOL)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s sign: %d", __PRETTY_FUNCTION__, arg1);
    [self GPGSetSignIfPossible:arg1];
}

- (void)GPGSetOriginalMessage:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s original message: %@", __PRETTY_FUNCTION__, arg1);
    [self GPGSetOriginalMessage:arg1];
}

- (void)GPGSetIsUndeliverable:(BOOL)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s is undeliverable: %d", __PRETTY_FUNCTION__, arg1);
    [self GPGSetIsUndeliverable:arg1];
}

@end

@implementation MFKeychainManager (GPGMail)

+ (struct OpaqueSecIdentityRef *)GPGCopySigningIdentityForAddress:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s copySigningIdentityForAddress: %@", __PRETTY_FUNCTION__, arg1);
    return [self GPGCopySigningIdentityForAddress:arg1];
}

+ (struct OpaqueSecCertificateRef *)GPGCopyEncryptionCertificateForAddress:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s copyEncryptionCertificateForAddress: %@", __PRETTY_FUNCTION__, arg1);
    return [self GPGCopyEncryptionCertificateForAddress:arg1];
    
}
+ (BOOL)GPGCanSignMessagesFromAddress:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s can sign: %@", __PRETTY_FUNCTION__, arg1);
    return [self GPGCanSignMessagesFromAddress:arg1];
}
+ (BOOL)GPGCanEncryptMessagesToAddress:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s can encrypt: %@", __PRETTY_FUNCTION__, arg1);
    return [self GPGCanEncryptMessagesToAddress:arg1];
}
+ (BOOL)GPGCanEncryptMessagesToAddresses:(id)arg1 sender:(id)arg2 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s to address: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s sender: %@", __PRETTY_FUNCTION__, arg2);
    return [self GPGCanEncryptMessagesToAddresses:arg1 sender:arg2];
}
+ (struct OpaqueSecPolicyRef *)GPGCopySMIMESigningPolicyForAddress:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s for address: %@", __PRETTY_FUNCTION__, arg1);
    return [self GPGCopySMIMESigningPolicyForAddress:arg1];
    
}
+ (struct OpaqueSecPolicyRef *)GPGCopySMIMEEncryptionPolicyForAddress:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s for address: %@", __PRETTY_FUNCTION__, arg1);
    return [self GPGCopySMIMEEncryptionPolicyForAddress:arg1];
}

@end

@implementation OutgoingMessage (GPGMail)

- (id)GPGInit {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    return [self GPGInit];
}

- (void)GPGSetRawData:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s raw data length: %d", __PRETTY_FUNCTION__, [arg1 length]);
    CCLog(@"[DEBUG] %s raw data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:arg1 encoding:NSUTF8StringEncoding]);
    [self GPGSetRawData:arg1]; 
}

- (void)GPGSetMessageBody:(id)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s message body: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s message body data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:[arg1 rawData] encoding:NSUTF8StringEncoding]);
    [self GPGSetMessageBody:arg1];
}

@end

@implementation MessageWriter (GPGMail)

- (id)GPGNewMessageWithHtmlString:(id)arg1 plainTextAlternative:(id)arg2 otherHtmlStringsAndAttachments:(id)arg3 headers:(id)arg4 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s html string: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s text: %@", __PRETTY_FUNCTION__, arg2);
    CCLog(@"[DEBUG] %s strings and attachments: %@", __PRETTY_FUNCTION__, arg3);
    CCLog(@"[DEBUG] %s headers: %@", __PRETTY_FUNCTION__, arg4);
    return [self GPGNewMessageWithHtmlString:arg1 plainTextAlternative:arg2 otherHtmlStringsAndAttachments:arg3 headers:arg4];
}
- (id)GPGNewMessageWithHtmlString:(id)arg1 attachments:(id)arg2 headers:(id)arg3 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s html string: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s attachments: %@", __PRETTY_FUNCTION__, arg2);
    CCLog(@"[DEBUG] %s headers: %@", __PRETTY_FUNCTION__, arg3);
    return [self GPGNewMessageWithHtmlString:arg1 attachments:arg2 headers:arg3];
}
- (id)GPGNewMessageWithBodyData:(id)arg1 headers:(id)arg2 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s body data: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s body string: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:arg1 encoding:NSUTF8StringEncoding]);
    CCLog(@"[DEBUG] %s headers: %@", __PRETTY_FUNCTION__, arg2);
    return [self GPGNewMessageWithBodyData:arg1 headers:arg2];
}

- (void)GPGAppendDataForMimePart:(id)arg1 toData:(id)arg2 withPartData:(id)arg3 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s mime part: %@", __PRETTY_FUNCTION__, arg1);
    CCLog(@"[DEBUG] %s top level body: %@", __PRETTY_FUNCTION__, [arg1 mimeBody]);
    CCLog(@"[DEBUG] %s top level data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:[[arg1 mimeBody] bodyData] encoding:NSUTF8StringEncoding]);
    
//    CCLog(@"[DEBUG] %s toData length: %d", __PRETTY_FUNCTION__, [arg2 length]);
//    CCLog(@"[DEBUG] %s toData: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:arg2 encoding:NSUTF8StringEncoding]);
//    CCLog(@"[DEBUG] %s toData class: %@", __PRETTY_FUNCTION__, [arg2 class]);
//    CCLog(@"[DEBUG] %s withPartData length: %@", __PRETTY_FUNCTION__, arg3);
//    CCLog(@"[DEBUG] %s withPartData class: %@", __PRETTY_FUNCTION__, [arg3 class]);
    CCLog(@"[DEBUG] %s withPartData keys: %@", __PRETTY_FUNCTION__, [arg3 allKeys]);
    for(id key in [arg3 allKeys]) {
        CCLog(@"[DEBUG] %s part class: %@", __PRETTY_FUNCTION__, [key class]);
        CCLog(@"[DEBUG] %s part hash: %@", __PRETTY_FUNCTION__, [key hash]);
        CCLog(@"[DEBUG] %s subpart body: %@", __PRETTY_FUNCTION__, [key mimeBody]);
        CCLog(@"[DEBUG] %s subpart data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:[[key mimeBody] bodyData] encoding:NSUTF8StringEncoding]);
        
    }
//    CCLog(@"[DEBUG] %s withPartData: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:arg3 encoding:NSUTF8StringEncoding]);
    [self GPGAppendDataForMimePart:arg1 toData:arg2 withPartData:arg3];
    CCLog(@"[DEBUG] %s toData: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:arg2 encoding:NSUTF8StringEncoding]);
}

@end

@implementation _OutgoingMessageBody (GPGMail)

- (id)GPGInit {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    return [self GPGInit];
}

- (void)GPGSetRawData:(id)data {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    CCLog(@"[DEBUG] %s raw data length: %d", __PRETTY_FUNCTION__, [data length]);
    CCLog(@"[DEBUG] %s raw data: %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    return [self GPGSetRawData:data];
}

@end
     
@interface GPGMailBundle_ComposeHeaderView : NSObject
@end

@implementation GPGMailBundle_ComposeHeaderView

- (struct CGRect)GPG_calculateSecurityFrame:(struct CGRect)arg1 {
    if([[self valueForKey:@"_securityOptionalView"] ivarExists:@"securityViewWidth"])
        arg1.size.width = [[[self valueForKey:@"_securityOptionalView"] getIvar:@"securityViewWidth"] floatValue];
    CGRect newRect = [self GPG_calculateSecurityFrame:arg1];
    return newRect;
}

@end

@interface GPGMailBundle_DocumentEditor : NSObject
@end

@implementation GPGMailBundle_DocumentEditor

- (void)GPGPostDocumentEditorDidFinishSetup {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    
    NSLog(@"[DEBUG] %s This should be a back end: %@", __PRETTY_FUNCTION__, ((DocumentEditor *)self).backEnd);
    
    // Get the position of each element in the security optional view
    // and reposition it accordingly.
    OptionalView *securityOptionalView = (OptionalView *)[[self valueForKey:@"_composeHeaderView"] valueForKey:@"_securityOptionalView"];
    
    NSSegmentedControl *lockView = [[securityOptionalView subviews] objectAtIndex:0];
    NSSegmentedControl *signView = [[securityOptionalView subviews] objectAtIndex:1];
    NSRect encryptFrame = [lockView frame];
    NSRect signFrame = [signView frame];
    
    // Creating the NSButton based checkbox.
    NSButton *gpgCheckbox = [[NSButton alloc] initWithFrame:NSMakeRect(0.0f, 2.0f, 0.0f, 0.0f)];
    [gpgCheckbox setButtonType:NSSwitchButton];
    [gpgCheckbox setTitle:@"GPG"];
    [gpgCheckbox setBezelStyle:NSRegularSquareBezelStyle];
    [gpgCheckbox setToolTip:@"Choose whether you want to encrypt the message with OpenPGP or not"];
    [gpgCheckbox setTarget:((DocumentEditor *)self).backEnd];
    [gpgCheckbox setAction:@selector(GPGSetGPGState:)];
    [gpgCheckbox sizeToFit];
    NSLog(@"[DEBUG] %s gpgCheckbox: %@", __PRETTY_FUNCTION__, NSStringFromRect([gpgCheckbox frame]));

//    NSTextField *gpgLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 50.0f, signFrame.size.height)];
//    [gpgLabel setStringValue:@"GPG"];
//    [gpgLabel setBezeled:NO];
//    [gpgLabel setDrawsBackground:NO];
//    [gpgLabel setEditable:NO];
//    [gpgLabel setSelectable:NO];
//    [gpgLabel sizeToFit];
//    [gpgLabel setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
//    
//    
    // 1.) Adjust the frame.
    [lockView setFrameOrigin:NSMakePoint((gpgCheckbox.frame.origin.x + gpgCheckbox.frame.size.width + 4.0f),
                                         0.0f)];
    encryptFrame = [lockView frame];
    // 2.) Adjust the frame.
    [signView setFrame:NSMakeRect(encryptFrame.origin.x + encryptFrame.size.width + 5.0f, -1.0f, signFrame.size.width, signFrame.size.height)];
    signFrame = [signView frame];
    
    [securityOptionalView addSubview:gpgCheckbox];
    [gpgCheckbox release];
    
    NSLog(@"[DEBUG] %s end width: %f", __PRETTY_FUNCTION__, signFrame.origin.x + signFrame.size.width);
    
    [securityOptionalView setIvar:@"securityViewWidth" value:[NSNumber numberWithFloat:signFrame.origin.x + signFrame.size.width]];
    
    [self GPGPostDocumentEditorDidFinishSetup];
}

@end

@interface GPGMailBundle_OptionalView : NSObject
@end

@implementation GPGMailBundle_OptionalView

- (double)GPGWidthIncludingOptionSwitch:(BOOL)arg1 {
    CCLog(@"[DEBUG] %s enter", __PRETTY_FUNCTION__);
    double ret;
    if([self ivarExists:@"securityViewWidth"])
        ret = [[self getIvar:@"securityViewWidth"] floatValue];
    else
        ret = [self GPGWidthIncludingOptionSwitch:arg1];
    CCLog(@"[DEBUG] %s width: %f", __PRETTY_FUNCTION__, ret);
    return ret;
}

@end

@implementation GPGMailBundle

@synthesize cachedPublicGPGKeys, cachedPersonalGPGKeys;

+ (void)load {
	GPGMailLoggingLevel = [[GPGDefaults standardDefaults] integerForKey:@"GPGMailDebug"];
	[[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask:NSLogOtherExceptionMask | NSLogTopLevelExceptionMask];
}

+ (void)addSnowLeopardCompatibility {
	NSLog(@"Adding Snow Leopard Compatibility");

	/* Adding methods for ComposeBackEnd. */
	[GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_ComposeBackEnd") toClass:NSClassFromString(@"ComposeBackEnd")];

	/* Adding methods for HeadersEditor. */
	[GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_HeadersEditor") toClass:NSClassFromString(@"HeadersEditor")];
	/* Adding methods for MailDocumentEditor. */
	[GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MailDocumentEditor") toClass:NSClassFromString(@"MailDocumentEditor")];

	/* Add Methods from GPGMail Message Viewer to Message Viewer. */
	[GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MessageViewer") toClass:NSClassFromString(@"MessageViewer")];

	/* Add methods of GPGMail Message Content Controller to Message Content Controller. */
	[GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MessageContentController") toClass:NSClassFromString(@"MessageContentController")];

	/* Swizzling method for the contextual menu of the table view manager. */
	[GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_TableViewManager") toClass:NSClassFromString(@"TableViewManager")];

	/* Emulate categories for MailTextAttachment. */
	[GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MailTextAttachment") toClass:NSClassFromString(@"MailTextAttachment")];
    
//    [GPGMailSwizzler swizzleMethod:@selector(setHasSetupMessageBody:) fromClass:NSClassFromString(@"MessageContentController") withMethod:@selector(gpgSetHasSetupMessageBody:) ofClass:NSClassFromString(@"MessageContentController")];
//    [GPGMailSwizzler swizzleMethod:@selector(setMessageIDHeaderDigest:) fromClass:NSClassFromString(@"Message") withMethod:@selector(gpgSetMessageIDHeaderDigest:) ofClass:NSClassFromString(@"Message")];
//    [GPGMailSwizzler swizzleMethod:@selector(setSubject:) fromClass:NSClassFromString(@"Message") withMethod:@selector(gpgSetSubject:) ofClass:NSClassFromString(@"Message")];
    //[GPGMailSwizzler swizzleMethod:@selector(setMessageFlags:mask:) fromClass:NSClassFromString(@"Message") withMethod:@selector(gpgSetMessageFlags:mask:) ofClass:NSClassFromString(@"Message")];
    [GPGMailSwizzler swizzleMethod:@selector(decodeWithContext:) fromClass:NSClassFromString(@"MimePart") withMethod:@selector(GPGDecodeWithContext:) ofClass:NSClassFromString(@"MimePart")];
    [GPGMailSwizzler swizzleMethod:@selector(decodeMultipartSignedWithContext:) fromClass:NSClassFromString(@"MimePart") withMethod:@selector(GPGDecodeMultipartSignedWithContext:) ofClass:NSClassFromString(@"MimePart")];
    [GPGMailSwizzler swizzleMethod:@selector(decodeApplicationPkcs7_mimeWithContext:) fromClass:NSClassFromString(@"MimePart") withMethod:@selector(GPGDecodeApplicationPkcs7_mimeWithContext:) ofClass:NSClassFromString(@"MimePart")];
    [GPGMailSwizzler swizzleMethod:@selector(decryptedMessageBodyIsEncrypted:isSigned:error:) fromClass:NSClassFromString(@"MimePart") withMethod:@selector(GPGDecryptedMessageBodyIsEncrypted:isSigned:error:) ofClass:NSClassFromString(@"MimePart")];
    [GPGMailSwizzler swizzleMethod:@selector(setDecryptedMessageBody:isEncrypted:isSigned:error:) fromClass:NSClassFromString(@"MimePart") withMethod:@selector(GPGSetDecryptedMessageBody:isEncrypted:isSigned:error:) ofClass:NSClassFromString(@"MimePart")];
//    [GPGMailSwizzler swizzleMethod:@selector(headerAttributedString) fromClass:NSClassFromString(@"MessageViewingState") withMethod:@selector(GPGMessageHeaderDisplay) ofClass:NSClassFromString(@"GPGMailBundle")];
//    [GPGMailSwizzler swizzleMethod:@selector(initWithAddress:record:type:showComma:) fromClass:NSClassFromString(@"AddressAttachment") withMethod:@selector(GPGinitWithAddress:record:type:showComma:) ofClass:NSClassFromString(@"GPGMailBundle")];
//    NSError *error = nil;
//    [GPGMailBundle jr_swizzleMethod:@selector(finishInitialization) withMethod:@selector(newFinishInitialization) error:&error];
//    NSLog(@"Failed?: %@", error);
//    [error release];
//    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_AddressAttachment") toClass:NSClassFromString(@"AddressAttachment")];
//    error = nil;
//    [NSClassFromString(@"AddressAttachment") jr_swizzleMethod:@selector(initWithAddress:record:type:showComma:) withMethod:@selector(GPGinitWithAddress:record:type:showComma:) error:&error];
//    NSLog(@"Failed?: %@", error);
//    [error release];
    
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MessageViewingState") toClass:NSClassFromString(@"MessageViewingState")];
    NSError *error = nil;
//    [NSClassFromString(@"MessageViewingState") jr_swizzleMethod:@selector(init) withMethod:@selector(GPGInit) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MessageHeaderDisplay") toClass:NSClassFromString(@"MessageHeaderDisplay")];
    [NSClassFromString(@"MessageHeaderDisplay") jr_swizzleMethod:@selector(_attributedStringForSecurityHeader) withMethod:@selector(GPG_attributedStringForSecurityHeader) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"MessageHeaderDisplay") jr_swizzleMethod:@selector(textView:clickedOnLink:atIndex:) withMethod:@selector(GPGTextView:clickedOnLink:atIndex:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"MessageHeaderDisplay") jr_swizzleMethod:@selector(textView:clickedOnCell:event:inRect:atIndex:) withMethod:@selector(GPG_textView:clickedOnCell:event:inRect:atIndex:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    
    [NSClassFromString(@"MimePart") jr_swizzleMethod:@selector(isEncrypted) withMethod:@selector(GPGIsEncrypted) error:&error];
//    [NSClassFromString(@"MimePart") jr_swizzleMethod:@selector(isEncrypted) withMethod:@selector(GPGIsEncrypted) error:&error];
//    [NSClassFromString(@"MimePart") jr_swizzleMethod:@selector(isMimeEncrypted) withMethod:@selector(GPGIsEncrypted) error:&error];
//    [NSClassFromString(@"MimePart") jr_swizzleMethod:@selector(isMimeSigned) withMethod:@selector(GPGIsSigned) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MessageViewingState") toClass:NSClassFromString(@"MessageHeaderView")];
    [NSClassFromString(@"MessageHeaderView") jr_swizzleMethod:@selector(_securityButtonClicked:) withMethod:@selector(GPG_securityButtonClicked:) error:&error];
//    [NSClassFromString(@"MessageHeaderView") jr_swizzleMethod:@selector(mouseDown:) withMethod:@selector(GPGmouseDown:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(decodedContentWithContext:) withMethod:@selector(GPGDecodedContentWithContext:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMail_MailNotificationCenter") toClass:NSClassFromString(@"MailNotificationCenter")];
//    [NSClassFromString(@"MailNotificationCenter") jr_swizzleMethod:@selector(postNotificationName:object:userInfo:) withMethod:@selector(GPGPostNotificationName:object:userInfo:) error:&error];
//    [NSClassFromString(@"MailNotificationCenter") jr_swizzleMethod:@selector(_postNotificationWithMangledName:object:userInfo:) withMethod:@selector(GPG_postNotificationWithMangledName:object:userInfo:) error:&error];
//    [Message jr_swizzleMethod:@selector(messageBodyUpdatingFlags:) withMethod:@selector(GPGMessageBodyUpdatingFlags:) error:&error];
//    [MimePart jr_swizzleMethod:@selector(bodyData) withMethod:@selector(GPGBodyData) error:&error];
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_WebMessageDocument") toClass:NSClassFromString(@"WebMessageDocument")];
//    [NSClassFromString(@"WebMessageDocument") jr_swizzleMethod:@selector(initWithMimeBody:forDisplay:) withMethod:@selector(GPGInitWithMimeBody:forDisplay:) error:&error];
    [GPGMailSwizzler addClassMethodsFromClass:NSClassFromString(@"GPGMailBundle_ParsedMessage") toClass:NSClassFromString(@"ParsedMessage")];
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_ParsedMessage") toClass:NSClassFromString(@"ParsedMessage")];
//    [NSClassFromString(@"ParsedMessage") jr_swizzleMethod:@selector(initWithWebArchive:) withMethod:@selector(GPGInitWithWebArchive:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"ParsedMessage") jr_swizzleMethod:@selector(initWithWebArchive:archiveIsMailInternal:) withMethod:@selector(GPGInitWithWebArchive:archiveIsMailInternal:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"ParsedMessage") jr_swizzleClassMethod:@selector(parsedMessageWithWebArchive:archiveIsMailInternal:) withClassMethod:@selector(GPGParsedMessageWithWebArchive:archiveIsMailInternal:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"ParsedMessage") jr_swizzleMethod:@selector(init) withMethod:@selector(GPGInit) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"ParsedMessage") jr_swizzleMethod:@selector(setHtml:) withMethod:@selector(GPGSetHtml:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"ParsedMessage") jr_swizzleMethod:@selector(addAttachment:forURL:) withMethod:@selector(GPGAddAttachment:forURL:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"ParsedMessage") jr_swizzleMethod:@selector(setAttachmentsByURL:) withMethod:@selector(GPGSetAttachmentsByURL:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MimePart jr_swizzleMethod:@selector(nextSiblingPart) withMethod:@selector(GPGNextSiblingPart) error:&error];
//    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_MessageStore") toClass:NSClassFromString(@"MessageStore")];
//    [NSClassFromString(@"MessageStore") jr_swizzleMethod:@selector(setNumberOfAttachments:isSigned:isEncrypted:forMessage:) withMethod:@selector(GPGSetNumberOfAttachments:isSigned:isEncrypted:forMessage:) error:&error];
//    [NSClassFromString(@"MessageStore") jr_swizzleMethod:@selector(_setOrGetBody:forMessage:updateFlags:) withMethod:@selector(GPG_setOrGetBody:forMessage:updateFlags:) error:&error];
    [MimePart jr_swizzleMethod:@selector(subparts) withMethod:@selector(GPGSubparts) error:&error];
    [MimePart jr_swizzleMethod:@selector(subpartAtIndex:) withMethod:@selector(GPGSubpartAtIndex:) error:&error];
//    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_NSDataMessageStore") toClass:NSClassFromString(@"NSDataMessageStore")];
//    [NSClassFromString(@"NSDataMessageStore") jr_swizzleMethod:@selector(initWithData:) withMethod:@selector(GPGInitWithData:) error:&error];
//    [Message jr_swizzleClassMethod:@selector(messageWithRFC822Data:) withClassMethod:@selector(GPGMessageWithRFC822Data:) error:&error];
    [Message jr_swizzleMethod:@selector(setMessageInfoFromMessage:) withMethod:@selector(GPGSetMessageInfoFromMessage:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(setMessageFlags:mask:) withMethod:@selector(GPGSetMessageFlags:mask:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(messageBody) withMethod:@selector(GPGMessageBody) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(attributedString) withMethod:@selector(GPGAttributedString) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(setIsRead:) withMethod:@selector(GPGSetIsRead:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(messageBodyIfAvailable) withMethod:@selector(GPGMessageBodyIfAvailable) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(messageBodyFetchIfNotAvailable:allowPartial:) withMethod:@selector(GPGMessageBodyFetchIfNotAvailable:allowPartial:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(attributedString) withMethod:@selector(GPGAttributedString) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(allPartsEnumerator) withMethod:@selector(GPGAllPartsEnumerator) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(partWithNumber:) withMethod:@selector(GPGPartWithNumber:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(textHtmlPart) withMethod:@selector(GPGTextHtmlPart) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(topLevelPart) withMethod:@selector(GPGTopLevelPart) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(messageBodyForIndexingAttachments) withMethod:@selector(GPGMessageBodyForIndexingAttachments) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(messageBodyIfAvailableUpdatingFlags:) withMethod:@selector(GPGMessageBodyIfAvailableUpdatingFlags:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(numberOfAttachmentsSigned:encrypted:numberOfTNEFAttachments:) withMethod:@selector(GPGNumberOfAttachmentsSigned:encrypted:numberOfTNEFAttachments:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(decodeIfNecessaryWithContext:) withMethod:@selector(GPGDecodeIfNecessaryWithContext:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(_isPossiblySignedOrEncrypted) withMethod:@selector(GPG_isPossiblySignedOrEncrypted) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(dataForMimePart:) withMethod:@selector(GPGDataForMimePart:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(messageStore) withMethod:@selector(GPGMessageStore) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [NSClassFromString(@"NSDataMessageStore") jr_swizzleMethod:@selector(_cachedBodyForMessage:valueIfNotPresent:) withMethod:@selector(GPG_cachedBodyForMessage:valueIfNotPresent:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(_cachedMessageBody) withMethod:@selector(GPG_cachedMessageBody) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [Message jr_swizzleMethod:@selector(_cachedMessageBodyData) withMethod:@selector(GPG_cachedMessageBodyData) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"MessageContentController") jr_swizzleMethod:@selector(_fetchDataForMessageAndUpdateDisplay:) withMethod:@selector(GPG_fetchDataForMessageAndUpdateDisplay:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"MessageContentController") jr_swizzleMethod:@selector(reloadCurrentMessageShouldReparseBody:) withMethod:@selector(GPGReloadCurrentMessageShouldReparseBody:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"MessageContentController") jr_swizzleMethod:@selector(_displayMessageLoadBody:) withMethod:@selector(GPG_displayMessageLoadBody:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_BannerController") toClass:NSClassFromString(@"BannerController")];
//    [NSClassFromString(@"BannerController") jr_swizzleMethod:@selector(sendMessage:)withMethod:@selector(GPGSendMessage:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_ComposeBackEnd") toClass:NSClassFromString(@"ComposeBackEnd")];
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(_makeMessageWithContents:isDraft:shouldSign:shouldEncrypt:shouldSkipSignature:shouldBePlainText:) withMethod:@selector(GPG_makeMessageWithContents:isDraft:shouldSign:shouldEncrypt:shouldSkipSignature:shouldBePlainText:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MimePart jr_swizzleMethod:@selector(newEncryptedPartWithData:recipients:encryptedData:) withMethod:@selector(GPGNewEncryptedPartWithData:recipients:encryptedData:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(setMimeBody:) withMethod:@selector(GPGSetMimeBody:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [OutgoingMessage jr_swizzleMethod:@selector(setRawData:) withMethod:@selector(GPGSetRawData:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(newSignedPartWithData:sender:signatureData:) withMethod:@selector(GPGNewSignedPartWithData:sender:signatureData:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(_verifySignatureWithCMSDecoder:againstSender:signingError:) withMethod:@selector(GPG_verifySignatureWithCMSDecoder:againstSender:signingError:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(needsSignatureVerification:) withMethod:@selector(GPGNeedsSignatureVerification:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(verifySignature) withMethod:@selector(GPGVerifySignature) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [_OutgoingMessageBody jr_swizzleMethod:@selector(setRawData:) withMethod:@selector(GPGSetRawData:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [_OutgoingMessageBody jr_swizzleMethod:@selector(init) withMethod:@selector(GPGInit) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [OutgoingMessage jr_swizzleMethod:@selector(setMessageBody:) withMethod:@selector(GPGSetMessageBody:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [OutgoingMessage jr_swizzleMethod:@selector(init) withMethod:@selector(GPGInit) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MimePart jr_swizzleMethod:@selector(addSubpart:) withMethod:@selector(GPGAddSubpart:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MimePart jr_swizzleMethod:@selector(setSubtype:) withMethod:@selector(GPGSetSubtype:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(init) withMethod:@selector(GPGInit) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(setTopLevelPart:) withMethod:@selector(GPGSetTopLevelPart:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MessageWriter jr_swizzleMethod:@selector(newMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:) withMethod:@selector(GPGNewMessageWithHtmlString:plainTextAlternative:otherHtmlStringsAndAttachments:headers:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MessageWriter jr_swizzleMethod:@selector(newMessageWithHtmlString:attachments:headers:) withMethod:@selector(GPGNewMessageWithHtmlString:attachments:headers:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MessageWriter jr_swizzleMethod:@selector(newMessageWithBodyData:headers:) withMethod:@selector(GPGNewMessageWithBodyData:headers:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MessageWriter jr_swizzleMethod:@selector(appendDataForMimePart:toData:withPartData:) withMethod:@selector(GPGAppendDataForMimePart:toData:withPartData:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(parseMimeBodyFetchIfNotAvailable:allowPartial:) withMethod:@selector(GPGParseMimeBodyFetchIfNotAvailable:allowPartial:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MimePart jr_swizzleMethod:@selector(parseMimeBody) withMethod:@selector(GPGParseMimeBody) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MimePart jr_swizzleMethod:@selector(bodyParameterForKey:) withMethod:@selector(GPGBodyParameterForKey:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(bodyParameterKeys) withMethod:@selector(GPGBodyParameterKeys) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(bodyConvertedFromFlowedText) withMethod:@selector(GPGBodyConvertedFromFlowedText) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimePart jr_swizzleMethod:@selector(attributedString) withMethod:@selector(GPGAttributedString) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MimeBody jr_swizzleMethod:@selector(dataForMimePart:) withMethod:@selector(GPGDataForMimePart:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MimeBody jr_swizzleClassMethod:@selector(newMimeBoundary) withClassMethod:@selector(GPGNewMimeBoundary) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"MailDocumentEditor") jr_swizzleMethod:@selector(backEnd:didCancelMessageDeliveryForEncryptionError:) withMethod:@selector(GPGBackEnd:didCancelMessageDeliveryForEncryptionError:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(canEncryptForRecipients:sender:) withMethod:@selector(GPGCanEncryptForRecipients:sender:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(canSignFromAddress:) withMethod:@selector(GPGCanSignFromAddress:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(recipientsThatHaveNoKeyForEncryption) withMethod:@selector(GPGRecipientsThatHaveNoKeyForEncryption) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(setSignIfPossible:) withMethod:@selector(GPGSetSignIfPossible:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(setOriginalMessage:) withMethod:@selector(GPGSetOriginalMessage:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(setIsUndeliverable:) withMethod:@selector(GPGSetIsUndeliverable:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MFKeychainManager jr_swizzleClassMethod:@selector(canEncryptMessagesToAddress:) withClassMethod:@selector(GPGCanEncryptMessagesToAddress:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MFKeychainManager jr_swizzleClassMethod:@selector(canEncryptMessagesToAddresses:sender:) withClassMethod:@selector(GPGCanEncryptMessagesToAddresses:sender:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MFKeychainManager jr_swizzleClassMethod:@selector(copySigningIdentityForAddress:) withClassMethod:@selector(GPGCopySigningIdentityForAddress:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MFKeychainManager jr_swizzleClassMethod:@selector(copyEncryptionCertificateForAddress:) withClassMethod:@selector(GPGCopyEncryptionCertificateForAddress:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [MFKeychainManager jr_swizzleClassMethod:@selector(canSignMessagesFromAddress:) withClassMethod:@selector(GPGCanSignMessagesFromAddress:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MFKeychainManager jr_swizzleClassMethod:@selector(copySMIMESigningPolicyForAddress:) withClassMethod:@selector(GPGCopySMIMESigningPolicyForAddress:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
//    [MFKeychainManager jr_swizzleClassMethod:@selector(copySMIMEEncryptionPolicyForAddress:) withClassMethod:@selector(GPGCopySMIMEEncryptionPolicyForAddress:) error:&error];
//    if(error)
//        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [NSClassFromString(@"ComposeBackEnd") jr_swizzleMethod:@selector(outgoingMessageUsingWriter:contents:headers:isDraft:shouldBePlainText:)withMethod:@selector(GPGOutgoingMessageUsingWriter:contents:headers:isDraft:shouldBePlainText:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_ComposeHeaderView") toClass:NSClassFromString(@"ComposeHeaderView")];
    [NSClassFromString(@"ComposeHeaderView") jr_swizzleMethod:@selector(_calculateSecurityFrame:) withMethod:@selector(GPG_calculateSecurityFrame:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_DocumentEditor") toClass:NSClassFromString(@"DocumentEditor")];
    [NSClassFromString(@"DocumentEditor") jr_swizzleMethod:@selector(postDocumentEditorDidFinishSetup) withMethod:@selector(GPGPostDocumentEditorDidFinishSetup) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
    [GPGMailSwizzler addMethodsFromClass:NSClassFromString(@"GPGMailBundle_OptionalView") toClass:NSClassFromString(@"OptionalView")];
    [NSClassFromString(@"OptionalView") jr_swizzleMethod:@selector(widthIncludingOptionSwitch:) withMethod:@selector(GPGWidthIncludingOptionSwitch:) error:&error];
    if(error)
        NSLog(@"[DEBUG] %s Error: %@", __PRETTY_FUNCTION__, error);
}


//- (id)GPGMessageHeaderDisplay {
//    id ret = [GPGMailSwizzler originalMethodForName:@"MessageViewingState.headerAttributedString"](
//                                                                                              self, @selector(headerAttributedString));
//    if(ret) {
//        NSLog(@"[DEBUG] %s %@", __PRETTY_FUNCTION__, ret);
//        NSFont *font = [NSFont fontWithName:@"Palatino-Roman" size:14.0];
//        NSDictionary *attrsDictionary =
//        [NSDictionary dictionaryWithObject:font
//                                    forKey:NSFontAttributeName];
//        NSAttributedString *attrString =
//        [[NSAttributedString alloc] initWithString:@"strigil"
//                                        attributes:attrsDictionary];
//        return attrString;
//    }
//    return ret;
//}

- (id)GPGinitWithAddress:(id)arg1 record:(id)arg2 type:(int)arg3 showComma:(BOOL)arg4 {
    NSLog(@"[DEBUG] %s address: %@", __PRETTY_FUNCTION__, arg1);
    NSLog(@"[DEBUG] %s record: %@", __PRETTY_FUNCTION__, arg2);
    NSLog(@"[DEBUG] %s type: %@", __PRETTY_FUNCTION__, arg3);
    NSLog(@"[DEBUG] %s show-comma: %@", __PRETTY_FUNCTION__, arg4);
    return [GPGMailSwizzler originalMethodForName:@"AddressAttachment.initWithAddress:record:type:showComma:"](self, @selector(initWithAddress:record:type:showComma:), 
                                                                                                        arg1, arg2, arg3, arg4);
}


+ (void)GPGGetRecordsForAddresses:(id)arg1 {
    [GPGMailSwizzler originalMethodForName:@"AddressAttachment.getRecordsForAddresses:"](
                                                                                          self, @selector(getRecordsForAddresses:), arg1);

}

+ (void)initialize {
	static BOOL initialized = NO;

	if (initialized) {
		return;
	}
	initialized = YES;


	if (class_getSuperclass([self class]) != NSClassFromString(@"MVMailBundle")) {
		[super initialize];

		Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
		if (mvMailBundleClass) {
			// use class_addMethod and method_setImplementation instead
			class_setSuperclass([self class], mvMailBundleClass); 
		}

		[GPGMailBundle addSnowLeopardCompatibility];
	}
	NSBundle *myBundle = [NSBundle bundleForClass:self];
    
	// Do not call super - see +initialize documentation



	// We need to load images and name them, because all images are searched by their name; as they are not located in the main bundle,
	// +[NSImage imageNamed:] does not find them.
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"encrypted"]] setName:@"gpgEncrypted"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"clear"]] setName:@"gpgClear"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"signed"]] setName:@"gpgSigned"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"unsigned"]] setName:@"gpgUnsigned"];

	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"GPGMail"]] setName:@"GPGMail"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"MacGPG"]] setName:@"MacGPG"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"GPGMail32"]] setName:@"GPGMail32"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"GPGMailPreferences"]] setName:@"GPGMailPreferences"];

	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"questionMark"]] setName:@"gpgQuestionMark"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"SmallAlert12"]] setName:@"gpgSmallAlert12"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"SmallAlert16"]] setName:@"gpgSmallAlert16"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"EmptyImage"]] setName:@"gpgEmptyImage"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"ValidBadge"]] setName:@"gpgValidBadge"];
	[(NSImage *)[[NSImage alloc] initByReferencingFile:[myBundle pathForImageResource:@"InvalidBadge"]] setName:@"gpgInvalidBadge"];

	// Do NOT release images!


	[self registerBundle];             // To force registering composeAccessoryView and preferences

	NSLog(@"Loaded GPGMail %@", [(GPGMailBundle *)[self sharedInstance] version]);

	SUUpdater *updater = [SUUpdater updaterForBundle:[NSBundle bundleForClass:[self class]]];
	updater.delegate = [self sharedInstance];
	// [updater setAutomaticallyChecksForUpdates:YES];
	[updater resetUpdateCycle];
#warning Sparkle should automatically start to check, but sometimes doesn't.
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater {
	return @"/Applications/Mail.app";
}

+ (BOOL)hasPreferencesPanel {
	return gpgMailWorks;             // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle
}

+ (NSString *)preferencesOwnerClassName {
	return NSStringFromClass([GPGMailPreferences class]);
}

+ (NSString *)preferencesPanelName {
	return NSLocalizedStringFromTableInBundle(@"PGP_PREFERENCES", @"GPGMail", [NSBundle bundleForClass:self], "PGP preferences panel name");
}

+ (BOOL)gpgMailWorks {
	return gpgMailWorks;
}

- (BOOL)gpgMailWorks {
	return gpgMailWorks;
}

- (NSMenuItem *)newMenuItemWithTitle:(NSString *)title action:(SEL)action andKeyEquivalent:(NSString *)keyEquivalent inMenu:(NSMenu *)menu relativeToItemWithSelector:(SEL)selector offset:(int)offset {
// Taken from /System/Developer/Examples/EnterpriseObjects/AppKit/ModelerBundle/EOUtil.m

	// Simple utility category which adds a new menu item with title, action
	// and keyEquivalent to menu (or one of its submenus) under that item with
	// selector as its action.  Returns the new addition or nil if no such
	// item could be found.

	NSMenuItem *menuItem;
	NSArray *items = [menu itemArray];
	int iI;

	if (!keyEquivalent) {
		keyEquivalent = @"";
	}

	for (iI = 0; iI < [items count]; iI++) {
		menuItem = [items objectAtIndex:iI];

		if ([menuItem action] == selector) {
			return ([[menu insertItemWithTitle:title action:action keyEquivalent:keyEquivalent atIndex:iI + offset] retain]);
		} else if ([[menuItem target] isKindOfClass:[NSMenu class]]) {
			menuItem = [self newMenuItemWithTitle:title action:action andKeyEquivalent:keyEquivalent inMenu:[menuItem target] relativeToItemWithSelector:selector offset:offset];
			if (menuItem) {
				return menuItem;
			}
		}
	}

	return nil;
}

- (void)setPGPMenu:(NSMenu *)pgpMenu {
	if (gpgMailWorks) {
		pgpMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_MENU", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP> submenu title") action:NULL andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(addSenderToAddressBook:) offset:1];

		if (!pgpMenuItem) {
			NSLog(@"### GPGMail: unable to add submenu <PGP>");
		} else {
			[[pgpMenuItem menu] insertItem:[NSMenuItem separatorItem] atIndex:[[pgpMenuItem menu] indexOfItem:pgpMenuItem]];
			[[pgpMenuItem menu] setSubmenu:pgpMenu forItem:pgpMenuItem];
			[encryptsNewMessageMenuItem setState:NSOffState];
			[signsNewMessageMenuItem setState:([self alwaysSignMessages] ? NSOnState:NSOffState)];
			[pgpMenuItem retain];
			[self refreshPersonalKeysMenu];
			[self refreshPublicKeysMenu];
#warning CHECK: keys not synced with current editor?
		}
	}
}

- (void)refreshKeyIdentifiersDisplayInMenu:(NSMenu *)menu {
	NSArray *displayedKeyIdentifiers = [self displayedKeyIdentifiers];
	int i = 1;

    for (NSString *anIdentifier in [self allDisplayedKeyIdentifiers]) {
		if (![displayedKeyIdentifiers containsObject:anIdentifier]) {
			[[menu itemWithTag:i] setState:NSOffState];
		} else {
			[[menu itemWithTag:i] setState:NSOnState];
		}
		i++;
	}
}

- (void)setPGPViewMenu:(NSMenu *)pgpViewMenu {
	if (gpgMailWorks) {
		SEL targetSelector;

		targetSelector = @selector(toggleThreadedMode:);
		pgpViewMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_KEYS_MENU", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP Keys> submenu title") action:NULL andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:targetSelector offset:-1];

		if (!pgpViewMenuItem) {
			NSLog(@"### GPGMail: unable to add submenu <PGP Keys>");
		} else {
			NSMenu *aMenu = [pgpViewMenuItem menu];
/*            int		anIndex = [aMenu indexOfItem:pgpViewMenuItem];
 *
 *          [pgpViewMenuItem retain];
 *          while(--anIndex > 0)
 *              if([[aMenu itemAtIndex:anIndex] isSeparatorItem])
 *                  break;
 *          if(anIndex > 0){
 *              [aMenu removeItem:pgpViewMenuItem];
 *              [aMenu insertItem:pgpViewMenuItem atIndex:anIndex];
 *          }*/
			[aMenu setSubmenu:pgpViewMenu forItem:pgpViewMenuItem];

			[self refreshKeyIdentifiersDisplayInMenu:pgpViewMenu];
		}
	}
}

#pragma mark Toolbar stuff (+contextual menu)

- (id)realDelegateForToolbar:(NSToolbar *)toolbar {
// #warning This won't work if other controller usurps delegate!
//    if([toolbar delegate] != self){
	if (![[toolbar delegate] isKindOfClass:NSClassFromString(@"MVMailBundle")]) {
		[realToolbarDelegates removeObjectForKey:[NSValue valueWithNonretainedObject:toolbar]];
		return nil;
	} else {
		return [[realToolbarDelegates objectForKey:[NSValue valueWithNonretainedObject:toolbar]] nonretainedObjectValue];
	}
}

- (void)addAdditionalContextualMenuItemsToMessageViewer:(MessageViewer *)viewer {
	NSMenu *menu = [[viewer gpgTableManager] gpgContextualMenu];
	NSMenu *pgpMenu = [[self encryptsNewMessageMenuItem] menu];
	NSMenuItem *newMenuItem;

	// We need to take care of not adding items more than once!
	// WARNING Hardcoded dependency on menu item order in PGP menu
	newMenuItem = [pgpMenu itemAtIndex:0];
	if ([menu indexOfItemWithTitle:[newMenuItem title]] == -1) {
		newMenuItem = [NSMenuItem separatorItem];
		[menu addItem:newMenuItem];
		newMenuItem = [[pgpMenu itemAtIndex:0] copyWithZone:[menu zone]];
		[newMenuItem setKeyEquivalent:@""];
		[menu addItem:newMenuItem];
		[newMenuItem release];
		newMenuItem = [[pgpMenu itemAtIndex:1] copyWithZone:[menu zone]];
		[newMenuItem setKeyEquivalent:@""];
		[menu addItem:newMenuItem];
		[newMenuItem release];
	}
}

- (id)usurpToolbarDelegate:(NSToolbar *)toolbar {
	NSArray *additionalIdentifiers = [additionalToolbarItemIdentifiersPerToolbarIdentifier objectForKey:[toolbar identifier]];
	id realDelegate = [toolbar delegate];

	if (realDelegate == nil) {
		NSLog(@"### GPGMail: toolbar %@ has no delegate!", [toolbar identifier]);
		return nil;
	}

	if (additionalIdentifiers != nil && [additionalIdentifiers count] > 0) {
		if ([realDelegate isKindOfClass:NSClassFromString(@"MessageViewer")]) {
			[self addAdditionalContextualMenuItemsToMessageViewer:realDelegate];
		}
		// In case other bundles usurp delegation too, they probably do it my way ;-)
		else if ([realDelegate respondsToSelector:@selector(realDelegateForToolbar:)]) {
			id usurpedDelegate = [realDelegate realDelegateForToolbar:toolbar];
			if ([usurpedDelegate isKindOfClass:NSClassFromString(@"MessageViewer")]) {
				[self addAdditionalContextualMenuItemsToMessageViewer:usurpedDelegate];
			}
		}
		[realToolbarDelegates setObject:[NSValue valueWithNonretainedObject:realDelegate] forKey:[NSValue valueWithNonretainedObject:toolbar]];
		[toolbar setDelegate:self];

		return realDelegate;
	} else {
		// No usurpation if no item added...
		return nil;
	}
}

- (NSToolbarItem *)createToolbarItemWithItemIdentifier:(NSString *)itemIdentifier label:(NSString *)label altLabel:(NSString *)altLabel paletteLabel:(NSString *)paletteLabel tooltip:(NSString *)tooltip target:(id)target action:(SEL)action imageNamed:(NSString *)imageName forToolbar:(NSToolbar *)toolbar {
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	SegmentedToolbarItem *anItem = [[NSClassFromString(@"SegmentedToolbarItem") alloc] initWithItemIdentifier:itemIdentifier];

	// By default has already one segment - no need to create it
	[[[anItem subitems] objectAtIndex:0] setImage:[NSImage imageNamed:imageName]];
	[anItem setLabel:NSLocalizedStringFromTableInBundle(label, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setAlternateLabel:NSLocalizedStringFromTableInBundle(altLabel, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setPaletteLabel:NSLocalizedStringFromTableInBundle(paletteLabel, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setToolTip:NSLocalizedStringFromTableInBundle(tooltip, @"GPGMail", myBundle, "") forSegment:0];
	[anItem setTag:-1 forSegment:0];
	[anItem setTarget:target forSegment:0];
	[anItem setAction:action forSegment:0];

	return [anItem autorelease];
}

- (BOOL)itemForItemIdentifier:(NSString *)itemIdentifier alreadyInToolbar:(NSToolbar *)toolbar {
    for (NSToolbarItem *anItem in [toolbar items]) {
		if ([[anItem itemIdentifier] isEqualToString:itemIdentifier] && ![anItem allowsDuplicatesInToolbar]) {
			return YES;
		}
    }
	return NO;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	// IMPORTANT: we need to give, as altLabel, the largest label we can have!
	if ([itemIdentifier isEqualToString:GPGDecryptMessageToolbarItemIdentifier]) {
		return [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"DECRYPT_ITEM" altLabel:@"" paletteLabel:@"DECRYPT_ITEM" tooltip:@"DECRYPT_ITEM_TOOLTIP" target:self action:@selector(gpgDecrypt:) imageNamed:@"gpgClear" forToolbar:toolbar];
	} else if ([itemIdentifier isEqualToString:GPGAuthenticateMessageToolbarItemIdentifier]) {
		return [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"AUTHENTICATE_ITEM" altLabel:@"" paletteLabel:@"AUTHENTICATE_ITEM" tooltip:@"AUTHENTICATE_ITEM_TOOLTIP" target:self action:@selector(gpgAuthenticate:) imageNamed:@"gpgSigned" forToolbar:toolbar];
	} else if ([itemIdentifier isEqualToString:GPGEncryptMessageToolbarItemIdentifier]) {
		// (We cannot use responder chain mechanism, because MessageEditor class does not cooperate...)
		NSToolbarItem *newItem;

		if ([self buttonsShowState]) {
			newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"ENCRYPTED_ITEM" altLabel:@"CLEAR_ITEM" paletteLabel:@"ENCRYPTED_ITEM" tooltip:@"ENCRYPTED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleEncryptionForNewMessage:) imageNamed:@"gpgEncrypted" forToolbar:toolbar];                                                      // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner
		} else {
			newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"MAKE_ENCRYPTED_ITEM" altLabel:@"MAKE_CLEAR_ITEM" paletteLabel:@"MAKE_ENCRYPTED_ITEM" tooltip:@"MAKE_ENCRYPTED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleEncryptionForNewMessage:) imageNamed:@"gpgClear" forToolbar:toolbar];                                      // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner

		}
		return newItem;
	} else if ([itemIdentifier isEqualToString:GPGSignMessageToolbarItemIdentifier]) {
		// (We cannot use responder chain mechanism, because MessageEditor class does not cooperate...)
		NSToolbarItem *newItem;

		if ([self buttonsShowState]) {
			newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"SIGNED_ITEM" altLabel:@"UNSIGNED_ITEM" paletteLabel:@"SIGNED_ITEM" tooltip:@"SIGNED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleSignatureForNewMessage:) imageNamed:@"gpgSigned" forToolbar:toolbar];                                                            // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner
		} else {
			newItem = [self createToolbarItemWithItemIdentifier:itemIdentifier label:@"MAKE_SIGNED_ITEM" altLabel:@"MAKE_UNSIGNED_ITEM" paletteLabel:@"MAKE_SIGNED_ITEM" tooltip:@"MAKE_SIGNED_ITEM_TOOLTIP" target:self action:@selector(gpgToggleSignatureForNewMessage:) imageNamed:@"gpgUnsigned" forToolbar:toolbar];                                      // label, tooltip and image will be updated by GPGMailComposeAccessoryViewOwner

		}
		return newItem;
	} else {
		return [[self realDelegateForToolbar:toolbar] toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
	}
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return [[self realDelegateForToolbar:toolbar] toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	NSArray *additionalIdentifiers = [additionalToolbarItemIdentifiersPerToolbarIdentifier objectForKey:[toolbar identifier]];

	if (additionalIdentifiers != nil) {
		NSMutableArray *identifiers = [NSMutableArray arrayWithArray:[[self realDelegateForToolbar:toolbar] toolbarAllowedItemIdentifiers:toolbar]];
       
        [identifiers addObjectsFromArray:additionalIdentifiers];
		return identifiers;
	} else {
		return [[self realDelegateForToolbar:toolbar] toolbarAllowedItemIdentifiers:toolbar];
	}
}

- (void)toolbarWillAddItem:(NSNotification *)notification notifyRealDelegate:(BOOL)notifyRealDelegate {
	NSToolbar *toolbar = [notification object];

	if (notifyRealDelegate) {
		id realDelegate = [self realDelegateForToolbar:toolbar];

		if ([realDelegate respondsToSelector:@selector(toolbarWillAddItem:)]) {
			[realDelegate performSelector:@selector(toolbarWillAddItem:) withObject:notification];
		}
	}
}

- (void)anyToolbarWillAddItem:(NSNotification *)notification {
	NSToolbar *toolbar = [notification object];
	id realDelegate = [self realDelegateForToolbar:toolbar];

	if (realDelegate == nil) {
		realDelegate = [self usurpToolbarDelegate:toolbar];                         // Can fire notification!
		if (realDelegate != nil) {
			[self toolbarWillAddItem:notification notifyRealDelegate:NO];
		}
	}
}

- (void)toolbarWillAddItem:(NSNotification *)notification {
	// Called automatically by toolbar we are the delegate of
	[self toolbarWillAddItem:notification notifyRealDelegate:YES];
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification {
	// Called automatically by toolbar we are the delegate of
	// Update userDefaults
	NSToolbar *toolbar = [notification object];
	id realDelegate = [self realDelegateForToolbar:toolbar];
	NSString *itemIdentifier = [[[notification userInfo] objectForKey:@"item"] itemIdentifier];
	NSArray *additionalIdentifiers = [additionalToolbarItemIdentifiersPerToolbarIdentifier objectForKey:[toolbar identifier]];

	// WARNING: check whether it was a duplicate item!
	if ([additionalIdentifiers containsObject:itemIdentifier]) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[itemIdentifier stringByAppendingFormat:@".%@", [toolbar identifier]]];
	}
	if ([realDelegate respondsToSelector:_cmd]) {
		[realDelegate performSelector:_cmd withObject:notification];
	}
}

- (void)refreshPersonalKeysMenu {
	GPGKey *theDefaultKey = [self defaultKey];
	NSMenu *aSubmenu = [personalKeysMenuItem submenu];
	NSMenuItem *anItem;
	BOOL displaysAllUserIDs = [self displaysAllUserIDs];

    
    [aSubmenu removeAllItems];

    NSLog(@"Personal Keys: %@", [self personalKeys]);
    
    for (GPGKey *aKey in [self personalKeys]) {
		NSString *title = [self menuItemTitleForKey:aKey];
        anItem = [aSubmenu addItemWithTitle:title action:@selector(gpgChoosePersonalKey:) keyEquivalent:@""];
        [anItem setRepresentedObject:aKey];
		[anItem setTarget:self];
		if (![self canKeyBeUsedForSigning:aKey]) {
			[anItem setEnabled:NO];
		}
        if (theDefaultKey && [aKey isEqual:theDefaultKey]) {
            [anItem setState:NSMixedState];
        }
		if (displaysAllUserIDs) {
            for (GPGUserID *aUserID in [self secondaryUserIDsForKey:aKey]) {
				anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
				[anItem setEnabled:NO];
			}
		}
	}
}

- (void)refreshPublicKeysMenu {
	DebugLog(@"[DEBUG] %s", __PRETTY_FUNCTION__);
    NSMenu *aSubmenu = [choosePublicKeysMenuItem menu];
    GPGKey *theDefaultKey = [self publicKeyForSecretKey:[self defaultKey]];
    NSMenuItem *anItem;

    NSUInteger count = [[aSubmenu itemArray] count];
    for (; count > GPGENCRYPTION_MENU_ITEMS_COUNT; count--) {
        [aSubmenu removeItemAtIndex:GPGENCRYPTION_MENU_ITEMS_COUNT];
    }
    
	if ([self encryptsToSelf] && theDefaultKey) {
		anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForKey:theDefaultKey] action:NULL keyEquivalent:@""];
        [anItem setEnabled:[self canKeyBeUsedForEncryption:theDefaultKey]];
        
		if ([self displaysAllUserIDs]) {
            for (GPGUserID *aUserID in [self secondaryUserIDsForKey:theDefaultKey]) {
				anItem = [aSubmenu addItemWithTitle:[self menuItemTitleForUserID:aUserID indent:1] action:NULL keyEquivalent:@""];
				[anItem setEnabled:NO];
			}
		}
	}
}

- (void)checkPGPmailPresence {
	if (![self ignoresPGPPresence]) {
		if (NSClassFromString(@"PGPMailBundle") != Nil) {
			NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
			NSString *errorTitle = NSLocalizedStringFromTableInBundle(@"GPGMAIL_VS_PGPMAIL", @"GPGMail", myBundle, "");
			NSString *errorMessage = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"GPGMAIL_%@_VS_PGPMAIL_%@", @"GPGMail", myBundle, ""), [myBundle bundlePath], [[NSBundle bundleForClass:NSClassFromString(@"PGPMailBundle")] bundlePath]];

			if (NSRunCriticalAlertPanel(errorTitle, @"%@", NSLocalizedStringFromTableInBundle(@"QUIT", @"GPGMail", myBundle, ""), NSLocalizedStringFromTableInBundle(@"CONTINUE_ANYWAY", @"GPGMail", myBundle, ""), nil, errorMessage) == NSAlertDefaultReturn) {
				[[NSApplication sharedApplication] terminate:nil];
			} else {
				[self setIgnoresPGPPresence:YES];
			}
		}
	}
}

//- (GPGEngine *)engine {
//	if (engine == nil) {
//		BOOL logging = (GPGMailLoggingLevel > 0);
//
//		engine = [GPGEngine engineForProtocol:GPGOpenPGPProtocol];
//		NSAssert(engine != nil, @"### gpgme has been configured without OpenPGP engine?!");
//		[engine retain];
//		if (logging) {
//			NSLog(@"[DEBUG] Engine: %@", [engine debugDescription]);
//		}
//	}
//
//	return engine;
//}

// TODO: Fix me for libmacgpg
- (BOOL)checkGPG {
    return YES;
//	NSString *errorTitle = nil;
//	GPGError anError = GPGErrorNoError;
//	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
//	GPGEngine *anEngine = [self engine];
//
///*    NSArray     *availableExecutablePaths = [anEngine availableExecutablePaths];
// *  NSString    *chosenPath = nil;
// *
// *  if(![anEngine usesCustomExecutablePath]){
// *      if([availableExecutablePaths count] == 1){
// *          chosenPath = [availableExecutablePaths lastObject];
// *          @try {
// *              [[GPGEngine engineForProtocol:GPGOpenPGPProtocol] setExecutablePath:chosenPath];
// *          } @catch(NSException *localException){
// *              chosenPath = nil;
// *          }
// *      }
// *      else{
// *          // Give choice to user: either from availables, or custom, or cancel
// *      }
// *  }*/
//
//
//	anError = [GPGEngine checkVersionForProtocol:GPGOpenPGPProtocol];
//	if (anError != GPGErrorNoError) {
//		errorTitle = [self gpgErrorDescription:anError];
//	} else {
//		// Now that engine executable path is configurable, we need to check it
//		if ([anEngine version] == nil) {
//			anError = GPGErrorInvalidEngine;
//		}
//	}
//
//	if (anError != GPGErrorNoError) {
//		NSString *errorMessage = nil;
//
//		if (GPGErrorInvalidEngine == [self gpgErrorCodeFromError:anError]) {
//			NSString *currentVersion;
//			NSString *requiredVersion;
//			NSString *executablePath;
//
//			requiredVersion = [anEngine requestedVersion];
//			currentVersion = [anEngine version];
//			executablePath = [anEngine executablePath];
//
//			if (currentVersion == nil) {
//				errorMessage = NSLocalizedStringFromTableInBundle(@"GPGMAIL_CANNOT_WORK_MISSING_GPG_%@_VERSION_%@", @"GPGMail", myBundle, "");
//				errorMessage = [NSString stringWithFormat:errorMessage, executablePath, requiredVersion];
//			} else {
//				errorMessage = NSLocalizedStringFromTableInBundle(@"GPGMAIL_CANNOT_WORK_HAS_GPG_%@_VERSION_%@_NEEDS_%@", @"GPGMail", myBundle, "");
//				errorMessage = [NSString stringWithFormat:errorMessage, executablePath, currentVersion, requiredVersion];
//			}
//		} else {
//			errorMessage = NSLocalizedStringFromTableInBundle(@"GPGMAIL_CANNOT_WORK", @"GPGMail", myBundle, "");
//		}
//		(void)NSRunCriticalAlertPanel(errorTitle, @"%@", nil, nil, nil, errorMessage);
//
//		return NO;
//	} else {
//		return YES;
//	}
}

- (BOOL)checkSystem {
	BOOL isCompatibleSystem;

#warning CHECK - change for leopard!
	isCompatibleSystem = (NSClassFromString(@"NSGarbageCollector") != Nil);

	if (!isCompatibleSystem) {
		NSBundle *aBundle = [NSBundle bundleForClass:[self class]];

		(void)NSRunCriticalAlertPanel(NSLocalizedStringFromTableInBundle(@"INVALID_GPGMAIL_VERSION", @"GPGMail", aBundle, "Alert panel title"), @"%@", nil, nil, nil, NSLocalizedStringFromTableInBundle(@"NEEDS_COMPATIBLE_BUNDLE_VERSION", @"GPGMail", aBundle, "Alert panel message"));
	}

	return isCompatibleSystem;
}

- (void)newFinishInitialization {
    NSLog(@"Should be called before finish Initialization");
    [self newFinishInitialization];
}

- (void)finishInitialization {
	NSMenuItem *aMenuItem;
    
    NSLog(@"We're in, what now");
//    asm("\t.weak_reference _OBJC_CLASS_$_ComposeBackEnd\n");
//
//    NSLog(@"Trying weak linking: %@", [ComposeBackEnd self]);
    //NSLog(@"Main Bundle: %@", [NSBundle mainBundle]);
    //NSLog(@"Image named: %@", [NSImage imageNamed:@"Encrypted_Glyph"]);
//    NSLog(@"Current account: %@", [[ABAddressBook sharedAddressBook] me]);
//    NSLog(@"Personal Keys: %@", [self personalKeys]);
//    NSLog(@"Public Keys: %@", [self publicKeys]);
    
	// There's a bug in MOX: added menu items are not enabled/disabled correctly
	// if they are instantiated programmatically
	NSAssert([NSBundle loadNibNamed:@"GPGMenu" owner:self], @"### GPGMail: -[GPGMailBundle init]: Unable to load nib named GPGMenu");
	// If we disable usurpation, we can't set contextual menu?!

	realToolbarDelegates = [[NSMutableDictionary allocWithZone:[self zone]] init];
	additionalToolbarItemIdentifiersPerToolbarIdentifier = [[NSDictionary allocWithZone:[self zone]] initWithObjectsAndKeys:[NSArray arrayWithObjects:GPGDecryptMessageToolbarItemIdentifier, GPGAuthenticateMessageToolbarItemIdentifier, nil], @"MainWindow", [NSArray arrayWithObjects:GPGDecryptMessageToolbarItemIdentifier, GPGAuthenticateMessageToolbarItemIdentifier, nil], @"SingleMessageViewer", [NSArray arrayWithObjects:GPGEncryptMessageToolbarItemIdentifier, GPGSignMessageToolbarItemIdentifier, nil], @"ComposeWindow_NewMessage", [NSArray arrayWithObjects:GPGEncryptMessageToolbarItemIdentifier, GPGSignMessageToolbarItemIdentifier, nil], @"ComposeWindow_ReplyOrForward", nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(anyToolbarWillAddItem:) name:NSToolbarWillAddItemNotification object:nil];
	// LEOPARD - list is always empty. If too early, then it's OK for us. No instance has yet been created, and we will do the work through -anyToolbarWillAddItem:
    for (MessageViewer *aViewer in [NSClassFromString(@"MessageViewer") allMessageViewers]) {
        [self usurpToolbarDelegate:[aViewer gpgToolbar]];
    }
        
    
	[GPGPassphraseController setCachesPassphrases:[self remembersPassphrasesDuringSession]];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidMount:) name:NSWorkspaceDidMountNotification object:[NSWorkspace sharedWorkspace]];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceDidUnmount:) name:NSWorkspaceDidUnmountNotification object:[NSWorkspace sharedWorkspace]];
	[allUserIDsMenuItem setState:([self displaysAllUserIDs] ? NSOnState:NSOffState)];

	aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"PGP_SEARCH_KEYS_MENUITEM", @"GPGMail", [NSBundle bundleForClass:[self class]], "<PGP Key Search> menuItem title") action:@selector(gpgSearchKeys:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(showAddressHistoryPanel:) offset:1];

	if (!aMenuItem) {
		NSLog(@"### GPGMail: unable to add menuItem <PGP Key Search>");
	} else {
		[aMenuItem setTarget:self];
	}
    [aMenuItem release];

	// Addition which has nothing to do with GPGMail
	if ([[GPGDefaults gpgDefaults] boolForKey:@"GPGEnableMessageURLCopy"]) {
		aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"COPY_MSG_URL_MENUITEM", @"GPGMail", [NSBundle bundleForClass:[self class]], "<Copy Message URL> menuItem title") action:@selector(gpgCopyMessageURL:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(pasteAsQuotation:) offset:0];
        [aMenuItem release];
    }
    
	[self performSelector:@selector(checkPGPmailPresence) withObject:nil afterDelay:0];
	/*            if([[GPGDefaults gpgDefaults] boolForKey:@"GPGAddServiceReplacement"]){
	 * aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"ENCRYPT_SELECTION...", @"GPGMail", [NSBundle bundleForClass:[self class]], "<Encrypt Selection> menuItem title") action:@selector(gpgEncryptSelection:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(complete:) offset:1];
	 * [aMenuItem setTarget:self];
	 * aMenuItem = [self newMenuItemWithTitle:NSLocalizedStringFromTableInBundle(@"SIGN_SELECTION...", @"GPGMail", [NSBundle bundleForClass:[self class]], "<Sign Selection> menuItem title") action:@selector(gpgSignSelection:) andKeyEquivalent:@"" inMenu:[[NSApplication sharedApplication] mainMenu] relativeToItemWithSelector:@selector(complete:) offset:1];
	 * [aMenuItem setTarget:self];
	 * }*/

//	[self synchronizeKeyGroupsWithAddressBookGroups];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abDatabaseChangedExternally:) name:kABDatabaseChangedExternallyNotification object:[ABAddressBook sharedAddressBook]];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(abDatabaseChanged:) name:kABDatabaseChangedNotification object:[ABAddressBook sharedAddressBook]];
//
//	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(keyringChanged:) name:GPGKeyringChangedNotification object:nil];
}

- (id)init {
	if (self = [super init]) {
		NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
		NSDictionary *defaultsDictionary = [NSDictionary dictionaryWithContentsOfFile:[myBundle pathForResource:@"GPGMailBundle" ofType:@"defaults"]];

		if (gpgMailWorks) {
			gpgMailWorks = [self checkSystem];
		}

		if (defaultsDictionary) {
			[[GPGDefaults gpgDefaults] registerDefaults:defaultsDictionary];
		}

		if (gpgMailWorks) {
			gpgMailWorks = [self checkGPG];
		}
		if (gpgMailWorks) {
			[self finishInitialization];
		}
	}

	return self;
}

- (void)messageStoreMessageFlagsChanged:(NSNotification *)notification {
	if (GPGMailLoggingLevel) {
		NSLog(@"[DEBUG] messageStoreMessageFlagsChanged, from %@, with %@", [notification object], [notification userInfo]);
	}
}

- (void)workspaceDidMount:(NSNotification *)notification {
	// Some people put their keys on a mountable volume, and sometimes don't mount that volume
	// before launching Mail. In case the keyrings are in a newly-mounted volume, we refresh them
	if ([self refreshesKeysOnVolumeMount]) {
		[self flushKeyCache:YES];
	}
}

- (void)workspaceDidUnmount:(NSNotification *)notification {
	// Some people put their keys on a mountable volume, and sometimes don't mount that volume
	// before launching Mail. In case the keyrings are in a newly-mounted volume, we refresh them
	if ([self refreshesKeysOnVolumeMount]) {
		[self flushKeyCache:YES];
	}
}

- (void)dealloc {
    cachedPersonalGPGKeys = nil;
    [cachedPersonalGPGKeys release];
    cachedPublicGPGKeys = nil;
    [cachedPublicGPGKeys release];
    
	// Never invoked...
	[realToolbarDelegates release];
	[additionalToolbarItemIdentifiersPerToolbarIdentifier release];
	if (cachedUserIDsPerKey != NULL) {
		NSFreeMapTable(cachedUserIDsPerKey);
	}
	[cachedKeyGroups release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self name:nil object:nil];
	[locale release];

	struct objc_super s = { self, [self superclass] };
	objc_msgSendSuper(&s, @selector(dealloc));
}

- (NSString *)versionDescription {
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"VERSION: %@", @"GPGMail", [NSBundle bundleForClass:[self class]], "Description of version prefixed with <Version: >"), [self version]];
}

- (NSString *)version {
	return [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

@synthesize decryptMenuItem;
@synthesize authenticateMenuItem;
@synthesize encryptsNewMessageMenuItem;
@synthesize signsNewMessageMenuItem;
@synthesize personalKeysMenuItem;
@synthesize choosePublicKeysMenuItem;
@synthesize automaticPublicKeysMenuItem;
@synthesize symetricEncryptionMenuItem;
@synthesize usesOnlyOpenPGPStyleMenuItem;
@synthesize pgpMenuItem;
@synthesize pgpViewMenuItem;
@synthesize allUserIDsMenuItem;



+ (BOOL)hasComposeAccessoryViewOwner {
	return gpgMailWorks;                 // TIGER + LEOPARD Invoked on +initialize
}

+ (NSString *)composeAccessoryViewOwnerClassName {
	// TIGER/LEOPARD Never invoked!
	return @"GPGMailComposeAccessoryViewOwner";
}

- (void)preferencesDidChange:(SEL)selector {
	NSString *aString = NSStringFromSelector(selector);

	aString = [[[aString substringWithRange:NSMakeRange(3, 1)] lowercaseString] stringByAppendingString:[aString substringWithRange:NSMakeRange(4, [aString length] - 5)]];
	// aString is the 'getter' derived from the 'setter' selector (setXXX:)
	[[NSNotificationCenter defaultCenter] postNotificationName:GPGPreferencesDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:aString forKey:@"key"]];
}

- (void)setAlwaysSignMessages:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAlwaysSignMessage"];
	if (![signsNewMessageMenuItem isEnabled]) {
		[signsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
	}
	[self preferencesDidChange:_cmd];
}

- (BOOL)alwaysSignMessages {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAlwaysSignMessage"];
}

- (void)setAlwaysEncryptMessages:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAlwaysEncryptMessage"];
	// FIXME: Update menu for mixed
	if (![encryptsNewMessageMenuItem isEnabled]) {
		[encryptsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
	}
	[self preferencesDidChange:_cmd];
}

- (BOOL)alwaysEncryptMessages {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAlwaysEncryptMessage"];
}

- (void)setEncryptMessagesWhenPossible:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptMessageWhenPossible"];
	// FIXME: Update menu
//    if(![encryptsNewMessageMenuItem isEnabled])
//        [encryptsNewMessageMenuItem setState:(flag ? NSOnState:NSOffState)];
	[self preferencesDidChange:_cmd];
}

- (BOOL)encryptMessagesWhenPossible {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptMessageWhenPossible"];
}

- (void)setDefaultKey:(GPGKey *)key {
	if (key != nil) {
		[[GPGDefaults gpgDefaults] setObject:[key fingerprint] forKey:@"GPGDefaultKeyFingerprint"];
		[key retain];
		[defaultKey release];
		defaultKey = key;
	} else {
		[[GPGDefaults gpgDefaults] removeObjectForKey:@"GPGDefaultKeyFingerprint"];
		[defaultKey release];
		defaultKey = nil;
	}
	[self refreshPersonalKeysMenu];
	[self refreshPublicKeysMenu];
	[self preferencesDidChange:_cmd];
}

- (GPGKey *)defaultKey {
	if (defaultKey == nil && gpgMailWorks) {        
		NSString *aPattern = [[GPGDefaults gpgDefaults] stringForKey:@"GPGDefaultKeyFingerprint"];
		BOOL searchedAllKeys = NO;
		BOOL fprPattern = YES;

		if (!aPattern || [aPattern length] == 0) {
            // Lion doesn't have userEmail... unfortunately.
            //aPattern = [NSApp userEmail];
			aPattern = @"";
            fprPattern = NO;
            if (!aPattern || [aPattern length] == 0) {
                aPattern = nil; // Return all secret keys
            }
		}
        
		do {
            NSArray *patterns;
            if (aPattern) {
                if (fprPattern) {
                    patterns = [NSArray arrayWithObject:aPattern];
                } else {
                    patterns = [NSArray arrayWithObject:[aPattern valueForKey:@"gpgNormalizedEmail"]];
                }
            } else {
                patterns = nil;
            }

            NSArray *keys = [self keysForSearchPatterns:patterns attributeName:(fprPattern ? @"primaryKey.fingerprint" : @"email") secretKeys:YES];
            if ([keys count] > 0) {
                [defaultKey release];
                defaultKey = [[keys objectAtIndex:0] retain];
            }
            
			if (aPattern == nil) {
				searchedAllKeys = YES;
			} else {
				aPattern = nil;
			}
		} while (defaultKey == nil && !searchedAllKeys);
	}

	return defaultKey;
}

- (void)setRemembersPassphrasesDuringSession:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGRemembersPassphrasesDuringSession"];
	[GPGPassphraseController setCachesPassphrases:flag];
	[self preferencesDidChange:_cmd];
}

- (BOOL)remembersPassphrasesDuringSession {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGRemembersPassphrasesDuringSession"];
}

- (void)setDecryptsMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDecryptsMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)decryptsMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDecryptsMessagesAutomatically"];
}

- (void)setAuthenticatesMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAuthenticatesMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)authenticatesMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAuthenticatesMessagesAutomatically"];
}

- (void)setDisplaysButtonsInComposeWindow:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisplaysButtonsInComposeWindow"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)displaysButtonsInComposeWindow {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisplaysButtonsInComposeWindow"];
}

- (void)setEncryptsToSelf:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptsToSelf"];
	[self refreshPublicKeysMenu];
	[self preferencesDidChange:_cmd];
}

- (BOOL)encryptsToSelf {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptsToSelf"];
}

- (void)setUsesKeychain:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesKeychain"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesKeychain {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesKeychain"];
}

- (void)setUsesOnlyOpenPGPStyle:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGOpenPGPStyleOnly"];
	if (![usesOnlyOpenPGPStyleMenuItem isEnabled]) {
		[usesOnlyOpenPGPStyleMenuItem setState:(flag ? NSOnState:NSOffState)];
	}
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesOnlyOpenPGPStyle {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGOpenPGPStyleOnly"];
}

- (void)setDecryptsOnlyUnreadMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDecryptsOnlyUnreadMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)decryptsOnlyUnreadMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDecryptsOnlyUnreadMessagesAutomatically"];
}

- (void)setAuthenticatesOnlyUnreadMessagesAutomatically:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAuthenticatesOnlyUnreadMessagesAutomatically"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)authenticatesOnlyUnreadMessagesAutomatically {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAuthenticatesOnlyUnreadMessagesAutomatically"];
}

- (void)setUsesEncapsulatedSignature:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesEncapsulatedSignature"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesEncapsulatedSignature {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesEncapsulatedSignature"];
}

- (void)setUsesBCCRecipients:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesBCCRecipients"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)usesBCCRecipients {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesBCCRecipients"];
}

- (void)setTrustsAllKeys:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGTrustsAllKeys"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)trustsAllKeys {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGTrustsAllKeys"];
}

- (void)setAutomaticallyShowsAllInfo:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAutomaticallyShowsAllInfo"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)automaticallyShowsAllInfo {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAutomaticallyShowsAllInfo"];
}

- (void)setPassphraseFlushTimeout:(NSTimeInterval)timeout {
	NSParameterAssert(timeout >= 0.0);
	[[GPGDefaults gpgDefaults] setFloat:timeout forKey:@"GPGPassphraseFlushTimeout"];
	[self preferencesDidChange:_cmd];
}

- (NSTimeInterval)passphraseFlushTimeout {
	return [[GPGDefaults gpgDefaults] floatForKey:@"GPGPassphraseFlushTimeout"];
}

- (void)setChoosesPersonalKeyAccordingToAccount:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGChoosesPersonalKeyAccordingToAccount"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)choosesPersonalKeyAccordingToAccount {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGChoosesPersonalKeyAccordingToAccount"];
}

- (void)setButtonsShowState:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGButtonsShowState"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)buttonsShowState {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGButtonsShowState"];
}

- (void)setSignWhenEncrypting:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGSignWhenEncrypting"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)signWhenEncrypting {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGSignWhenEncrypting"];
}

- (NSArray *)allDisplayedKeyIdentifiers {
	static NSArray *allDisplayedKeyIdentifiers = nil;

	if (!allDisplayedKeyIdentifiers) {
		// TODO: After adding longKeyID, update GPGPreferences.nib
		allDisplayedKeyIdentifiers = [[NSArray arrayWithObjects:@"name", @"email", @"comment", @"fingerprint", @"keyID", /*@"longKeyID",*/ @"validity", @"algorithm", nil] retain];
	}

	return allDisplayedKeyIdentifiers;
}

- (void)setDisplayedKeyIdentifiers:(NSArray *)keyIdentifiers {
    NSArray *allKeyIdentifiers = [self allDisplayedKeyIdentifiers];
  
    for (NSString *anIdentifier in keyIdentifiers) {
        NSAssert1([allKeyIdentifiers containsObject:anIdentifier], @"### GPGMail: -[GPGMailBundle setDisplayedKeyIdentifiers:]: invalid identifier '%@'", anIdentifier);
    }
	
    
    [[GPGDefaults gpgDefaults] setObject:keyIdentifiers forKey:@"GPGDisplayedKeyIdentifiers"];
	[self refreshPublicKeysMenu];
	[self refreshPersonalKeysMenu];
	[self refreshKeyIdentifiersDisplayInMenu:[[self pgpViewMenuItem] submenu]];
	[self preferencesDidChange:_cmd];
}

- (NSArray *)displayedKeyIdentifiers {
	return [[GPGDefaults gpgDefaults] arrayForKey:@"GPGDisplayedKeyIdentifiers"];
}

- (void)setDisplaysAllUserIDs:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisplaysAllUserIDs"];
	[self refreshPublicKeysMenu];
	[self refreshPersonalKeysMenu];
	[allUserIDsMenuItem setState:([self displaysAllUserIDs] ? NSOnState:NSOffState)];
	[self preferencesDidChange:_cmd];
}

- (BOOL)displaysAllUserIDs {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisplaysAllUserIDs"];
}

- (void)setFiltersOutUnusableKeys:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGFiltersOutUnusableKeys"];
	[self flushKeyCache:YES];
	[self preferencesDidChange:_cmd];
}

- (BOOL)filtersOutUnusableKeys {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGFiltersOutUnusableKeys"];
}

- (void)setShowsPassphrase:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGShowsPassphrase"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)showsPassphrase {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGShowsPassphrase"];
}

- (void)setLineWrappingLength:(int)value {
	[[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"LineLength"];
	[self preferencesDidChange:_cmd];
}

- (int)lineWrappingLength {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"LineLength"];
}

- (void)setIgnoresPGPPresence:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGIgnoresPGPPresence"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)ignoresPGPPresence {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGIgnoresPGPPresence"];
}

- (void)setRefreshesKeysOnVolumeMount:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGRefreshesKeysOnVolumeMount"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)refreshesKeysOnVolumeMount {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGRefreshesKeysOnVolumeMount"];
}

- (void)setDisablesSMIME:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGDisablesSMIME"];
	[self preferencesDidChange:_cmd];
}

- (BOOL)disablesSMIME {
	return gpgMailWorks && [[GPGDefaults gpgDefaults] boolForKey:@"GPGDisablesSMIME"];
}

- (void)setWarnedAboutMissingPrivateKeys:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGWarnedAboutMissingPrivateKeys"];
}

- (BOOL)warnedAboutMissingPrivateKeys {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGWarnedAboutMissingPrivateKeys"];
}

- (void)setEncryptsReplyToEncryptedMessage:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGEncryptsReplyToEncryptedMessage"];
}

- (BOOL)encryptsReplyToEncryptedMessage {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGEncryptsReplyToEncryptedMessage"];
}

- (void)setSignsReplyToSignedMessage:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGSignsReplyToSignedMessage"];
}

- (BOOL)signsReplyToSignedMessage {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGSignsReplyToSignedMessage"];
}

- (void)setUsesABEntriesRules:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGUsesABEntriesRules"];
}

- (BOOL)usesABEntriesRules {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGUsesABEntriesRules"];
}

- (void)setAddsCustomHeaders:(BOOL)flag {
	[[GPGDefaults gpgDefaults] setBool:flag forKey:@"GPGAddCustomHeaders"];
}

- (BOOL)addsCustomHeaders {
	return [[GPGDefaults gpgDefaults] boolForKey:@"GPGAddCustomHeaders"];
}

- (void)mailTo:(id)sender {
	NSString *error = nil;
	NSPasteboard *aPasteboard = [NSPasteboard pasteboardWithUniqueName];
	NSArray *pbTypes = [NSArray arrayWithObject:NSStringPboardType];
	id serviceProvider = [NSApplication sharedApplication];

	(void)[aPasteboard declareTypes:pbTypes owner:nil];
	(void)[aPasteboard addTypes:pbTypes owner:nil];
	(void)[aPasteboard setString:@"gpgtools-users@lists.gpgtools.org" forType:NSStringPboardType];

	// Invoke <MailViewer/Mail To> service
	if ([serviceProvider respondsToSelector:@selector(mailTo:userData:error:)]) {
		[serviceProvider mailTo:aPasteboard userData:nil error:&error];
	}
	if (error) {
		NSBeep();
	}
}

- (void)gpgForwardAction:(SEL)action from:(id)sender {
	// Still used as of v37 for encrypt/sign toolbar buttons
	id messageEditor = [[NSApplication sharedApplication] targetForAction:action];

	if (messageEditor && [messageEditor respondsToSelector:action]) {
		[messageEditor performSelector:action withObject:sender];
	}
}

- (IBAction)gpgToggleEncryptionForNewMessage:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleSignatureForNewMessage:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgChoosePublicKeys:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgChoosePersonalKey:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgChoosePublicKey:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleAutomaticPublicKeysChoice:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleSymetricEncryption:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleUsesOnlyOpenPGPStyle:(id)sender {
	[self gpgForwardAction:_cmd from:sender];
}

- (IBAction)gpgToggleShowKeyInformation:(id)sender {
	NSString *anIdentifier = [[self allDisplayedKeyIdentifiers] objectAtIndex:([sender tag] - 1)];
	NSMutableArray *anArray = [NSMutableArray arrayWithArray:[self displayedKeyIdentifiers]];
	int oldState = [sender state];

	if (oldState == NSOnState) {
		[anArray removeObject:anIdentifier];
	} else {
		[anArray addObject:anIdentifier];
	}
	[self setDisplayedKeyIdentifiers:anArray];
}

- (IBAction)gpgToggleDisplayAllUserIDs:(id)sender {
	[self setDisplaysAllUserIDs:([sender state] != NSOnState)];             // Toggle...
}

- (id)messageViewerOrEditorForToolbarItem:(NSToolbarItem *)item {
	MessageViewer *aViewer;
	MessageViewer *anEditor;

    for (aViewer in [NSClassFromString(@"MessageViewer") allMessageViewers]) {
		NSToolbar *aToolbar = [aViewer gpgToolbar];

		if ([[aToolbar items] containsObject:item]) {
			return aViewer;
		}

		if ([item isKindOfClass:[NSClassFromString(@"SegmentedToolbarItemSegmentItem") class]] && [[aToolbar items] containsObject:[(SegmentedToolbarItemSegmentItem *) item parent]]) {
			return aViewer;
		}
	}
	// These "messageEditors" are not real message editors, but detached viewers (no mailbox)...
    for (anEditor in [NSClassFromString(@"MailDocumentEditor") documentEditors]) {
		NSToolbar *aToolbar = [anEditor gpgToolbar];

		if ([[aToolbar items] containsObject:item]) {
			return anEditor;
		}
		if ([item isKindOfClass:[NSClassFromString(@"SegmentedToolbarItemSegmentItem") class]] && [[aToolbar items] containsObject:[(id) item parent]]) {
			return anEditor;
		}
	}

    for (aViewer in [NSClassFromString(@"MessageViewer") allSingleMessageViewers]) {
		NSToolbar *aToolbar = [aViewer gpgToolbar];

		if ([[aToolbar items] containsObject:item]) {
			return aViewer;
		}

		if ([item isKindOfClass:[NSClassFromString(@"SegmentedToolbarItemSegmentItem") class]] && [[aToolbar items] containsObject:[(SegmentedToolbarItemSegmentItem *) item parent]]) {
			return aViewer;
		}
	}

	return nil;             // May happen, while new compose window is being set up.
}

- (Message *)targetMessageForToolbarItem:(NSToolbarItem *)item {
	if (item == nil) {
		// item is nil when validating menu items => menu items apply to
		// first responder (or use responder chain)
		MessageViewer *messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
		MessageContentController *viewer = [messageViewer gpgTextViewer:nil];

		return [viewer gpgMessage];
	} else {
		MessageViewer *aViewer;
		MessageViewer *anEditor;

        for (aViewer in [NSClassFromString(@"MessageViewer") allMessageViewers]) {
			NSToolbar *aToolbar = [aViewer gpgToolbar];

			if ([[aToolbar items] containsObject:item]) {
				return [[aViewer gpgTextViewer:nil] gpgMessage];
			}
		}

		// These "messageEditors" are not real message editors, but detached viewers (no mailbox)...
        for (anEditor in [NSClassFromString(@"MailDocumentEditor") documentEditors]) {
			NSToolbar *aToolbar = [anEditor gpgToolbar];

			if ([[aToolbar items] containsObject:item]) {
				return [[anEditor gpgTextViewer:nil] gpgMessage];
			}
		}

        for (aViewer in [NSClassFromString(@"MessageViewer") allSingleMessageViewers]) {
			NSToolbar *aToolbar = [aViewer gpgToolbar];

			if ([[aToolbar items] containsObject:item]) {
				return [[aViewer gpgTextViewer:nil] gpgMessage];
			}
		}
	}

	return nil;
}

- (BOOL)_validateAction:(SEL)anAction toolbarItem:(NSToolbarItem *)item menuItem:(NSMenuItem *)menuItem {
    // TODO: Fix for Lion!
    return YES;
//	if (anAction == @selector(gpgToggleEncryptionForNewMessage:) ||
//		anAction == @selector(gpgToggleSignatureForNewMessage:) ||
//		anAction == @selector(gpgChoosePersonalKey:) ||
//		anAction == @selector(gpgChoosePublicKeys:) ||
//		anAction == @selector(gpgChoosePublicKey:) ||
//		anAction == @selector(gpgToggleAutomaticPublicKeysChoice:) ||
//		anAction == @selector(gpgToggleSymetricEncryption:) ||
//		anAction == @selector(gpgToggleUsesOnlyOpenPGPStyle:)) {
//		if (menuItem) {
//			id messageEditor = [[NSApplication sharedApplication] targetForAction:anAction];
//
//			if (messageEditor != nil) {
//				return ([messageEditor respondsToSelector:@selector(gpgIsRealEditor)] && [messageEditor gpgIsRealEditor] && [messageEditor gpgValidateMenuItem:menuItem]);
//			} else {
//				return NO;
//			}
//		} else {
//			id messageEditor = [self messageViewerOrEditorForToolbarItem:item];
//
//			if (messageEditor != nil) {
//				return ([messageEditor respondsToSelector:@selector(gpgIsRealEditor)] && [messageEditor gpgIsRealEditor] && [messageEditor gpgValidateToolbarItem:item]);
//			} else {
//				return NO;
//			}
//		}
//	} else if (anAction == @selector(gpgDecrypt:) || anAction == @selector(gpgAuthenticate:)) {
//		if (menuItem) {
//			MessageViewer *messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
//			MessageContentController *viewer = [messageViewer gpgTextViewer:nil];
//
//			return [viewer validateMenuItem:menuItem];
//		} else {
//			MessageViewer *messageViewer = [self messageViewerOrEditorForToolbarItem:item];
//			MessageContentController *viewer = [messageViewer gpgTextViewer:nil];
//
//			return [viewer gpgValidateAction:anAction];
//		}
//	} else if (anAction == @selector(gpgReloadPGPKeys:)) {
//		return YES;
//	} else if (anAction == @selector(gpgToggleDisplayAllUserIDs:)) {
//		return YES;
//	} else if (anAction == @selector(gpgToggleShowKeyInformation:)) {
//		return YES;
//	} else if (anAction == @selector(gpgSearchKeys:)) {
//		return YES;
//	}
/*    else if(anAction == @selector(gpgEncryptSelection:) || anAction == @selector(gpgSignSelection:)){
 *      static id previousDelegate = nil;
 *      static id previousResponder = nil;
 *
 *      if(previousDelegate != [[NSApp mainWindow] delegate]){
 *          previousDelegate = [[NSApp mainWindow] delegate];
 *          NSLog(@"[[NSApp mainWindow] delegate] = %@", [[NSApp mainWindow] delegate]);
 *      }
 *      if(previousResponder != [[NSApp mainWindow] firstResponder]){
 *          previousResponder = [[NSApp mainWindow] firstResponder];
 *          NSLog(@"[[NSApp mainWindow] firstResponder] = %@", [[NSApp mainWindow] firstResponder]);
 *      }
 *      if([[[NSApp mainWindow] delegate] isKindOfClass:[MessageEditor class]] && [[[NSApp mainWindow] firstResponder] isKindOfClass:[MessageTextView class]]){
 *          if([[[NSApp mainWindow] firstResponder] selectedAttachments] == nil && [[[NSApp mainWindow] firstResponder] selectedRange].length > 0)
 *          return YES;
 *      }
 *  }*/

	return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem *)theItem {
	// (Not called for toolbarItems when displayed as menuItems; validateToolbarItem: is called)
	return [self _validateAction:[theItem action] toolbarItem:nil menuItem:theItem];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
	// WARNING: this method is called repeatedly by Mail.app
	// In fact it is called so often that sometimes it can lock down Mail.app.
	// That's why we cache validation results
	return [self _validateAction:[theItem action] toolbarItem:theItem menuItem:nil];
}

- (BOOL)validateToolbarItem:(id)fp8 forSegment:(int)fp12 {
	return [self _validateAction:[fp8 actionForSegment:fp12] toolbarItem:fp8 menuItem:nil];
}

- (IBAction)gpgDecrypt:(id)sender {
	MessageViewer *messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
	MessageContentController *viewer = [messageViewer gpgTextViewer:nil];

	[viewer gpgDecrypt:sender];
}

- (IBAction)gpgAuthenticate:(id)sender {
	MessageViewer *messageViewer = [[NSApplication sharedApplication] targetForAction:@selector(gpgTextViewer:)];
	MessageContentController *viewer = [messageViewer gpgTextViewer:nil];

	[viewer gpgAuthenticate:sender];
}

- (void)progressIndicatorDidCancel:(GPGProgressIndicatorController *)controller {
//    [[GPGHandler defaultHandler] cancelOperation];
}

- (IBAction)gpgReloadPGPKeys:(id)sender {
	[self flushKeyCache:YES];
	if (gpgMailWorks) {
		[self synchronizeKeyGroupsWithAddressBookGroups];
	}
}

- (IBAction)gpgSearchKeys:(id)sender {
	// For testing create a NSDataMessageStore.
    GPGController *gpgc = [[GPGController alloc] init];
    NSData *encryptedData = [NSData dataWithContentsOfFile:@"/Users/lukele/Desktop/PGP.asc"];
    NSData *decryptedData = [gpgc decryptData:encryptedData];
    NSDataMessageStore *decryptedMessageStore = [[NSDataMessageStore alloc] initWithData:decryptedData];
    _NSDataMessageStoreMessage *decryptedMessage = [decryptedMessageStore message];
    MimeBody *decryptedMessageBody = [decryptedMessage messageBody];
    NSLog(@"Top level part: %@", [decryptedMessageBody attributedString]);
    
    //[[GPGKeyDownload sharedInstance] gpgSearchKeys:sender];
}

- (void)flushKeyCache:(BOOL)refresh {
	cachedPersonalGPGKeys = nil;
    [cachedPersonalGPGKeys release];
	cachedPublicGPGKeys = nil;
	[cachedPublicGPGKeys release];
	[cachedKeyGroups release];
	cachedKeyGroups = nil;
	[defaultKey release];
	defaultKey = nil;
	if (cachedUserIDsPerKey != NULL) {
		NSFreeMapTable(cachedUserIDsPerKey);
		cachedUserIDsPerKey = NULL;
	}
	if (refresh) {
		[[NSNotificationCenter defaultCenter] postNotificationName:GPGKeyListWasInvalidatedNotification object:self];
		[self refreshPersonalKeysMenu];                       // Was disabled
		[self refreshPublicKeysMenu];                         // Was disabled
	}
#warning CHECK: keys not synced with current editor!
}

- (void)warnUserForMissingPrivateKeys:(id)sender {
	NSBundle *aBundle = [NSBundle bundleForClass:[self class]];
	NSString *aTitle = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - TITLE", @"GPGMail", aBundle, "");
	NSString *aMessage = NSLocalizedStringFromTableInBundle(@"NO PGP PRIVATE KEY - MESSAGE", @"GPGMail", aBundle, "");

	(void)NSRunAlertPanel(aTitle, @"%@", nil, nil, nil, aMessage);
	[self setWarnedAboutMissingPrivateKeys:YES];
}

- (NSArray *)keysForSearchPatterns:(NSArray *)searchPatterns attributeName:(NSString *)attributeKeyPath secretKeys:(BOOL)secretKeys {
	// We need to perform search in-memory, because asking gpgme/gpg to do it launches
	// a task each time, starving the system resources!
	NSMutableArray *keys = [NSMutableArray array];
	NSSet *allKeys = (secretKeys ? [self personalKeys] : [self publicKeys]);

	if (!searchPatterns) {
		[keys addObjectsFromArray:[allKeys allObjects]];
	} else {
        for (GPGKey *eachKey in allKeys) {
			BOOL found = NO;
            
            for (GPGUserID *eachUserID in [eachKey userIDs]) {
				if ([searchPatterns containsObject:[eachUserID valueForKeyPath:attributeKeyPath]]) {                                                               // FIXME: Zombie(?) of searchPatterns crash in -isEqual:
					found = YES;
					break;
				}
			}

			if (found) {
				[keys addObject:eachKey];
			}
		}
	}

	return keys;
}

- (NSSet *)loadGPGKeys {
    if(!gpgMailWorks) return nil;
    if(!cachedGPGKeys) {
        GPGController *gpgc = [[GPGController alloc] init];
        cachedGPGKeys = [gpgc allKeys];
        [gpgc release];
    }
    return cachedGPGKeys;
}

- (NSSet *)personalKeys {
    NSSet *allKeys;
    BOOL filterKeys;
    
    if(!gpgMailWorks)
        return nil;
    
    if(!cachedPersonalGPGKeys) {
        filterKeys = [self filtersOutUnusableKeys];
        allKeys = [self loadGPGKeys];
        cachedPersonalGPGKeys = [[allKeys map:^(id obj) {
            return ((GPGKey *)obj).secret && (!filterKeys || [self canKeyBeUsedForSigning:obj]) ? obj : nil; 
        }] copy];
        
        if ([cachedPersonalGPGKeys count] == 0 && ![self warnedAboutMissingPrivateKeys]) {
			[self performSelector:@selector(warnUserForMissingPrivateKeys:) withObject:nil afterDelay:0];
		}
    }
    NSLog(@"cachedPersonalGPGKeys: %@", cachedPersonalGPGKeys);
    
    return cachedPersonalGPGKeys;
}

- (NSSet *)publicKeys {
    NSSet *allKeys;
    BOOL filterKeys;
    
    if(!gpgMailWorks)
        return nil;
    
    if(!cachedPublicGPGKeys) {
        filterKeys = [self filtersOutUnusableKeys];
        allKeys = [self loadGPGKeys];
        cachedPublicGPGKeys = [[allKeys map:^(id obj) {
            return !filterKeys || [self canKeyBeUsedForEncryption:obj] ? obj : nil; 
        }] copy];        
    }
    
    return cachedPublicGPGKeys;
}

// TODO: Fix for libmacgpg
//- (NSArray *)keyGroups {
//	if (!cachedKeyGroups && gpgMailWorks) {
//		GPGContext *aContext = [[GPGContext alloc] init];
//
//		cachedKeyGroups = [[aContext keyGroups] retain];
//		[aContext release];
//	}
//
//	return cachedKeyGroups;
//}

- (NSArray *)secondaryUserIDsForKey:(GPGKey *)key {
	// BUG: if primary userID is not valid,
	// it will not be filtered out!
	NSArray *result;

	if (cachedUserIDsPerKey == NULL) {
		// We NEED to retain userIDs, else there are zombies, due to DO
		cachedUserIDsPerKey = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 50, [self zone]);
	}
	result = NSMapGet(cachedUserIDsPerKey, key);
	if (result == nil) {
        
		result = [key userIDs];
		if ([result count] > 1) {
			NSEnumerator *anEnum = [result objectEnumerator];
			NSMutableArray *anArray = [NSMutableArray array];
			GPGUserID *aUserID;
			BOOL filterKeys = [self filtersOutUnusableKeys];

            
			[anEnum nextObject]; // Skip primary userID
			while (aUserID = [anEnum nextObject]) {
				if (!filterKeys || [self canUserIDBeUsed:aUserID]) {
					[anArray addObject:aUserID];
				}
            }
			result = anArray;
		} else {
			result = [NSArray array];
		}
		NSMapInsert(cachedUserIDsPerKey, key, result);
	}

	return result;
}

// TODO: Fix for libmacgpg
//- (NSString *)context:(GPGContext *)context passphraseForKey:(GPGKey *)key again:(BOOL)again {
//	NSString *passphrase;
//
//	if (again && key != nil) {
//		[GPGPassphraseController flushCachedPassphraseForUser:key];
//	}
//
//	// (Find current window) No longer necessary - will be replaced by agent
//	passphrase = [[GPGPassphraseController controller] passphraseForUser:key title:NSLocalizedStringFromTableInBundle(@"MESSAGE_DECRYPTION_PASSPHRASE_TITLE", @"GPGMail", [NSBundle bundleForClass:[self class]], "") window:/*[[self composeAccessoryView] window]*/ nil];
//
//	return passphrase;
//}

- (GPGKey *)publicKeyForSecretKey:(GPGKey *)secretKey {
	// Do not invoke -[GPGKey publicKey], because it will perform a gpg op
	// Get key from cached public keys
	[secretKey retain];
    NSString *aFingerprint = [secretKey fingerprint];

    for (GPGKey *aPublicKey in [self publicKeys]) {
		if ([[aPublicKey fingerprint] isEqualToString:aFingerprint]) {
            [secretKey release];
			return aPublicKey;
		}
    }
    [secretKey release];
	return nil;
}

- (NSString *)menuItemTitleForKey:(GPGKey *)key {
	NSMutableArray *components = [NSMutableArray array];
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	GPGUserID *primaryUserID;
	BOOL isKeyRevoked, hasKeyExpired, isKeyDisabled, isKeyInvalid;
	BOOL hasNonRevokedSubkey = NO, hasNonExpiredSubkey = NO, hasNonDisabledSubkey = NO, hasNonInvalidSubkey = NO;
    GPGKey *publicKey;
    
    [key retain];
#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
	publicKey = [self publicKeyForSecretKey:key];
    [key release];
	primaryUserID = ([[publicKey userIDs] count] > 0 ? [[publicKey userIDs] objectAtIndex:0] : nil);
	isKeyRevoked = publicKey.revoked;             // Secret keys are never marked as revoked!
	hasKeyExpired = publicKey.expired;
	isKeyDisabled = publicKey.disabled;
	isKeyInvalid = publicKey.invalid;

	// A key can have no "problem" whereas the subkey it needs has such "problems"!!!
#warning We really need to filter keys according to SUBKEYS!
	// Currently we filter only according to key -> we display disabled keys,
	// whereas we shouldn't even show them
    for (GPGSubkey *aSubkey in [publicKey subkeys]) {
		if (!aSubkey.revoked) {
			hasNonRevokedSubkey = YES;
		}
		if (!aSubkey.expired) {
			hasNonExpiredSubkey = YES;
		}
		if (!aSubkey.disabled) {
			hasNonDisabledSubkey = YES;
		}
		if (!aSubkey.invalid) {
			hasNonInvalidSubkey = YES;
		}
	}

	if (primaryUserID != nil) {
		if (primaryUserID.revoked) {
			[components addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_USER_ID:", @"GPGMail", myBundle, "")];
		}
		if (primaryUserID.invalid) {
			[components addObject:NSLocalizedStringFromTableInBundle(@"INVALID_USER_ID:", @"GPGMail", myBundle, "")];
		}
	}

	if (isKeyRevoked && !hasNonRevokedSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_KEY:", @"GPGMail", myBundle, "")];
	}
	if (hasKeyExpired && !hasNonExpiredSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"EXPIRED_KEY:", @"GPGMail", myBundle, "")];
	}
	if (isKeyDisabled && !hasNonDisabledSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"DISABLED_KEY:", @"GPGMail", myBundle, "")];
	}
	if (isKeyInvalid && !hasNonInvalidSubkey) {
		[components addObject:NSLocalizedStringFromTableInBundle(@"INVALID_KEY:", @"GPGMail", myBundle, "")];
	}

    for (NSString *anIdentifier in [self displayedKeyIdentifiers]) {
		id aValue;
		NSString *aComponent;

		if ([anIdentifier isEqualToString:@"validity"]) {
			anIdentifier = @"validityNumber";
		} else if ([anIdentifier isEqualToString:@"keyID"]) {
			anIdentifier = @"shortKeyID";
		} else if ([anIdentifier isEqualToString:@"longKeyID"]) {
			anIdentifier = @"keyID";
		} else if ([anIdentifier isEqualToString:@"algorithm"]) {
			anIdentifier = @"algorithmDescription";
		} else if ([anIdentifier isEqualToString:@"fingerprint"]) {
			anIdentifier = @"formattedFingerprint";
		}
		aValue = [publicKey performSelector:NSSelectorFromString(anIdentifier)];
		if (aValue == nil || ([aValue isKindOfClass:[NSString class]] && [(NSString *) aValue length] == 0)) {
			continue;
		}

		if ([anIdentifier isEqualToString:@"email"]) {
			aComponent = [NSString stringWithFormat:@"<%@>", aValue];
		} else if ([anIdentifier isEqualToString:@"comment"]) {
			aComponent = [NSString stringWithFormat:@"(%@)", aValue];
		} else if ([anIdentifier isEqualToString:@"validityNumber"]) {
			// Validity has no meaning yet for secret keys, always unknown, so we never display it
			if (![publicKey isSecret]) {
				NSString *aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

				aDesc = NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", myBundle, "");
				aComponent = [NSString stringWithFormat:@"[%@%@]", NSLocalizedStringFromTableInBundle(@"VALIDITY: ", @"GPGMail", myBundle, ""), aDesc];
			} else {
				continue;
			}
		} else if ([anIdentifier isEqualToString:@"shortKeyID"]) {
			aComponent = [NSString stringWithFormat:@"0x%@", aValue];
		} else if ([anIdentifier isEqualToString:@"keyID"]) {
			aComponent = [NSString stringWithFormat:@"0x%@", aValue];
		} else {
			aComponent = aValue;
		}
		[components addObject:aComponent];
	}

	return [components componentsJoinedByString:@" "];
}

- (NSString *)menuItemTitleForUserID:(GPGUserID *)userID indent:(unsigned)indent {
	NSMutableArray *titleElements = [NSMutableArray array];
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];

#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
	if ([userID hasBeenRevoked]) {
		[titleElements addObject:NSLocalizedStringFromTableInBundle(@"REVOKED_USER_ID:", @"GPGMail", myBundle, "")];
	}
	if ([userID isInvalid]) {
		[titleElements addObject:NSLocalizedStringFromTableInBundle(@"INVALID_USER_ID:", @"GPGMail", myBundle, "")];
	}

    for (NSString *anIdentifier in [self displayedKeyIdentifiers]) {
		id aValue;

		if ([anIdentifier isEqualToString:@"fingerprint"] || [anIdentifier isEqualToString:@"keyID"] || [anIdentifier isEqualToString:@"algorithm"] || [anIdentifier isEqualToString:@"longKeyID"]) {
			continue;
		}
		if ([anIdentifier isEqualToString:@"validity"]) {
			anIdentifier = @"validityNumber";
		}

		aValue = [userID performSelector:NSSelectorFromString(anIdentifier)];

		if (aValue == nil || ([aValue isKindOfClass:[NSString class]] && [(NSString *) aValue length] == 0)) {
			continue;
		}

		if ([anIdentifier isEqualToString:@"email"]) {
			[titleElements addObject:[NSString stringWithFormat:@"<%@>", aValue]];
		} else if ([anIdentifier isEqualToString:@"comment"]) {
			[titleElements addObject:[NSString stringWithFormat:@"(%@)", aValue]];
		} else if ([anIdentifier isEqualToString:@"validityNumber"]) {
			// Validity has no meaning yet for secret keys, always unknown, so we never display it
			if (![[userID key] isSecret]) {
				NSString *aDesc = [NSString stringWithFormat:@"Validity=%@", aValue];

				aDesc = NSLocalizedStringFromTableInBundle(aDesc, @"GPGMail", myBundle, "");
				[titleElements addObject:[NSString stringWithFormat:@"[%@%@]", NSLocalizedStringFromTableInBundle(@"VALIDITY: ", @"GPGMail", myBundle, ""), aDesc]];                                                 // Would be nice to have an image for that
			}
		} else {
			[titleElements addObject:aValue];
		}
	}

	return [[@"" stringByPaddingToLength:(indent * 4) withString:@" " startingAtIndex:0] stringByAppendingString:[titleElements componentsJoinedByString:@" "]];
}

- (BOOL)canKeyBeUsedForEncryption:(GPGKey *)key {
	// A subkey can be expired, without the key being, thus making key useless because it has
	// no other subkey...
	// We don't care about ownerTrust, validity

	for (GPGSubkey *aSubkey in [key subkeys]) {
		if (aSubkey.canEncrypt && !aSubkey.expired && !aSubkey.revoked && !aSubkey.invalid && !aSubkey.disabled) {
			return YES;
		}
    }
	return NO;
}

- (BOOL)canKeyBeUsedForSigning:(GPGKey *)key {
	// A subkey can be expired, without the key being, thus making key useless because it has
	// no other subkey...
	// We don't care about ownerTrust, validity, subkeys

#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
	key = [self publicKeyForSecretKey:key];

	// If primary key itself can sign, that's OK (unlike what gpgme documentation says!)
	if (key.canSign && !key.expired && !key.revoked && !key.invalid && !key.disabled) {
		return YES;
	}

	for (GPGSubkey *aSubkey in [key subkeys]) {
		if (aSubkey.canSign && !aSubkey.expired && !aSubkey.revoked && !aSubkey.invalid && !aSubkey.disabled) {
			return YES;
		}
    }
	return NO;
}

- (BOOL)canUserIDBeUsed:(GPGUserID *)userID {
	// We suppose that key is OK
	// We don't care about validity
#warning FIXME: Secret keys are never marked as revoked! Check expired/disabled/invalid
	return (![userID hasBeenRevoked] && ![userID isInvalid]);
}

//- (NSString *)descriptionForError:(GPGError)error {
//	unsigned errorCode = [self gpgErrorCodeFromError:error];
//	NSString *aKey = [NSString stringWithFormat:@"GPGErrorCode=%u", errorCode];
//	NSString *localizedString = NSLocalizedStringFromTableInBundle(aKey, @"GPGMail", [NSBundle bundleForClass:[self class]], "");
//
//	if ([localizedString isEqualToString:aKey]) {
//		localizedString = [NSString stringWithFormat:@"%@ (%u)", [self gpgErrorDescription:errorCode], errorCode];
//	}
//
//	return localizedString;
//}

//- (NSString *)descriptionForException:(NSException *)exception {
//	if ([[exception name] isEqualToString:GPGException]) {
//		// Workaround for bug in gpgme: in case we encrypt to a key which is not trusted, we get a General Error instead of a Invalid Key error
//		GPGError anError = [[[exception userInfo] objectForKey:GPGErrorKey] unsignedIntValue];
//		NSDictionary *keyErrors = [[[[exception userInfo] objectForKey:GPGContextKey] operationResults] objectForKey:@"keyErrors"];
//		NSString *aDescription;
//
//		if ([self gpgErrorCodeFromError:anError] == GPGErrorGeneralError && [keyErrors count] > 0) {
//			aDescription = [self descriptionForError:[self gpgMakeErrorWithSource:[self gpgErrorSourceFromError:anError] code:GPGErrorUnusablePublicKey]];
//		} else {
//			aDescription = [self descriptionForError:[[[exception userInfo] objectForKey:GPGErrorKey] unsignedIntValue]];
//		}
//
//		if (keyErrors != nil) {
//			NSEnumerator *keyEnum = [keyErrors keyEnumerator];
//			id aKey;                                                  // GPGKey or GPGRemoteKey
//			NSMutableArray *errors = [[NSMutableArray alloc] initWithCapacity:[keyErrors count]];
//
//			while (aKey = [keyEnum nextObject]) {
//				GPGError anError = [[keyErrors objectForKey:aKey] unsignedIntValue];
//
//				if (anError != GPGErrorNoError) {
//					NSString *aKeyDescription = [aKey isKindOfClass:[GPGRemoteKey class]] ? [@"0x" stringByAppendingString:[aKey keyID]] : [self menuItemTitleForKey:aKey];
//
//					[errors addObject:[NSString stringWithFormat:@"%@ - %@", aKeyDescription, [self descriptionForError:anError]]];
//				}
//			}
//			if ([errors count] > 0) {
//				aDescription = [errors componentsJoinedByString:@". "];
//			}
//			[errors release];
//		}
//
//		return aDescription;
//	} else if ([[exception name] isEqualToString:GPGMailException]) {
//		return NSLocalizedStringFromTableInBundle([exception reason], @"GPGMail", [NSBundle bundleForClass:[self class]], "");
//	} else {
//		NSString *aString = [exception reason];
//
//		if ([aString hasPrefix:@"[NOTE: this exception originated in the server.]"]) {
//			aString = [aString substringFromIndex:49];                                      // String is not localized, no problem
//		}
//		return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXCEPTION: %@", @"GPGMail", [NSBundle bundleForClass:[self class]], ""), aString];
//	}
//}

// TODO: Fix for libmacgpg
//- (NSString *)hashAlgorithmDescription:(GPGHashAlgorithm)algorithm {
//	// We can't use results coming from MacGPGME: they are not the same as defined in RFC3156
//	switch (algorithm) {
//		case GPG_MD5HashAlgorithm :
//			return @"md5";
//		case GPG_SHA_1HashAlgorithm :
//			return @"sha1";
//		case GPG_RIPE_MD160HashAlgorithm :
//			return @"ripemd160";
//		case GPG_MD2HashAlgorithm :
//			return @"md2";
//		case GPG_TIGER192HashAlgorithm :
//			return @"tiger192";
//		case GPG_HAVALHashAlgorithm :
//			return @"haval-5-160";
//		case GPG_SHA256HashAlgorithm :
//			return @"sha256";
//		case GPG_SHA384HashAlgorithm :
//			return @"sha384";
//		case GPG_SHA512HashAlgorithm :
//			return @"sha512";
//		default: {
//			NSString *hashAlgorithmDescription = GPGHashAlgorithmDescription(algorithm);
//
//			if (hashAlgorithmDescription == nil) {
//				hashAlgorithmDescription = [NSString stringWithFormat:@"%d", algorithm];
//			}
//
//			[NSException raise:NSGenericException format:NSLocalizedStringFromTableInBundle(@"INVALID_HASH_%@", @"GPGMail", [NSBundle bundleForClass:[self class]], ""), hashAlgorithmDescription];
//			return nil;                                     // Never reached
//		}
//	}
//}

- (id)locale {
//    return [NSLocale autoupdatingCurrentLocale]; // FIXME: does not work as expected
	return [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
}

/*
 * - (void) encryptSelectionSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
 * {
 *  MessageTextView	*aTextView = contextInfo;
 *  NSString		*originalString = [[aTextView string] substringWithRange:[aTextView selectedRange]];
 * }
 *
 * - (IBAction) gpgSignSelection:(id)sender
 * {
 * }
 *
 * - (IBAction) gpgEncryptSelection:(id)sender
 * {
 *  MessageTextView	*aTextView = [[NSApp mainWindow] firstResponder];
 *  NSWindow		*aWindow;
 *
 *  // Load nib containing list of pubkeys + encoding choice
 *  [NSApp beginSheet:aWindow modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(encryptSelectionSheetDidEnd:returnCode:contextInfo:) contextInfo:aTextView];
 * }
 */
//- (NSString *)gpgErrorDescription:(GPGError)error {
//	return GPGErrorDescription(error);
//}
//
//- (GPGErrorCode)gpgErrorCodeFromError:(GPGError)error {
//	return GPGErrorCodeFromError(error);
//}
//
//- (GPGErrorSource)gpgErrorSourceFromError:(GPGError)error {
//	return GPGErrorSourceFromError(error);
//}
//
//- (GPGError)gpgMakeErrorWithSource:(GPGErrorSource)source code:(GPGErrorCode)code {
//	return GPGMakeError(source, code);
//}

@end

#import <AddressBook/AddressBook.h>

@interface ABGroup (GPGMail)
- (NSArray *)gpgFlattenedMembers;
@end


@implementation ABGroup (GPGMail)

- (NSArray *)gpgFlattenedMembers {
	NSArray *gpgFlattenedMembers = [self members];

    for (ABGroup *aGroup in [self subgroups]) {
		gpgFlattenedMembers = [gpgFlattenedMembers arrayByAddingObjectsFromArray:[aGroup gpgFlattenedMembers]];
    }

	return gpgFlattenedMembers;
}

@end

@implementation GPGMailBundle (AddressGroups)

// TODO: Fix for libmacgpg
//- (void)synchronizeKeyGroupsWithAddressBookGroups {
//	// FIXME: Do that in secondary thread
//	// We try to create/update gpg groups according to AB groups
//	// We don't modify gpg groups not referenced in AB groups
//	// We create/modify only gpg groups which have keys for all members
//	GPGContext *aContext = [[GPGContext alloc] init];
//	NSArray *gpgGroups;
//	GPGKeyGroup *aKeyGroup;
//	BOOL groupsChanged = NO;
//
//	@try {
//		gpgGroups = [aContext keyGroups];
//        for (ABGroup *aGroup in [[ABAddressBook sharedAddressBook] groups]) {
//			BOOL someMemberHasNoEmail = NO;
//			BOOL someMemberHasNoKey = NO;
//			NSMutableArray *futureGroupKeys = [NSMutableArray array];
//			GPGKeyGroup *existingKeyGroup = nil;
//			NSString *aGroupName = [aGroup valueForProperty:kABGroupNameProperty];
//
//            for (GPGKeyGroup *aKeyGroup in gpgGroups) {
//				if ([[aKeyGroup name] isEqualToString:aGroupName]) {
//					existingKeyGroup = aKeyGroup;
//					break;
//				}
//			}
//
//            for (ABPerson *aMember in [aGroup gpgFlattenedMembers]) {
//				ABMultiValue *emailsValue = [aMember valueForProperty:kABEmailProperty];
//				unsigned aCount = [emailsValue count];
//
//				if (aCount > 0) {
//					NSMutableArray *emails = [NSMutableArray arrayWithCapacity:aCount];
//					unsigned i;
//					NSArray *gpgKeys;
//
//					for (i = 0; i < aCount; i++) {
//						[emails addObject:[emailsValue valueAtIndex:i]];
//					}
//					gpgKeys = [self keysForSearchPatterns:[emails valueForKey:@"gpgNormalizedEmail"] attributeName:@"normalizedEmail" secretKeys:NO];
//					switch ([gpgKeys count]) {
//						case 0:
//							someMemberHasNoKey = YES;
//							break;
//						case 1:
//							[futureGroupKeys addObject:[gpgKeys lastObject]];
//							break;
//						default: {
//							// If existing gpg group already has user's key, use it, else ask which key(s) to choose
//							BOOL existingGroupHasKeyForMember = NO;
//
//							if (existingKeyGroup) {
//                                for (GPGKey *aKey in gpgKeys) {
//									if ([[existingKeyGroup keys] containsObject:aKey]) {
//										existingGroupHasKeyForMember = YES;
//										[futureGroupKeys addObject:aKey];
//									}
//								}
//							}
//
//							if (!existingGroupHasKeyForMember) {
//								//                            if(delegate)
//								//                                gpgKeys = [delegate chooseKeys:gpgKeys forMember:aMember inGroup:aGroup];
//								if ([gpgKeys count] == 0) {
//									someMemberHasNoKey = YES;
//								} else {
//									[futureGroupKeys addObjectsFromArray:gpgKeys];
//								}
//							}
//						}
//					}
//					if (someMemberHasNoKey) {
//						break;
//					}
//				} else {
//					someMemberHasNoEmail = YES;
//					break;
//				}
//			}
//
//			if (!someMemberHasNoEmail && !someMemberHasNoKey) {
//				if (GPGMailLoggingLevel) {
//					if (existingKeyGroup) {
//						NSLog(@"[DEBUG] Will update group %@ having keys\n%@\nwith keys\n%@", aGroupName, [[existingKeyGroup keys] valueForKey:@"keyID"], [futureGroupKeys valueForKey:@"keyID"]);
//					} else {
//						NSLog(@"[DEBUG] Will create group %@ with keys\n%@", aGroupName, [futureGroupKeys valueForKey:@"keyID"]);
//					}
//				}
//				@try {
//					(void)[GPGKeyGroup createKeyGroupNamed:aGroupName withKeys:futureGroupKeys];
//					groupsChanged = YES;
//				} @catch (NSException *localException) {
//					// FIXME: Report to user that group name is invalid?
//					// Let's ignore the error
//				}
//			}
//		}
//	} @catch (NSException *localException) {
//		// FIXME: Report to user that group name is invalid?
//		// Let's ignore the error
//		[aContext release];
//		[localException raise];
//	}
//	[aContext release];
//
//	if (groupsChanged) {
//		// FIXME: Post in main thread
//		[[NSNotificationCenter defaultCenter] postNotificationName:GPGKeyGroupsChangedNotification object:nil];
//	}
//}

- (void)abDatabaseChangedExternally:(NSNotification *)notification {
	// FIXME: Update only what's needed
	[self synchronizeKeyGroupsWithAddressBookGroups];
}

- (void)abDatabaseChanged:(NSNotification *)notification {
	// FIXME: Update only what's needed
	[self synchronizeKeyGroupsWithAddressBookGroups];
}

- (void)keyringChanged:(NSNotification *)notification {
	[self gpgReloadPGPKeys:nil];
}

@end
