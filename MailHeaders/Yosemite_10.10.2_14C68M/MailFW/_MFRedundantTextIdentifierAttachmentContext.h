/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

@class NSString;

@interface _MFRedundantTextIdentifierAttachmentContext : NSObject
{
    BOOL _attachmentIsDownloaded;
    NSString *_attachmentName;
    NSString *_attachmentExtension;
    unsigned long long _attachmentSize;
}

@property(readonly, nonatomic) BOOL attachmentIsDownloaded; // @synthesize attachmentIsDownloaded=_attachmentIsDownloaded;
@property(readonly, nonatomic) unsigned long long attachmentSize; // @synthesize attachmentSize=_attachmentSize;
@property(readonly, copy, nonatomic) NSString *attachmentExtension; // @synthesize attachmentExtension=_attachmentExtension;
@property(readonly, copy, nonatomic) NSString *attachmentName; // @synthesize attachmentName=_attachmentName;
- (void).cxx_destruct;
- (BOOL)isEqualTo:(id)arg1;
- (id)description;
- (id)initWithAttachmentName:(id)arg1 attachmentSize:(unsigned long long)arg2 attachmentIsDownloaded:(BOOL)arg3;

@end

