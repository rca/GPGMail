/* Library+GPGMail.m created by Lukas Pitschl (@lukele) on Wed 13-Jun-2013 */

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

#import "Library+GPGMail.h"
#import "GPGFlaggedString.h"

@implementation Library_GPGMail

/** ONLY FOR Mavericks and then on MFLibrary. */
+ (id)MAPlistDataForMessage:(id)message subject:(id)subject sender:(id)sender to:(id)to dateSent:(id)dateSent dateReceived:(id)dateReceived dateLastViewed:(id)dateLastViewed remoteID:(id)remoteID originalMailboxURLString:(id)originalMailboxURLString gmailLabels:(id)gmailLabels flags:(long long)flags mergeWithDictionary:(id)mergeWithDictionary {
    if([sender isKindOfClass:[GPGFlaggedString class]])
        sender = [(GPGFlaggedString *)sender description];
    if([to isKindOfClass:[GPGFlaggedString class]])
        to = [(GPGFlaggedString *)to description];
    
    return [self MAPlistDataForMessage:message subject:subject sender:sender to:to dateSent:dateSent dateReceived:dateReceived dateLastViewed:dateLastViewed remoteID:remoteID originalMailboxURLString:originalMailboxURLString gmailLabels:gmailLabels flags:flags mergeWithDictionary:mergeWithDictionary];
}

+ (id)MAPlistDataForMessage:(id)message subject:(id)subject sender:(id)sender to:(id)to dateSent:(id)dateSent remoteID:(id)remoteID originalMailbox:(id)originalMailbox flags:(long long)flags mergeWithDictionary:(id)mergeWithDictionary {
    if([sender isKindOfClass:[GPGFlaggedString class]])
        sender = [(GPGFlaggedString *)sender description];
    if([to isKindOfClass:[GPGFlaggedString class]])
        to = [(GPGFlaggedString *)to description];
    
    return [self MAPlistDataForMessage:message subject:subject sender:sender to:to dateSent:dateSent remoteID:remoteID originalMailbox:originalMailbox flags:flags mergeWithDictionary:mergeWithDictionary];
}

@end
