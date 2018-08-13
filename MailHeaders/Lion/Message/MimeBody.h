/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "MessageBody.h"

@class MimePart, NSData;

@interface MimeBody : MessageBody
{
    MimePart *_topLevelPart;
    unsigned int _preferredTextEncoding;
    NSData *_bodyData;
    long long _preferredAlternative;
    long long _numAlternatives;
}

+ (void)initialize;
+ (id)versionString;
+ (id)newMimeBoundary;
- (id)attributedString;
- (id)init;
- (void)dealloc;
- (id)topLevelPart;
- (void)setTopLevelPart:(id)arg1;
- (id)allPartsEnumerator;
- (id)attachmentPartsEnumerator;
- (unsigned int)preferredTextEncoding;
- (void)setPreferredTextEncoding:(unsigned int)arg1;
- (BOOL)isSignedByMe;
- (id)mimeType;
- (id)mimeSubtype;
- (id)partWithNumber:(id)arg1;
- (void)calculateNumberOfAttachmentsIfNeeded;
- (BOOL)_isPossiblySignedOrEncrypted;
- (void)decodeIfNecessaryWithContext:(id)arg1;
- (void)decodeIfNecessary;
- (BOOL)hasAttachments;
- (unsigned int)numberOfAttachmentsSigned:(char *)arg1 encrypted:(char *)arg2 numberOfTNEFAttachments:(unsigned int *)arg3;
- (id)attachments;
- (id)attachmentsWithContext:(id)arg1;
- (id)attachmentViewControllers;
- (id)attachmentFilenames;
- (BOOL)isHTML;
- (BOOL)isRich;
- (BOOL)isMultipartRelated;
- (BOOL)isTextPlain;
- (long long)numberOfAlternatives;
- (void)setPreferredAlternative:(long long)arg1;
- (long long)preferredAlternative;
- (id)preferredAlternativePart;
- (id)preferredBodyPart;
- (id)textHtmlPart;
- (id)webArchive;
- (id)parsedMessage;
- (id)parsedMessageWithContext:(id)arg1;
- (id)dataForMimePart:(id)arg1;
- (id)bodyData;
- (void)setBodyData:(id)arg1;
- (void)flushCachedData;
- (void)renderStringForJunk:(id)arg1;
- (void)renderString:(id)arg1;

@end

