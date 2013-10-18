/* LibraryStore+GPGMail.m created by Lukas Pitschl (@lukele) on Thu 26-Aug-2011 */

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

#import <Message.h>
#import <MimeBody.h>
#import "NSObject+LPDynamicIvars.h"
#import "NSData+GPGMail.h"
#import "Message+GPGMail.h"
#import "LibraryStore+GPGMail.h"

//@implementation LibraryStore (GPGMail)

/**
 Whenever a list of messages is supposed to be displayed,
 the library store is checked for already available snippets.
 
 A dictionary is returned which contains the snippet for every message
 a snippet is available already.
 For every message from the original list not included in the returned
 dictionary, the snippet is re-created.
 
 In case of S/MIME encrypted messages, the message is not included in the dictionary,
 which forces the snippet to be re-created. The re-creation process decrypts the
 message and correctly returns a snippet for the decrypted message body.
 
 In case of PGP encrypted messages, Mail.app includes them in the returned dictionary.
 To force the re-creation of a snippet from the decrypted message body, each message
 is checked for PGP data and if found, it's removed from the dictionary.
 
 And voila!
 
 P.S.: This fixed the snippet generation, but somehow something I changed apparently made this unnecessary...
       Let's see what others report.
 
 */
//- (id)MASnippetsForMessages:(id)messages {
//    // This seems to be the best place to remove the additional attachments,
//    // since it's called whenever the user selects another mailbox. decodeWithContext is too late.
//    // This might be heavy, but the information should be cached, so theoretically no biggy.
//    id ret = [self MASnippetsForMessages:messages];
//    
//    if(ret) {
//        CFMutableDictionaryRef snippetDictionaryRef = CFDictionaryCreateMutableCopy(NULL, 0, (CFDictionaryRef)ret);
//        NSMutableDictionary *snippetDictionary = (NSMutableDictionary *)snippetDictionaryRef;
//        NSLog(@"Return dict: %@", ret);
//        for(id key in ret) {
//            NSData *bodyData = [(Message *)key bodyDataFetchIfNotAvailable:YES allowPartial:NO];
//            BOOL containsPGPData = [bodyData rangeOfPGPInlineEncryptedData].location != NSNotFound || 
//                                   [bodyData rangeOfPGPSignatures].location != NSNotFound;
//            
//            
//            if(containsPGPData) {
//                // Check if the message was not processed.
//                if(![key ivarExists:@"PGPMessageProcessed"])
//                    [snippetDictionary removeObjectForKey:key];
//            }
//        }
//        ret = [snippetDictionary autorelease];
//    }
//    
//    return ret;
//}

//@end
