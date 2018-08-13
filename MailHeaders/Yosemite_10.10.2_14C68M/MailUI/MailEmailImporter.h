/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "FilesystemEmailImporter.h"

#import "MFAddProgressMonitor.h"

@class ImportItem, NSString;

@interface MailEmailImporter : FilesystemEmailImporter <MFAddProgressMonitor>
{
    ImportItem *_currentItem;
    unsigned long long _currentItemMessageIndex;
    unsigned long long _currentItemMessageCount;
    unsigned long long _currentBlockSize;
}

+ (id)explanatoryText;
+ (id)name;
@property(nonatomic) unsigned long long currentBlockSize; // @synthesize currentBlockSize=_currentBlockSize;
@property(nonatomic) unsigned long long currentItemMessageCount; // @synthesize currentItemMessageCount=_currentItemMessageCount;
@property(nonatomic) unsigned long long currentItemMessageIndex; // @synthesize currentItemMessageIndex=_currentItemMessageIndex;
@property(nonatomic) __weak ImportItem *currentItem; // @synthesize currentItem=_currentItem;
- (void).cxx_destruct;
- (void)setFractionDone:(double)arg1;
- (id)mailboxNameForImportItem:(id)arg1;
- (void)importMailbox:(id)arg1;
- (BOOL)isValidMailbox:(id)arg1;
- (id)pathExtensions;
- (id)prepareForImport;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

