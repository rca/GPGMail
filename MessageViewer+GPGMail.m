/* MessageViewer+GPGMail.m created by stephane on Tue 04-Jul-2000 */

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

#ifndef SNOW_LEOPARD
#import <MessageContentController.h>
#endif
#import "MessageViewer+GPGMail.h"
#import "GPGMailPatching.h"
#import "Message+GPGMail.h"


@interface NSTextView(GPGMail)
// In fact it is implemented in MessageTextView subclass
- (void) originalSelectAll:(id)sender;
@end

#ifdef SNOW_LEOPARD
@implementation GPGMail_MessageViewer
#else
@implementation MessageViewer(GPGMail)
#endif

- (MessageContentController *) gpgTextViewer:(id)dummy
{
#ifdef SNOW_LEOPARD
    return [self valueForKey:@"_contentController"];
#else
    return _contentController;
#endif
}

- (NSToolbar *) gpgToolbar
{
#ifdef SNOW_LEOPARD
    return [self valueForKey:@"_toolbar"];
#else
    return _toolbar;
#endif
}

#ifdef SNOW_LEOPARD
- (id) gpgTableManager
#else
- (TableViewManager *) gpgTableManager
#endif
{
#ifdef SNOW_LEOPARD
	return [self valueForKey:@"_tableManager"];
#else
    return _tableManager;
#endif
}

// Mike's hack: when replying/forwarding encrypted message, select all content before replying
// And it works!
static IMP MessageViewer__replyMessageWithType = NULL;
static IMP MessageViewer_forwardMessage = NULL;
#ifdef LEOPARD
static IMP MessageViewer_validateMenuItem = NULL;
#endif

+ (void) load
{
    MessageViewer__replyMessageWithType = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(_replyMessageWithType:), self, @selector(gpg_replyMessageWithType:), self);
    MessageViewer_forwardMessage = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(forwardMessage:), self, @selector(gpgForwardMessage:), self);
#ifdef LEOPARD
    MessageViewer_validateMenuItem = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(validateMenuItem:), self, @selector(gpgValidateMenuItem:), self);
#endif
}

- (void)gpg_replyMessageWithType:(int)fp8
{
    if(![GPGMailBundle gpgMailWorks]){
#ifdef SNOW_LEOPARD
        ((void (*)(id, SEL, int))[GPGMailSwizzler originalMethodForName:@"MessageViewer._replyMessageWithType:"])(self, _cmd, fp8);
#else
        ((void (*)(id, SEL, int))MessageViewer__replyMessageWithType)(self, _cmd, fp8);
#endif
        return;
    }
    
    // When message is encrypted and user has not selected anything, 
    // then we temporarily select all body content
#if defined(LEOPARD) || defined(TIGER)
#warning CHECK
    BOOL    changedSelection = ([self currentDisplayedMessage] != nil && [[self currentDisplayedMessage] gpgIsEncrypted] && [[self gpgTextViewer:nil] selectedText] == nil);
#else
    BOOL    changedSelection = ([self currentDisplayedMessage] != nil && [[self currentDisplayedMessage] gpgIsEncrypted] && [[self gpgTextViewer:nil] currentSelection] == nil);
#endif
    
    if(changedSelection){
        [[[self gpgTextViewer:nil] textView] originalSelectAll:nil]; // If we use -selectAll:, headers are also selected, and we don't want it, else, on deselection, headers are still selected!
    }
#ifdef SNOW_LEOPARD
    ((void (*)(id, SEL, int))[GPGMailSwizzler originalMethodForName:@"MessageViewer._replyMessageWithType:"])(self, _cmd, fp8);
#else
    ((void (*)(id, SEL, int))MessageViewer__replyMessageWithType)(self, _cmd, fp8);
#endif
    if(changedSelection){
        [[[self gpgTextViewer:nil] textView] selectText:nil];
    }
}

- (void)gpgForwardMessage:fp12
{
    if(![GPGMailBundle gpgMailWorks]){
#ifdef SNOW_LEOPARD
        ((void (*)(id, SEL, id))[GPGMailSwizzler originalMethodForName:@"MessageViewer.forwardMessage:"])(self, _cmd, fp12);
#else
        ((void (*)(id, SEL, id))MessageViewer_forwardMessage)(self, _cmd, fp12);
#endif
        return;
    }
    
#if defined(LEOPARD) || defined(TIGER)
#warning CHECK
    BOOL    changedSelection = ([self currentDisplayedMessage] != nil && [[self currentDisplayedMessage] gpgIsEncrypted] && [[self gpgTextViewer:nil] selectedText] == nil);
#else
    BOOL    changedSelection = ([self currentDisplayedMessage] != nil && [[self currentDisplayedMessage] gpgIsEncrypted] && [[self gpgTextViewer:nil] currentSelection] == nil);
#endif
    
    if(changedSelection){
        [[[self gpgTextViewer:nil] textView] originalSelectAll:nil];
    }
#ifdef SNOW_LEOPARD
    ((void (*)(id, SEL, id))[GPGMailSwizzler originalMethodForName:@"MessageViewer.forwardMessage:"])(self, _cmd, fp12);
#else
    ((void (*)(id, SEL, id))MessageViewer_forwardMessage)(self, _cmd, fp12);
#endif
    if(changedSelection){
        [[[self gpgTextViewer:nil] textView] selectText:nil];
    }
}

#ifdef LEOPARD
- (IBAction)gpgCopyMessageURL:(id)sender
{
    Message *message = [self currentDisplayedMessage];
    
    if(message != nil){
        NSPasteboard    *pb = [NSPasteboard generalPasteboard];
        NSArray         *types = [NSArray arrayWithObjects:@"public.url", NSStringPboardType, @"public.url-name", nil];
        NSString        *urlString = [message URL];
        NSString        *subject = [message subject];
        const char      *urlBytes = [urlString UTF8String];
        const char      *titleBytes = [subject UTF8String];
        
        [pb declareTypes:types owner:nil];
        [pb addTypes:types owner:nil];
        [pb setString:urlString forType:NSStringPboardType]; // Needed, because we want simple text editors to get the URL, not the subject
        [pb setData:[NSData dataWithBytes:urlBytes length:strlen(urlBytes)] forType:@"public.url"]; // Includes NSURLPBoardType
        [pb setData:[NSData dataWithBytes:titleBytes length:strlen(titleBytes)] forType:@"public.url-name"];
    }
    else
        NSBeep();
}

- (BOOL)gpgValidateMenuItem:(id)fp8
{
    if([fp8 action] == @selector(gpgCopyMessageURL:)){
        return [self currentDisplayedMessage] != nil;
    }
    else
#ifdef SNOW_LEOPARD
        return ((BOOL (*)(id, SEL, id))[GPGMailSwizzler originalMethodForName:@"MessageViewer.validateMenuItem:"])(self, _cmd, fp8);
#else
        return ((BOOL (*)(id, SEL, id))MessageViewer_validateMenuItem)(self, _cmd, fp8);
#endif
}
#endif

@end
