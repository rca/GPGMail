/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */

#import "Quota.h"

#import "NSTableViewDataSource-Protocol.h"
#import "NSTableViewDelegate-Protocol.h"

@class NSButton, NSMutableArray, NSMutableAttributedString, NSMutableDictionary, NSPopUpButton;

@interface POPQuota : Quota <NSTableViewDataSource, NSTableViewDelegate>
{
    NSPopUpButton *_showMessagesPopup;
    NSButton *_deleteButton;
    NSMutableAttributedString *_truncatedString;
    NSMutableDictionary *_truncatedParagraphStyle;
    struct QuotaSimpleSortDescriptor _simpleSortDescs[5];
    NSMutableArray *_messageIDs;
}

- (id)initWithAccount:(id)arg1;
- (void)awakeFromNib;
- (void)dealloc;
- (Class)engineClass;
- (void)deleteFromServer:(id)arg1;
- (void)_deleteMessagesSheetDidEnd:(id)arg1 returnCode:(long long)arg2 contextInfo:(void *)arg3;
- (BOOL)_shouldShowMessage:(id)arg1 showMessageType:(long long)arg2;
- (id)_filterMessages:(id)arg1 showMessageType:(long long)arg2;
- (void)_updateUsageField;
- (void)showMessagesPopupChanged:(id)arg1;
- (id)_account;
- (void)engineDidStart;
- (void)engineDidFinish;
- (void)engineUpdated:(id)arg1;
- (unsigned long long)numberOfSortDescriptors;
- (const struct QuotaSimpleSortDescriptor *)sortDescriptorAtIndex:(unsigned long long)arg1;
- (long long)numberOfRowsInTableView:(id)arg1;
- (id)_truncatedAttributedStringForString:(id)arg1;
- (id)tableView:(id)arg1 objectValueForTableColumn:(id)arg2 row:(long long)arg3;
- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forTableColumn:(id)arg3 row:(long long)arg4;
- (void)tableView:(id)arg1 sortDescriptorsDidChange:(id)arg2;
- (void)tableViewSelectionDidChange:(id)arg1;
- (void)_syncSortDescriptors;
- (void)_resortMessages;
- (long long)_addMessage:(id)arg1;
- (BOOL)_updateMessage:(id)arg1;
- (void)_deleteServerMessagesStarted:(id)arg1;
- (void)_deleteServerMessagesCompleted:(id)arg1;

@end

