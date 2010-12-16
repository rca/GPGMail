#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@class MessageHeaderView;
@class MessageTextContainer;

@interface MessageHeaderDisplay : NSObject <NSLayoutManagerDelegate>
{
	MessageHeaderView * headerView;
	MessageContentController * contentController;
	MessageTextContainer * specialContainer;
	NSImageView * senderImageView;
	NSString * unloadedSender;
	double oldHeaderViewWidth;
	BOOL isCalculatingAddressLines;
	BOOL isForPrinting;
	BOOL isViewingSource;
	MessageViewingState * _viewingState;
}

+ (id)copyHeadersForMessage:(id) arg1 viewingState:(id)arg2;
+ (id)_copyRSSHeadersForMessage:(id) arg1 viewingState:(id)arg2;
+ (void)_addAddressesToString:(id) arg1 addressStrings:(id) arg2 plainAddresses:(id) arg3 addressAttachments:(id) arg4 key:(id) arg5 viewingState:(id) arg6 tabPosition:(long long)arg7 range:(struct _NSRange *)arg8;
+ (void)_setSendersFromAddressAttachments:(id)arg1;
+ (void)_stripTrailingReturns:(id)arg1;
+ (void)setUpAttachmentsDescriptionForMessage:(id) arg1 viewingState:(id)arg2;
+ (id)formattedAttachmentsSizeForAttachments:(id)arg1;
+ (id)formattedAttachmentsSizeForMessage:(id)arg1;
+ (unsigned long long)numberOfAddressesThatFitOnTwoLinesAttachments:(id) arg1 strings:(id) arg2 inTextContainer:(id) arg3 withIndent:(long long)arg4 andVerticalLocation:(long long)arg5 forPrinting:(BOOL)arg6;
+ (id)linkForMoreAddressesCount:(unsigned long long)arg1 headerKey:(id) arg2 font:(id)arg3;
+ (id)copyViewingState:(id)arg1;
+ (void)setUpEncryptionAndSignatureImageForMessage:(id) arg1 viewingState:(id)arg2;
+ (id)orderedKeys:(id) arg1 withTableViewOrder:(id)arg2;
+ (id)regularParagraphStyleForTabPosition:(long long)arg1;
+ (id)regularParagraphStyleForTabPosition:(long long)arg1 paragraphSpacing:(long long)arg2;
+ (id)addressParagraphStyleForTabPosition:(long long)arg1 withLineBreakMode:(unsigned long long)arg2 forPrinting:(BOOL)arg3;
+ (void)setTabsWithPosition:(long long)arg1 inAttributedString:(id) arg2 withKeys:(id) arg3 addressKeys:(id) arg4 addressAttachments:(id) arg5 forPrinting:(BOOL)arg6;
+ (id)attributedStringOfLength:(long long)arg1 usingAttachments:(id) arg2 startingAtIndex:(long long)arg3 strings:(id) arg4 newAttachments:(id *)arg5 forPrinting:(BOOL)arg6;
+ (void)rangeOfAddresses:(struct _NSRange *)arg1 rangeOfLink:(struct _NSRange *)arg2 forKey:(id) arg3 inAttributedString:(id)arg4;
- (void)dealloc;
@property (retain) MessageViewingState * viewingState;
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
- (BOOL)textView:(id) arg1 clickedOnLink:(id) arg2 atIndex:(unsigned long long)arg3;
- (void)adjustFontSizeBy:(long long)arg1 viewingState:(id)arg2;
- (id)selectedText;
- (void)_addressBookChanged:(id)arg1;
- (void)_addressPhotoLoaded:(id)arg1;
- (id)textView;
- (void)textView:(id) arg1 clickedOnCell:(id) arg2 event:(id) arg3 inRect:(struct CGRect)arg4 atIndex:(unsigned long long)arg5;
- (void)layoutManager:(id) arg1 didCompleteLayoutForTextContainer:(id) arg2 atEnd:(BOOL)arg3;
- (void)setIsForPrinting:(BOOL)arg1;

@end

#elif defined(SNOW_LEOPARD)

@class MessageHeaderView;
@class MessageContentController;
@class MessageTextContainer;
@class MessageViewingState;

@interface MessageHeaderDisplay : NSObject <NSLayoutManagerDelegate>
{
	MessageHeaderView * headerView;
	MessageContentController * contentController;
	MessageTextContainer * specialContainer;
	NSImageView * senderImageView;
	NSString * unloadedSender;
	float oldHeaderViewWidth;
	BOOL isCalculatingAddressLines;
	BOOL isForPrinting;
	BOOL isViewingSource;
	MessageViewingState * _viewingState;
}

+ (id)copyHeadersForMessage:(id) arg1 viewingState:(id)arg2;
+ (id)_copyRSSHeadersForMessage:(id) arg1 viewingState:(id)arg2;
+ (void)_addAddressesToString:(id) arg1 addressStrings:(id) arg2 plainAddresses:(id) arg3 addressAttachments:(id) arg4 key:(id) arg5 viewingState:(id) arg6 tabPosition:(long)arg7 range:(struct _NSRange *)arg8;
+ (void)_setSendersFromAddressAttachments:(id)arg1;
+ (void)_stripTrailingReturns:(id)arg1;
+ (void)setUpAttachmentsDescriptionForMessage:(id) arg1 viewingState:(id)arg2;
+ (id)formattedAttachmentsSizeForAttachments:(id)arg1;
+ (id)formattedAttachmentsSizeForMessage:(id)arg1;
+ (unsigned long)numberOfAddressesThatFitOnTwoLinesAttachments:(id) arg1 strings:(id) arg2 inTextContainer:(id) arg3 withIndent:(long)arg4 andVerticalLocation:(long)arg5 forPrinting:(BOOL)arg6;
+ (id)linkForMoreAddressesCount:(unsigned long)arg1 headerKey:(id) arg2 font:(id)arg3;
+ (id)copyViewingState:(id)arg1;
+ (void)setUpEncryptionAndSignatureImageForMessage:(id) arg1 viewingState:(id)arg2;
+ (id)orderedKeys:(id) arg1 withTableViewOrder:(id)arg2;
+ (id)regularParagraphStyleForTabPosition:(long)arg1;
+ (id)regularParagraphStyleForTabPosition:(long)arg1 paragraphSpacing:(long)arg2;
+ (id)addressParagraphStyleForTabPosition:(long)arg1 withLineBreakMode:(unsigned long)arg2 forPrinting:(BOOL)arg3;
+ (void)setTabsWithPosition:(long)arg1 inAttributedString:(id) arg2 withKeys:(id) arg3 addressKeys:(id) arg4 addressAttachments:(id) arg5 forPrinting:(BOOL)arg6;
+ (id)attributedStringOfLength:(long)arg1 usingAttachments:(id) arg2 startingAtIndex:(long)arg3 strings:(id) arg4 newAttachments:(id *)arg5 forPrinting:(BOOL)arg6;
+ (void)rangeOfAddresses:(struct _NSRange *)arg1 rangeOfLink:(struct _NSRange *)arg2 forKey:(id) arg3 inAttributedString:(id)arg4;
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
- (BOOL)textView:(id) arg1 clickedOnLink:(id) arg2 atIndex:(unsigned long)arg3;
- (void)adjustFontSizeBy:(long)arg1 viewingState:(id)arg2;
- (id)selectedText;
- (void)_addressBookChanged:(id)arg1;
- (void)_addressPhotoLoaded:(id)arg1;
- (id)textView;
- (void)textView:(id) arg1 clickedOnCell:(id) arg2 event:(id) arg3 inRect:(struct CGRect)arg4 atIndex:(unsigned long)arg5;
- (void)layoutManager:(id) arg1 didCompleteLayoutForTextContainer:(id) arg2 atEnd:(BOOL)arg3;
- (void)setIsForPrinting:(BOOL)arg1;

@end

#endif // ifdef SNOW_LEOPARD_64
