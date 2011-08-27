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
#import <MailAccount.h>
#import <MailDocumentEditor.h>
#import "GPGTitlebarAccessoryView.h"
#import "MailDocumentEditor+GPGMail.h"

@implementation MailDocumentEditor_GPGMail

- (void)MABackEndDidLoadInitialContent:(id)content {
    // If no account exists for signing, don't draw anything.
    if(![MailAccount accountExistsForSigning])
        return [self MABackEndDidLoadInitialContent:content];
    
    //    [[GPGOptions sharedOptions] addObserver:self forKeyPath:@"UseOpenPGPToSend" options:NSKeyValueObservingOptionNew context:nil];
    
    [self drawEncryptionMethodHint];
    
    [self MABackEndDidLoadInitialContent:content];
}

- (void)drawEncryptionMethodHint {
    NSString *encryptionMethod = nil;
    NSRect textFrame;
    BOOL monochrome = ![[GPGOptions sharedOptions] boolForKey:@"UseNonMonochromeEncryptionMethodHint"];
    if([[GPGOptions sharedOptions] boolForKey:@"UseOpenPGPToSend"]) {
        encryptionMethod = @"OpenPGP";
        if(monochrome)
            textFrame = NSMakeRect(15.0, -2.0, 80.0f, 17.0f);
        else
            textFrame = NSMakeRect(11.0, -2.0, 80.0f, 17.0f);
    }
    else {
        encryptionMethod = @"S/MIME";
        if(monochrome)
            textFrame = NSMakeRect(25.0, -2.0, 80.0f, 17.0f);
        else
            textFrame = NSMakeRect(17.0, -2.0, 80.0f, 17.0f);
    }
    GPGTitlebarAccessoryView *accessoryView = [[GPGTitlebarAccessoryView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 80.0f, 17.0f)];
    accessoryView.monochrome = monochrome;
    accessoryView.title = encryptionMethod;
    accessoryView.titleView.frame = textFrame;
    
    
    NSWindow *window = [self valueForKey:@"_window"];
    NSView *themeFrame = [[window contentView] superview];
    NSRect c = [themeFrame frame];	// c for "container"
    NSRect aV = [accessoryView frame];	// aV for "accessory view"
    // 4 point from the top, 6.0px from the very right.
    //NSPoint offset = NSMakePoint(6.0f, 4.0f);
    NSPoint offset = NSMakePoint(0.0f, 0.0f);
    
    NSRect newFrame = NSMakeRect(
                                 c.size.width - aV.size.width - offset.x,	// x position
                                 c.size.height - aV.size.height - offset.y,	// y position
                                 aV.size.width,	// width
                                 aV.size.height);	// height
    
    [accessoryView setFrame:newFrame];
    [themeFrame addSubview:accessoryView];
    
    [accessoryView release];
}

@end
