#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@class MessageHeaderView;
@class MessageTextContainer;

@interface MessageHeaderDisplay : NSObject <NSLayoutManagerDelegate>
{
    MessageHeaderView *headerView;
    MessageContentController *contentController;
    MessageTextContainer *specialContainer;
    NSImageView *senderImageView;
    NSString *unloadedSender;
    double oldHeaderViewWidth;
    BOOL isCalculatingAddressLines;
    BOOL isForPrinting;
    BOOL isViewingSource;
    MessageViewingState *_viewingState;
}

+ (id)copyHeadersForMessage:(id)arg1 viewingState:(id)arg2;
+ (id)_copyRSSHeadersForMessage:(id)arg1 viewingState:(id)arg2;
+ (void)_addAddressesToString:(id)arg1 addressStrings:(id)arg2 plainAddresses:(id)arg3 addressAttachments:(id)arg4 key:(id)arg5 viewingState:(id)arg6 tabPosition:(long long)arg7 range:(struct _NSRange *)arg8;
+ (void)_setSendersFromAddressAttachments:(id)arg1;
+ (void)_stripTrailingReturns:(id)arg1;
+ (void)setUpAttachmentsDescriptionForMessage:(id)arg1 viewingState:(id)arg2;
+ (id)formattedAttachmentsSizeForAttachments:(id)arg1;
+ (id)formattedAttachmentsSizeForMessage:(id)arg1;
+ (unsigned long long)numberOfAddressesThatFitOnTwoLinesAttachments:(id)arg1 strings:(id)arg2 inTextContainer:(id)arg3 withIndent:(long long)arg4 andVerticalLocation:(long long)arg5 forPrinting:(BOOL)arg6;
+ (id)linkForMoreAddressesCount:(unsigned long long)arg1 headerKey:(id)arg2 font:(id)arg3;
+ (id)copyViewingState:(id)arg1;
+ (void)setUpEncryptionAndSignatureImageForMessage:(id)arg1 viewingState:(id)arg2;
+ (id)orderedKeys:(id)arg1 withTableViewOrder:(id)arg2;
+ (id)regularParagraphStyleForTabPosition:(long long)arg1;
+ (id)regularParagraphStyleForTabPosition:(long long)arg1 paragraphSpacing:(long long)arg2;
+ (id)addressParagraphStyleForTabPosition:(long long)arg1 withLineBreakMode:(unsigned long long)arg2 forPrinting:(BOOL)arg3;
+ (void)setTabsWithPosition:(long long)arg1 inAttributedString:(id)arg2 withKeys:(id)arg3 addressKeys:(id)arg4 addressAttachments:(id)arg5 forPrinting:(BOOL)arg6;
+ (id)attributedStringOfLength:(long long)arg1 usingAttachments:(id)arg2 startingAtIndex:(long long)arg3 strings:(id)arg4 newAttachments:(id *)arg5 forPrinting:(BOOL)arg6;
+ (void)rangeOfAddresses:(struct _NSRange *)arg1 rangeOfLink:(struct _NSRange *)arg2 forKey:(id)arg3 inAttributedString:(id)arg4;
- (void)dealloc;
@property(retain) MessageViewingState *viewingState;
- (void)awakeFromNib;
- (void)setUp;
- (id)unloadedSender;
- (void)setUnloadedSender:(id)arg1;
- (void)display:(id)arg1;
- (void)prepareToRemoveView;
- (void)displayAttributedString:(id)arg1;
- (void)headerViewFrameChanged:(id)arg1;
- (void)recalculateAddressLinesShouldDisplay:(BOOL)arg1;
- (void)updateSubjectURLMatches:(id)arg1;
- (void)showAllAddressesForKey:(id)arg1;
- (BOOL)textView:(id)arg1 clickedOnLink:(id)arg2 atIndex:(unsigned long long)arg3;
- (void)adjustFontSizeBy:(long long)arg1 viewingState:(id)arg2;
- (id)selectedText;
- (void)_addressBookChanged:(id)arg1;
- (void)_addressPhotoLoaded:(id)arg1;
- (id)textView;
- (void)textView:(id)arg1 clickedOnCell:(id)arg2 event:(id)arg3 inRect:(struct CGRect)arg4 atIndex:(unsigned long long)arg5;
- (void)layoutManager:(id)arg1 didCompleteLayoutForTextContainer:(id)arg2 atEnd:(BOOL)arg3;
- (void)setIsForPrinting:(BOOL)arg1;

@end

#elif defined(SNOW_LEOPARD)

@class MessageHeaderView;
@class MessageContentController;
@class MessageTextContainer;
@class MessageViewingState;

@interface MessageHeaderDisplay : NSObject <NSLayoutManagerDelegate>
{
    MessageHeaderView *headerView;
    MessageContentController *contentController;
    MessageTextContainer *specialContainer;
    NSImageView *senderImageView;
    NSString *unloadedSender;
    float oldHeaderViewWidth;
    BOOL isCalculatingAddressLines;
    BOOL isForPrinting;
    BOOL isViewingSource;
    MessageViewingState *_viewingState;
}

+ (id)copyHeadersForMessage:(id)arg1 viewingState:(id)arg2;
+ (id)_copyRSSHeadersForMessage:(id)arg1 viewingState:(id)arg2;
+ (void)_addAddressesToString:(id)arg1 addressStrings:(id)arg2 plainAddresses:(id)arg3 addressAttachments:(id)arg4 key:(id)arg5 viewingState:(id)arg6 tabPosition:(long)arg7 range:(struct _NSRange *)arg8;
+ (void)_setSendersFromAddressAttachments:(id)arg1;
+ (void)_stripTrailingReturns:(id)arg1;
+ (void)setUpAttachmentsDescriptionForMessage:(id)arg1 viewingState:(id)arg2;
+ (id)formattedAttachmentsSizeForAttachments:(id)arg1;
+ (id)formattedAttachmentsSizeForMessage:(id)arg1;
+ (unsigned long)numberOfAddressesThatFitOnTwoLinesAttachments:(id)arg1 strings:(id)arg2 inTextContainer:(id)arg3 withIndent:(long)arg4 andVerticalLocation:(long)arg5 forPrinting:(BOOL)arg6;
+ (id)linkForMoreAddressesCount:(unsigned long)arg1 headerKey:(id)arg2 font:(id)arg3;
+ (id)copyViewingState:(id)arg1;
+ (void)setUpEncryptionAndSignatureImageForMessage:(id)arg1 viewingState:(id)arg2;
+ (id)orderedKeys:(id)arg1 withTableViewOrder:(id)arg2;
+ (id)regularParagraphStyleForTabPosition:(long)arg1;
+ (id)regularParagraphStyleForTabPosition:(long)arg1 paragraphSpacing:(long)arg2;
+ (id)addressParagraphStyleForTabPosition:(long)arg1 withLineBreakMode:(unsigned long)arg2 forPrinting:(BOOL)arg3;
+ (void)setTabsWithPosition:(long)arg1 inAttributedString:(id)arg2 withKeys:(id)arg3 addressKeys:(id)arg4 addressAttachments:(id)arg5 forPrinting:(BOOL)arg6;
+ (id)attributedStringOfLength:(long)arg1 usingAttachments:(id)arg2 startingAtIndex:(long)arg3 strings:(id)arg4 newAttachments:(id *)arg5 forPrinting:(BOOL)arg6;
+ (void)rangeOfAddresses:(struct _NSRange *)arg1 rangeOfLink:(struct _NSRange *)arg2 forKey:(id)arg3 inAttributedString:(id)arg4;
- (void)dealloc;
- (id)viewingState;
- (void)setViewingState:(id)arg1;
- (void)awakeFromNib;
- (void)setUp;
- (id)unloadedSender;
- (void)setUnloadedSender:(id)arg1;
- (void)display:(id)arg1;
- (void)prepareToRemoveView;
- (void)displayAttributedString:(id)arg1;
- (void)headerViewFrameChanged:(id)arg1;
- (void)recalculateAddressLinesShouldDisplay:(BOOL)arg1;
- (void)updateSubjectURLMatches:(id)arg1;
- (void)showAllAddressesForKey:(id)arg1;
- (BOOL)textView:(id)arg1 clickedOnLink:(id)arg2 atIndex:(unsigned long)arg3;
- (void)adjustFontSizeBy:(long)arg1 viewingState:(id)arg2;
- (id)selectedText;
- (void)_addressBookChanged:(id)arg1;
- (void)_addressPhotoLoaded:(id)arg1;
- (id)textView;
- (void)textView:(id)arg1 clickedOnCell:(id)arg2 event:(id)arg3 inRect:(struct CGRect)arg4 atIndex:(unsigned long)arg5;
- (void)layoutManager:(id)arg1 didCompleteLayoutForTextContainer:(id)arg2 atEnd:(BOOL)arg3;
- (void)setIsForPrinting:(BOOL)arg1;

@end

#elif defined(LEOPARD)

@class MessageHeaderView;
@class MessageContentController;
@class MessageTextContainer;
@class MessageViewingState;

@interface MessageHeaderDisplay : NSObject
{
    MessageHeaderView *headerView;
    MessageContentController *contentController;
    MessageTextContainer *specialContainer;
    NSImageView *senderImageView;
    NSString *unloadedSender;
    float oldHeaderViewWidth;
    BOOL isCalculatingAddressLines;
    BOOL isForPrinting;
    BOOL isViewingSource;
    MessageViewingState *_viewingState;
}

+ (id)copyHeadersForMessage:(id)fp8 viewingState:(id)fp12;
+ (id)_copyRSSHeadersForMessage:(id)fp8 viewingState:(id)fp12;
+ (void)_addAddressesToString:(id)fp8 addressStrings:(id)fp12 plainAddresses:(id)fp16 addressAttachments:(id)fp20 key:(id)fp24 viewingState:(id)fp28 tabPosition:(int)fp32 range:(struct _NSRange *)fp36;
+ (void)_setSendersFromAddressAttachments:(id)fp8;
+ (void)_stripTrailingReturns:(id)fp8;
+ (void)setUpAttachmentsDescriptionForMessage:(id)fp8 viewingState:(id)fp12;
+ (id)formattedAttachmentsSizeForAttachments:(id)fp8;
+ (id)formattedAttachmentsSizeForMessage:(id)fp8;
+ (int)numberOfAddressesThatFitOnTwoLinesAttachments:(id)fp8 strings:(id)fp12 inTextContainer:(id)fp16 withIndent:(int)fp20 andVerticalLocation:(int)fp24 forPrinting:(BOOL)fp28;
+ (id)linkForMoreAddressesCount:(int)fp8 headerKey:(id)fp12 font:(id)fp16;
+ (id)copyViewingState:(id)fp8;
+ (void)setUpEncryptionAndSignatureImageForMessage:(id)fp8 viewingState:(id)fp12;
+ (id)orderedKeys:(id)fp8 withTableViewOrder:(id)fp12;
+ (id)regularParagraphStyleForTabPosition:(int)fp8;
+ (id)regularParagraphStyleForTabPosition:(int)fp8 paragraphSpacing:(int)fp12;
+ (id)addressParagraphStyleForTabPosition:(int)fp8 withLineBreakMode:(unsigned int)fp12 forPrinting:(BOOL)fp16;
+ (void)setTabsWithPosition:(int)fp8 inAttributedString:(id)fp12 withKeys:(id)fp16 addressKeys:(id)fp20 addressAttachments:(id)fp24 forPrinting:(BOOL)fp28;
+ (id)attributedStringOfLength:(int)fp8 usingAttachments:(id)fp12 startingAtIndex:(int)fp16 strings:(id)fp20 newAttachments:(id *)fp24 forPrinting:(BOOL)fp28;
+ (void)rangeOfAddresses:(struct _NSRange *)fp8 rangeOfLink:(struct _NSRange *)fp12 forKey:(id)fp16 inAttributedString:(id)fp20;
- (void)dealloc;
- (id)viewingState;
- (void)setViewingState:(id)fp8;
- (void)awakeFromNib;
- (void)setUp;
- (id)unloadedSender;
- (void)setUnloadedSender:(id)fp8;
- (void)display:(id)fp8;
- (void)prepareToRemoveView;
- (void)displayAttributedString:(id)fp8;
- (void)headerViewFrameChanged:(id)fp8;
- (void)recalculateAddressLinesShouldDisplay:(BOOL)fp8;
- (void)updateSubjectURLMatches:(id)fp8;
- (void)showAllAddressesForKey:(id)fp8;
- (BOOL)textView:(id)fp8 clickedOnLink:(id)fp12 atIndex:(unsigned int)fp16;
- (void)adjustFontSizeBy:(int)fp8 viewingState:(id)fp12;
- (id)selectedText;
- (void)_addressBookChanged:(id)fp8;
- (void)_addressPhotoLoaded:(id)fp8;
- (id)textView;
- (void)textView:(id)fp8 clickedOnCell:(id)fp12 event:(id)fp16 inRect:(struct _NSRect)fp20 atIndex:(unsigned int)fp36;
- (void)layoutManager:(id)fp8 didCompleteLayoutForTextContainer:(id)fp12 atEnd:(BOOL)fp16;
- (void)setIsForPrinting:(BOOL)fp8;

@end

#elif defined(TIGER)

@class MessageHeaderView;
@class MessageContentController;
@class MessageTextContainer;

@interface MessageHeaderDisplay : NSObject
{
    MessageHeaderView *headerView;
    MessageContentController *contentController;
    MessageTextContainer *specialContainer;
    NSImageView *senderImageView;
    NSString *unloadedSender;
    float oldHeaderViewWidth;
    BOOL isCalculatingAddressLines;
    BOOL isForPrinting;
    BOOL isViewingSource;
}

+ (id)copyHeadersForMessage:(id)fp8 viewingState:(id)fp12;
+ (void)setUpAttachmentsDescriptionForMessage:(id)fp8 viewingState:(id)fp12;
+ (id)formattedAttachmentsSizeForAttachments:(id)fp8;
+ (id)formattedAttachmentsSizeForMessage:(id)fp8;
+ (int)numberOfAddressesThatFitOnTwoLinesAttachments:(id)fp8 strings:(id)fp12 inTextContainer:(id)fp16 withIndent:(int)fp20 andVerticalLocation:(int)fp24 forPrinting:(BOOL)fp28;
+ (id)linkForMoreAddressesCount:(int)fp8 headerKey:(id)fp12 font:(id)fp16;
+ (id)copyViewingState:(id)fp8;
+ (void)setUpEncryptionAndSignatureImageForMessage:(id)fp8 viewingState:(id)fp12;
+ (id)orderedKeys:(id)fp8 withTableViewOrder:(id)fp12;
+ (id)regularParagraphStyleForTabPosition:(int)fp8;
+ (id)regularParagraphStyleForTabPosition:(int)fp8 paragraphSpacing:(int)fp12;
+ (id)addressParagraphStyleForTabPosition:(int)fp8 withLineBreakMode:(int)fp12 forPrinting:(BOOL)fp16;
+ (void)setTabsWithPosition:(int)fp8 inAttributedString:(id)fp12 withKeys:(id)fp16 addressKeys:(id)fp20 addressAttachments:(id)fp24 forPrinting:(BOOL)fp28;
+ (id)attributedStringOfLength:(int)fp8 usingAttachments:(id)fp12 startingAtIndex:(int)fp16 strings:(id)fp20 newAttachments:(id *)fp24 forPrinting:(BOOL)fp28;
+ (void)rangeOfAddresses:(struct _NSRange *)fp8 rangeOfLink:(struct _NSRange *)fp12 forKey:(id)fp16 inAttributedString:(id)fp20;
- (void)dealloc;
- (void)awakeFromNib;
- (void)setUp;
- (void)display:(id)fp8;
- (void)prepareToRemoveView;
- (void)displayAttributedString:(id)fp8;
- (void)headerViewFrameChanged:(id)fp8;
- (void)recalculateAddressLinesShouldDisplay:(BOOL)fp8;
- (void)showAllAddressesForKey:(id)fp8;
- (id)textView:(id)fp8 willWriteSelectionToPasteboard:(id)fp12 type:(id)fp16;
- (BOOL)textView:(id)fp8 clickedOnLink:(id)fp12 atIndex:(unsigned int)fp16;
- (void)adjustFontSizeBy:(int)fp8 viewingState:(id)fp12;
- (id)selectedText;
- (id)textView:(id)fp8 dragImageForSelectionWithEvent:(id)fp12 origin:(struct _NSPoint *)fp16;
- (id)dragImageForSelection;
- (void)textViewDidSelectAll:(id)fp8;
- (void)selectAll;
- (void)textView:(id)fp8 setSelectedRange:(struct _NSRange)fp12 affinity:(int)fp20 stillSelecting:(BOOL)fp24;
- (void)messageTextIsChangingSelectionToRange:(struct _NSRange)fp8;
- (void)_addressPhotoLoaded:(id)fp8;
- (id)textView;
- (void)textView:(id)fp8 clickedOnCell:(id)fp12 event:(id)fp16 inRect:(struct _NSRect)fp20 atIndex:(unsigned int)fp36;
- (void)textView:(id)fp8 draggedCell:(id)fp12 inRect:(struct _NSRect)fp16 event:(id)fp32 atIndex:(unsigned int)fp36;
- (void)layoutManager:(id)fp8 didCompleteLayoutForTextContainer:(id)fp12 atEnd:(BOOL)fp16;
- (void)setIsForPrinting:(BOOL)fp8;

@end

#else

@class MessageHeaderView;
@class MessageContentController;
@class MessageTextContainer;

@interface MessageHeaderDisplay:NSObject
{
    MessageHeaderView *headerView;	// 4 = 0x4
    MessageContentController *contentController;	// 8 = 0x8
    MessageTextContainer *specialContainer;	// 12 = 0xc
    NSImageView *senderImageView;	// 16 = 0x10
    NSString *unloadedSender;	// 20 = 0x14
    float oldHeaderViewWidth;	// 24 = 0x18
    char isCalculatingAddressLines;	// 28 = 0x1c
    char isForPrinting;	// 29 = 0x1d
    char isViewingSource;	// 30 = 0x1e
}

+ copyHeadersForMessage:fp8 viewingState:fp12;
+ (void)setUpAttachmentsDescriptionForMessage:fp8 viewingState:fp12;
+ formattedAttachmentsSizeForAttachments:fp8;
+ formattedAttachmentsSizeForMessage:fp8;
+ (int)numberOfAddressesThatFitOnTwoLinesAttachments:fp8 strings:fp12 inTextContainer:fp16 withIndent:(int)fp20 andVerticalLocation:(int)fp24 forPrinting:(char)fp28;
+ linkForMoreAddressesCount:(int)fp8 headerKey:fp12;
+ copyViewingState:fp8;
+ (void)setUpEncryptionAndSignatureImageForMessage:fp8 viewingState:fp12;
+ orderedKeys:fp8 withTableViewOrder:fp12;
+ regularParagraphStyleForTabPosition:(int)fp8;
+ addressParagraphStyleForTabPosition:(int)fp8 withLineBreakMode:(int)fp12 forPrinting:(char)fp16;
+ (void)setTabsWithPosition:(int)fp8 inAttributedString:fp12 withKeys:fp16 addressKeys:fp20 addressAttachments:fp24 forPrinting:(char)fp28;
+ attributedStringOfLength:(int)fp8 usingAttachments:fp12 startingAtIndex:(int)fp16 strings:fp20 newAttachments:(id *)fp24 forPrinting:(char)fp28;
+ (void)rangeOfAddresses:(struct _NSRange *)fp8 rangeOfLink:(struct _NSRange *)fp12 forKey:fp16 inAttributedString:fp20;
- (void)dealloc;
- (void)awakeFromNib;
- (void)setUp;
- (void)display:fp8;
- (void)prepareToRemoveView;
- (void)displayAttributedString:fp8;
- (void)headerViewFrameChanged:fp8;
- (void)recalculateAddressLinesShouldDisplay:(char)fp8;
- (void)showAllAddressesForKey:fp8;
- textView:fp8 willWriteSelectionToPasteboard:fp12 type:fp16;
- (char)textView:fp8 clickedOnLink:fp12 atIndex:(unsigned int)fp16;
- selectedText;
- textView:fp8 dragImageForSelectionWithEvent:fp12 origin:(struct _NSPoint *)fp16;
- dragImageForSelection;
- (void)textViewDidSelectAll:fp8;
- (void)selectAll;
- (void)textView:fp8 setSelectedRange:(struct _NSRange)fp12 affinity:(int)fp20 stillSelecting:(char)fp24;
- (void)messageTextIsChangingSelectionToRange:(struct _NSRange)fp8;
- (void)_addressPhotoLoaded:fp8;
- textView;
- (void)textView:fp8 clickedOnCell:fp12 event:fp16 inRect:(struct _NSRect)fp20 atIndex:(unsigned int)fp36;
- (void)textView:fp8 draggedCell:fp12 inRect:(struct _NSRect)fp16 event:fp32 atIndex:(unsigned int)fp36;
- (void)layoutManager:fp8 didCompleteLayoutForTextContainer:fp12 atEnd:(char)fp16;
- (void)setIsForPrinting:(char)fp8;

@end

#endif
