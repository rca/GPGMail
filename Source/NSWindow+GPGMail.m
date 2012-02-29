/* NSWindow+GPGMail.m created by Lukas Pitschl (@lukele) on Mon 27-Feb-2012 */

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

#import "MailDocumentEditor.h"
#import "MailDocumentEditor+GPGMail.h"
#import "NSWindow+GPGMail.h"

@implementation NSWindow (GPGMail)

- (void)addAccessoryView:(NSView *)accessoryView {
    NSView *themeFrame = [[self contentView] superview];
    [self positionAccessoryView:accessoryView];
    [themeFrame addSubview:accessoryView];
}

- (void)positionAccessoryView:(NSView *)accessoryView {
    NSView *themeFrame = [[self contentView] superview];
    NSRect c = [themeFrame frame];	// c for "container"
    NSRect aV = [accessoryView frame];	// aV for "accessory view"
    // 4 point from the top, 6.0px from the very right.
    //NSPoint offset = NSMakePoint(6.0f, 4.0f);
    NSPoint offset = NSMakePoint(-0.0f, -0.0f);
    
    NSRect newFrame = NSMakeRect(
                                 c.size.width - aV.size.width - offset.x,	// x position
                                 c.size.height - aV.size.height - offset.y,	// y position
                                 aV.size.width,	// width
                                 aV.size.height);	// height
    
    [accessoryView setFrame:newFrame];
}

- (void)MAToggleFullScreen:(id)sender {
    NSLog(@"Sender: %@", sender);
    // Loop through all document editors and remove the security method
    // accessory view, so there's no animation glitch.
    for(MailDocumentEditor *editor in [NSClassFromString(@"MailDocumentEditor") documentEditors]) {
        if(editor.isModal)
            [((MailDocumentEditor_GPGMail *)editor) removeSecurityMethodAccessoryView];
    }
    [self MAToggleFullScreen:sender];
}

@end
