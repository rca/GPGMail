/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSTextAttachment.h"

@interface NSTextAttachment (MCMimeSupport)
- (id)internalAppleAttachmentData;
- (BOOL)shouldDownloadAttachmentOnDisplay;
- (BOOL)isPlaceholder;
- (BOOL)hasBeenDownloaded;
- (id)mimePart;
- (unsigned long long)approximateSize;
@end

