/*
 * Copyright (c) 2000-2012, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
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
 * THIS SOFTWARE IS PROVIDED BY GPGTools Project Team AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL GPGTools Project Team AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSObject+LPDynamicIvars.h"
#import "Message.h"
#import "ComposeBackEnd.h"
#import "MailDocumentEditor.h"
#import "Message+GPGMail.h"
#import "ComposeBackEnd+GPGMail.h"
#import "GMSecurityControl.h"

@implementation GMSecurityControl

@synthesize control = _control, securityTag = _securityTag, forcedImageName = _forcedImageName;

- (id)initWithControl:(NSSegmentedControl *)control tag:(SECURITY_BUTTON_TAG)tag {
    if(self = [super init]) {
        self.control = control;
        self.securityTag = tag;
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.control;
}

- (void)setEnabled:(BOOL)enabled {
    ComposeBackEnd *backEnd = [(MailDocumentEditor *)[[self.control target] valueForKey:@"_documentEditor"] backEnd];

    if(self.securityTag == SECURITY_BUTTON_SIGN_TAG) {
        enabled = [[backEnd getIvar:@"SignIsPossible"] boolValue];
    }
    else {
        enabled = [[backEnd getIvar:@"EncryptIsPossible"] boolValue];
        GPGMAIL_SECURITY_METHOD securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).guessedSecurityMethod;
        if(((ComposeBackEnd_GPGMail *)backEnd).securityMethod)
            securityMethod = ((ComposeBackEnd_GPGMail *)backEnd).securityMethod;
        if(securityMethod == GPGMAIL_SECURITY_METHOD_SMIME) {
            // Encrypt is for some reason only possible with S/MIME
            // if signing is also possible.
            enabled = enabled && [[backEnd getIvar:@"SignIsPossible"] boolValue];
        }
    }
    [self.control setEnabled:enabled];
}

- (void)setImage:(id)image forSegment:(NSInteger)segment {
    ComposeBackEnd *backEnd = [(MailDocumentEditor *)[[((NSSegmentedControl *)self.control) target] valueForKey:@"_documentEditor"] backEnd];
    // forcedImageName is not nil if the user clicked on the control.
    // In that case always change the control to the forced image.
    // NEVER! ignore a user decision!
    if(self.forcedImageName) {
        [self.control setImage:[NSImage imageNamed:self.forcedImageName] forSegment:0];
        return;
    }
    
    NSString *imageName = nil;
    
    if(self.securityTag == SECURITY_BUTTON_SIGN_TAG) {
        BOOL setSign = [backEnd ivarExists:@"ForceSign"] ? [[backEnd getIvar:@"ForceSign"] boolValue] : [[backEnd getIvar:@"SetSign"] boolValue];
        if(setSign && ![[backEnd getIvar:@"SignIsPossible"] boolValue])
            setSign = NO;
        
        imageName = setSign ? SIGN_ON_IMAGE : SIGN_OFF_IMAGE;
    }
    else if(self.securityTag == SECURITY_BUTTON_ENCRYPT_TAG) {
        BOOL setEncrypt = [backEnd ivarExists:@"ForceEncrypt"] ? [[backEnd getIvar:@"ForceEncrypt"] boolValue] : [[backEnd getIvar:@"SetEncrypt"] boolValue];
        
        if(setEncrypt && ![[backEnd getIvar:@"EncryptIsPossible"] boolValue])
            setEncrypt = NO;
        
        imageName = setEncrypt ? ENCRYPT_LOCK_LOCKED_IMAGE : ENCRYPT_LOCK_UNLOCKED_IMAGE;
    }
    [self.control setImage:[NSImage imageNamed:imageName] forSegment:0];
}

- (void)updateStatusFromImage:(NSImage *)image {
    // setImage is gonna be called a lot of times from the HeadersEditor after
    // -[HeadersEditor securityControlChanged:] was received, but always tries
    // to change it to the old status (before the click).
    // That's why GPGMail forces the right image to be always set regardless from what the HeadersEditor
    // wants.
    ComposeBackEnd *backEnd = [(MailDocumentEditor *)[[((NSSegmentedControl *)self.control) target] valueForKey:@"_documentEditor"] backEnd];
    
    if(self.securityTag == SECURITY_BUTTON_SIGN_TAG) {
        self.forcedImageName = [[image name] isEqualToString:SIGN_OFF_IMAGE] ? SIGN_ON_IMAGE : SIGN_OFF_IMAGE;
        BOOL forceSign = NO;
        if([[image name] isEqualToString:SIGN_OFF_IMAGE])
            forceSign = YES;
        
        [backEnd setIvar:@"ForceSign" value:[NSNumber numberWithBool:forceSign]];
    }
    else {
        self.forcedImageName = [[image name] isEqualToString:ENCRYPT_LOCK_UNLOCKED_IMAGE] ? ENCRYPT_LOCK_LOCKED_IMAGE : ENCRYPT_LOCK_UNLOCKED_IMAGE;
        BOOL forceEncrypt = NO;
        if([[image name] isEqualToString:ENCRYPT_LOCK_UNLOCKED_IMAGE])
            forceEncrypt = YES;
        [backEnd setIvar:@"ForceEncrypt" value:[NSNumber numberWithBool:forceEncrypt]];
    }
}

- (void)dealloc {
    if(_control)
        [_control release];
    if(_forcedImageName)
        [_forcedImageName release];
    _securityTag = 0;
    
    [super dealloc];
}

@end
