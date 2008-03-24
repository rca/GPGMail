#import <Cocoa/Cocoa.h>

#ifdef LEOPARD

//extern NSString	*MessageWillBeDisplayedInView;
//extern NSString *MessageWillNoLongerBeDisplayedInView;
// Object is MessageContentController
// UserInfo:
// MessageKey = Message
// MessageViewKey = MessageTextView

@class Message;
@class ActivityMonitor;
@class MimeBody;
@class MFError;
@class TextMessageDisplay;
@class MessageHeaderDisplay;
@class AttachmentsView;
@class ObjectCache;
@class InvocationQueue;
@class MessageViewingState;
@class EmbeddedNoteDocumentEditor;

@protocol DocumentEditorManaging
- (void)registerDocumentEditor:(id)fp8;
- (void)unregisterDocumentEditor:(id)fp8;
@end

@protocol MessageContentDisplay <NSObject>
+ (id)copyDocumentForMessage:(id)fp8 viewingState:(id)fp12;
- (id)contentView;
- (id)textView;
- (void)display:(id)fp8 inContainerView:(id)fp12 replacingView:(id)fp16 invokeWhenDisplayChanged:(id)fp20;
- (void)prepareToRemoveView;
- (void)highlightSearchText:(id)fp8;
- (id)selectedText;
- (id)selectedTextRepresentation;
- (void)setSelectedTextRepresentation:(id)fp8;
- (id)selectedWebArchive;
- (id)attachmentsInSelection;
- (id)webArchiveBaseURL:(id *)fp8;
- (void)adjustFontSizeBy:(int)fp8 viewingState:(id)fp12;
- (id)findTarget;
- (struct __CFDictionary *)stringsForURLification;
- (void)updateURLMatches:(id)fp8 viewingState:(id)fp12;
- (void)detectDataInMessage:(id)fp8 usingContext:(id)fp12;
- (id)delegate;
- (void)setDelegate:(id)fp8;
@end

@interface MessageViewingState : NSObject
{
    NSAttributedString *_headerAttributedString;
    NSDictionary *_addressAttachments;
    NSDictionary *_plainAddresses;
    NSSet *_expandedAddressKeys;
    NSAttributedString *_attachmentsDescription;
    NSArray *_headerOrder;
    NSArray *_attachments;
    Message *_message;
    ActivityMonitor *_monitor;
    MimeBody *mimeBody;
    id document;
    MFError *error;
    int headerIndent;
    int headerFontAdjustmentDebt;
    unsigned int preferredAlternative:23;
    unsigned int accountWasOffline:1;
    unsigned int dontCache:1;
    unsigned int showAllHeaders:1;
    unsigned int showDefaultHeaders:1;
    unsigned int isPrinting:1;
    unsigned int viewSource:1;
    unsigned int showControlChars:1;
    unsigned int showAttachments:1;
    unsigned int downloadRemoteURLs:1;
    unsigned int triedToDownloadRemoteURLs:1;
    unsigned int messageIsFromMicrosoft:1;
    unsigned int isChildRequestForSenders:1;
    int displayType;
    unsigned int preferredEncoding;
    NSString *sender;
    NSString *senderName;
    int priority;
    NSString *childAddress;
    NSArray *requestedAddressesFromChild;
    id <MessageContentDisplay> displayer;
    id editor;
}

+ (void)initialize;
- (void)release;
- (void)dealloc;
- (id)init;
- (id)editor;
- (void)setEditor:(id)fp8;
- (void)editorClosed:(id)fp8;
- (id)mimeBody;
- (id)attachments;
- (id)headerAttributedString;
- (void)setHeaderAttributedString:(id)fp8;
- (id)plainAddresses;
- (void)setPlainAddresses:(id)fp8;
- (id)addressAttachments;
- (void)setAddressAttachments:(id)fp8;
- (id)expandedAddressKeys;
- (void)setExpandedAddressKeys:(id)fp8;
- (id)attachmentsDescription;
- (void)setAttachmentsDescription:(id)fp8;
- (id)headerOrder;
- (void)setHeaderOrder:(id)fp8;
- (int)headerDetailLevel;
- (id)description;
- (id)monitor;
- (void)setMonitor:(id)fp8;
- (id)message;
- (void)setMessage:(id)fp8;

@end

@interface MessageContentController : NSResponder <DocumentEditorManaging>
{
    Message *_message;
    ActivityMonitor *_documentMonitor;
    ActivityMonitor *_urlificationMonitor;
    id <MessageContentDisplay> _currentDisplay;
    id <MessageContentDisplay> _threadDisplay;
    TextMessageDisplay *textDisplay;
    MessageHeaderDisplay *headerDisplay;
    NSView *contentContainerView;
    NSView *junkMailView;
    NSTextField *junkMailMessageField;
    NSButton *junkMailLoadHTMLButton;
    NSView *loadImagesView;
    NSBox *bannerBorderBox;
    NSView *certificateView;
    NSImageView *certificateImage;
    NSTextField *certificateMessageField;
    NSButton *certificateHelpButton;
    NSView *childBannerView;
    NSTextField *childBannerMessageField;
    NSImageView *childBannerImage;
    NSButton *childBannerButton;
    NSButton *childBannerHelpButton;
    NSView *parentBannerView;
    NSTextField *parentBannerMessageField;
    NSImageView *parentBannerImage;
    NSButton *parentBannerButton;
    AttachmentsView *attachmentsView;
    ObjectCache *_documentCache;
    InvocationQueue *invocationQueue;
    double _foregroundLoadStartTime;
    double _backgroundLoadStartTime;
    double _backgroundLoadEndTime;
    NSString *_messageIDToRestoreInitialStateFor;
    struct _NSRect _initialVisibleRect;
    struct _NSRange _initialSelectedRange;
    NSArray *mostRecentHeaderOrder;
    NSTimer *_fadeTimer;
    NSView *_currentBanner;
    BOOL _hideBannerBorder;
    NSTextField *_widthResizableTextFieldInCurrentBanner;
    NSView *_rightNeighborOfWidthResizableTextFieldInCurrentBanner;
    BOOL isForPrinting;
    BOOL showDefaultHeadersStickily;
    MessageViewingState *stickyViewingState;
    MessageViewingState *_viewingState;
    NSMutableDictionary *_editorCache;
    EmbeddedNoteDocumentEditor *_currentEditor;
    NSDictionary *_URLificationStrings;
    NSLock *_URLificationLock;
    float _accumulatedMagnification;
    BOOL _canZoomIn;
    BOOL _canZoomOut;
}

+ (void)setClass:(Class)fp8 forDisplayType:(id)fp12;
- (id)init;
- (id)documentEditors;
- (void)registerDocumentEditor:(id)fp8;
- (void)unregisterDocumentEditor:(id)fp8;
- (void)setIsForPrinting:(BOOL)fp8;
- (void)setContentContainerView:(id)fp8;
- (void)setLoadImagesView:(id)fp8;
- (void)setJunkMailView:(id)fp8;
- (void)setCertificateView:(id)fp8;
- (void)setChildBannerView:(id)fp8;
- (void)setParentBannerView:(id)fp8;
- (void)readDefaultsFromDictionary:(id)fp8;
- (void)writeDefaultsToDictionary:(id)fp8;
- (void)setEditorCache:(id)fp8;
- (void)release;
- (void)dealloc;
- (void)_stopBackgroundMessageLoading:(BOOL)fp8 URLification:(BOOL)fp12 dataDetection:(BOOL)fp16;
- (void)stopAllActivity;
- (id)documentView;
- (id)currentDisplay;
- (void)_updateIfDisplayingMessage:(id)fp8;
- (id)viewingState;
- (void)setViewingState:(id)fp8;
- (void)_fetchDataForMessageAndUpdateDisplay:(id)fp8;
- (void)_messageMayHaveBecomeAvailable;
- (id)_messageTilingView;
- (void)fadeToEmpty;
- (void)_pushDocumentToCache;
- (void)_startBackgroundURLification:(id)fp8;
- (void)_backgroundLoadFinished:(id)fp8;
- (void)_backgroundUrlificationFinished:(id)fp8 urlMatches:(id)fp12;
- (void)setMessage:(id)fp8 headerOrder:(id)fp12;
- (void)_setMessage:(id)fp8 headerOrder:(id)fp12;
- (void)fetchEditorForMessage:(id)fp8 viewingState:(id)fp12;
- (void)editorDidLoad:(id)fp8;
- (void)editorFailedLoad:(id)fp8;
- (id)existingEditor:(Class)fp8 forDocument:(id)fp12;
- (void)_fetchContentsForMessage:(id)fp8 fromStore:(id)fp12 withViewingState:(id)fp16;
- (BOOL)canAddNoteToMessage;
- (BOOL)canAddToDoToMessage;
- (void)webMessageController:(id)fp8 willDisplayMenuItems:(id)fp12;
- (void)addAssociatedToDo:(id)fp8;
- (void)_urlifyWithViewingState:(id)fp8;
- (void)_startBackgroundLoad:(id)fp8;
- (void)_setInvocationQueue:(id)fp8;
- (id)message;
- (void)setMostRecentHeaderOrder:(id)fp8;
- (void)reloadCurrentMessage;
- (void)viewerPreferencesChanged:(id)fp8;
- (void)_removeCurrentBanner;
- (void)_bannerResized:(id)fp8;
- (void)_contentViewResized:(id)fp8;
- (void)_showBannerView:(id)fp8;
- (void)_showLoadImagesBanner;
- (void)_showCertificateBanner;
- (void)_showJunkBanner;
- (BOOL)_showBannerIfMessageIsOutgoingMessageWaitingForParentApproval;
- (BOOL)_showBannerIfMessageIsPermissionRequestFromChild;
- (void)_updateBanner;
- (void)setShowBannerBorder:(BOOL)fp8;
- (void)setShowRevealMessageLink:(BOOL)fp8;
- (BOOL)showRevealMessageLink;
- (void)_addRecentAddress:(id)fp8;
- (void)markAsNotJunkMailClicked:(id)fp8;
- (void)_setJunkLevelToNotJunk;
- (void)approveChildRequest:(id)fp8;
- (void)rejectChildRequest:(id)fp8;
- (void)sendMessage:(id)fp8;
- (void)_messageFlagsDidChange:(id)fp8;
- (void)closeEditors;
- (id)editorForNote:(id)fp8 message:(id)fp12;
- (id)editorForNote:(id)fp8 message:(id)fp12 isPaperless:(BOOL)fp16 willLoad:(char *)fp20;
- (void)_updateEditorDisplay;
- (id)_dataDetectorsContextForMessage:(id)fp8;
- (void)_updateDisplay;
- (void)editorClosed:(id)fp8;
- (void)setCurrentEditor:(id)fp8;
- (void)_setCurrentDisplay:(id)fp8;
- (void)_displayChanged;
- (void)highlightSearchText:(id)fp8;
- (id)attachmentsView;
- (id)textView;
- (id)selectedText;
- (id)selectedWebArchive;
- (id)attachmentsInSelection;
- (id)webArchiveBaseURL:(id *)fp8;
- (void)clearCache;
- (void)clearCacheForMessage:(id)fp8;
- (void)removeCacheObjectForKey:(id)fp8;
- (void)setCacheObject:(id)fp8 forKey:(id)fp12;
- (id)cacheObjectForKey:(id)fp8;
- (id)viewingStateForMessage:(id)fp8;
- (void)cacheViewingState:(id)fp8 forMessage:(id)fp12;
- (void)initPrintInfo;
- (int)headerDetailLevel;
- (BOOL)showingAllHeaders;
- (void)setShowAllHeaders:(BOOL)fp8;
- (BOOL)remoteAttachmentsAreDownloaded;
- (void)makeStickyInfoFromViewingState:(id)fp8;
- (void)makeStickyShowDefaultHeaders;
- (void)keyDown:(id)fp8;
- (void)resetGestureState;
- (void)beginGestureWithEvent:(id)fp8;
- (void)endGestureWithEvent:(id)fp8;
- (void)magnifyWithEvent:(id)fp8;
- (BOOL)pageDown;
- (BOOL)pageUp;
- (BOOL)currentlyViewingSource;
- (BOOL)_validateAction:(SEL)fp8 tag:(int)fp12;
- (id)findTarget;
- (BOOL)validateToolbarItem:(id)fp8;
- (BOOL)validateMenuItem:(id)fp8;
- (void)showAllHeaders:(id)fp8;
- (void)showFilteredHeaders:(id)fp8;
- (void)viewSource:(id)fp8;
- (void)toggleShowControlCharacters:(id)fp8;
- (void)toggleAttachmentsArea:(id)fp8;
- (void)showFirstAlternative:(id)fp8;
- (void)showPreviousAlternative:(id)fp8;
- (void)showNextAlternative:(id)fp8;
- (void)_messageWouldHaveLoadedRemoteURL:(id)fp8;
- (void)downloadRemoteContent:(id)fp8;
- (void)showCertificate:(id)fp8;
- (void)certificateTrustSheetDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)showBestAlternative:(id)fp8;
- (void)changeTextEncoding:(id)fp8;
- (void)makeFontBigger:(id)fp8;
- (void)makeFontSmaller:(id)fp8;
- (void)jumpToSelection:(id)fp8;
- (void)takeFindStringFromSelection:(id)fp8;
- (void)saveAttachments:(id)fp8;
- (void)saveAttachmentsWithoutPrompting:(id)fp8;
- (id)urlificationMonitor;
- (void)setUrlificationMonitor:(id)fp8;
- (id)documentMonitor;
- (void)setDocumentMonitor:(id)fp8;
- (id)currentEditor;
- (id)editorCache;

@end

#elif defined(TIGER)

@class Message;
@class MessageTextView;
@class MessageTextContainer;
@class HTMLView;

extern NSString	*MessageWillBeDisplayedInView;
extern NSString *MessageWillNoLongerBeDisplayedInView;
// Object is MessageContentController
// UserInfo:
// MessageKey = Message
// MessageViewKey = MessageTextView

@class ActivityMonitor;
@class ObjectCache;
@class InvocationQueue;
@class MFError;
@class MimeBody;
@class TextMessageDisplay;
@class MessageHeaderDisplay;
@class AttachmentsView;

@interface MessageViewingState : NSObject
{
    NSAttributedString *_headerAttributedString;
    NSDictionary *_addressAttachments;
    NSDictionary *_plainAddresses;
    NSSet *_expandedAddressKeys;
    NSAttributedString *_attachmentsDescription;
    NSArray *_headerOrder;
    MimeBody *mimeBody;
    id document;
    MFError *error;
    int headerIndent;
    int headerFontAdjustmentDebt;
    unsigned int preferredAlternative:23;
    unsigned int accountWasOffline:1;
    unsigned int dontCache:1;
    unsigned int showAllHeaders:1;
    unsigned int showDefaultHeaders:1;
    unsigned int isPrinting:1;
    unsigned int viewSource:1;
    unsigned int showControlChars:1;
    unsigned int showAttachments:1;
    unsigned int downloadRemoteURLs:1;
    unsigned int triedToDownloadRemoteURLs:1;
    unsigned int urlificationDone:1;
    unsigned int messageIsFromEntourage:1;
    unsigned int preferredEncoding;
    ActivityMonitor *monitor;
    NSString *sender;
    NSString *senderName;
    int priority;
    id displayer;
}

+ (void)initialize;
- (void)dealloc;
- (id)init;
- (id)mimeBody;
- (id)headerAttributedString;
- (void)setHeaderAttributedString:(id)fp8;
- (id)plainAddresses;
- (void)setPlainAddresses:(id)fp8;
- (id)addressAttachments;
- (void)setAddressAttachments:(id)fp8;
- (id)expandedAddressKeys;
- (void)setExpandedAddressKeys:(id)fp8;
- (id)attachmentsDescription;
- (void)setAttachmentsDescription:(id)fp8;
- (id)headerOrder;
- (void)setHeaderOrder:(id)fp8;
- (int)headerDetailLevel;

@end

@interface MessageContentController : NSResponder
{
    Message *_message;
    MessageViewingState *_viewingState;
    ActivityMonitor *_documentMonitor;
    id _currentDisplay;
    id _threadDisplay;
    TextMessageDisplay *textDisplay;
    MessageHeaderDisplay *headerDisplay;
    NSView *contentContainerView;
    NSView *junkMailView;
    NSTextField *junkMailMessageField;
    NSButton *junkMailLoadHTMLButton;
    NSView *loadImagesView;
    NSButton *loadImagesButton;
    NSBox *bannerBorderBox;
    NSView *certificateView;
    NSButton *certificateButton;
    NSImageView *certificateImage;
    NSTextField *certificateMessageField;
    NSView *childBannerView;
    NSTextField *childBannerMessageField;
    NSImageView *childBannerImage;
    NSButton *childBannerButton;
    NSButton *childBannerHelpButton;
    NSView *parentBannerView;
    NSTextField *parentBannerMessageField;
    NSImageView *parentBannerImage;
    NSButton *parentBannerButton;
    NSView *parentApprovedOrRejectedBannerView;
    NSTextField *parentApprovedOrRejectedBannerMessageField;
    NSImageView *parentApprovedOrRejectedBannerImage;
    AttachmentsView *attachmentsView;
    ObjectCache *_documentCache;
    InvocationQueue *invocationQueue;
    double _foregroundLoadStartTime;
    double _backgroundLoadStartTime;
    double _backgroundLoadEndTime;
    NSString *_messageIDToRestoreInitialStateFor;
    struct _NSRect _initialVisibleRect;
    struct _NSRange _initialSelectedRange;
    NSArray *mostRecentHeaderOrder;
    NSTimer *_fadeTimer;
    NSView *_currentBanner;
    BOOL _hideBannerBorder;
    NSTextField *_widthResizableTextFieldInCurrentBanner;
    NSView *_rightNeighborOfWidthResizableTextFieldInCurrentBanner;
    BOOL isForPrinting;
    BOOL showDefaultHeadersStickily;
    MessageViewingState *stickyViewingState;
}

+ (void)setClass:(Class)fp8 forDisplayType:(id)fp12;
- (id)init;
- (void)setIsForPrinting:(BOOL)fp8;
- (void)setContentContainerView:(id)fp8;
- (void)setLoadImagesView:(id)fp8;
- (void)setJunkMailView:(id)fp8;
- (void)setCertificateView:(id)fp8;
- (void)setChildBannerView:(id)fp8;
- (void)setParentBannerView:(id)fp8;
- (void)setParentApprovedOrRejectedBannerView:(id)fp8;
- (void)readDefaultsFromDictionary:(id)fp8;
- (void)writeDefaultsToDictionary:(id)fp8;
- (void)dealloc;
- (void)stopAllActivity;
- (id)documentView;
- (id)currentDisplay;
- (void)_updateIfDisplayingMessage:(id)fp8;
- (void)_fetchDataForMessageAndUpdateDisplay:(id)fp8;
- (void)_messageMayHaveBecomeAvailable;
- (id)_messageTilingView;
- (void)fadeToEmpty;
- (void)_pushDocumentToCache;
- (void)_backgroundLoadFinished:(id)fp8;
- (void)_backgroundUrlificationFinished:(id)fp8 urlMatches:(id)fp12;
- (void)setMessage:(id)fp8 headerOrder:(id)fp12;
- (void)_setMessage:(id)fp8 headerOrder:(id)fp12;
- (void)_fetchContentsForMessage:(id)fp8 fromStore:(id)fp12 withViewingState:(id)fp16;
- (void)_startBackgroundLoad:(id)fp8;
- (id)message;
- (void)setMostRecentHeaderOrder:(id)fp8;
- (void)reloadCurrentMessage;
- (void)viewerPreferencesChanged:(id)fp8;
- (void)showJunkMailHelp:(id)fp8;
- (void)_removeCurrentBanner;
- (void)_bannerResized:(id)fp8;
- (void)_showBannerView:(id)fp8;
- (void)_showLoadImagesBanner;
- (void)_showCertificateBanner;
- (id)_fixBezelStyleOfHelpButtonInBannerView:(id)fp8;
- (void)_showJunkBanner;
- (BOOL)_showBannerIfMessageIsOutgoingMessageWaitingForParentApproval;
- (BOOL)_showBannerIfMessageIsPermissionRequestFromChild;
- (void)_updateBanner;
- (void)setShowBannerBorder:(BOOL)fp8;
- (void)setShowRevealMessageLink:(BOOL)fp8;
- (BOOL)showRevealMessageLink;
- (void)_addRecentAddress:(id)fp8;
- (void)markAsNotJunkMailClicked:(id)fp8;
- (void)_setJunkLevelToNotJunk;
- (void)approveChildRequest:(id)fp8;
- (void)rejectChildRequest:(id)fp8;
- (void)sendMessage:(id)fp8;
- (void)_messageFlagsDidChange:(id)fp8;
- (void)_updateDisplay;
- (void)_setCurrentDisplay:(id)fp8;
- (void)highlightSearchText:(id)fp8;
- (id)attachmentsView;
- (id)textView;
- (id)selectedText;
- (id)selectedWebArchive;
- (id)attachmentsInSelection;
- (id)webArchive;
- (void)clearCache;
- (id)viewingState;
- (id)viewingStateForMessage:(id)fp8;
- (void)cacheViewingState:(id)fp8 forMessage:(id)fp12;
- (void)displayString:(id)fp8;
- (void)initPrintInfo;
- (int)headerDetailLevel;
- (BOOL)showingAllHeaders;
- (void)setShowAllHeaders:(BOOL)fp8;
- (void)makeStickyInfoFromViewingState:(id)fp8;
- (void)makeStickyShowDefaultHeaders;
- (void)keyDown:(id)fp8;
- (BOOL)pageDown;
- (BOOL)pageUp;
- (BOOL)currentlyViewingSource;
- (BOOL)_validateAction:(SEL)fp8 tag:(int)fp12;
- (id)findTarget;
- (BOOL)validateToolbarItem:(id)fp8 forSegment:(int)fp12;
- (BOOL)validateMenuItem:(id)fp8;
- (void)showAllHeaders:(id)fp8;
- (void)showFilteredHeaders:(id)fp8;
- (void)viewSource:(id)fp8;
- (void)toggleShowControlCharacters:(id)fp8;
- (void)toggleAttachmentsArea:(id)fp8;
- (void)showFirstAlternative:(id)fp8;
- (void)showPreviousAlternative:(id)fp8;
- (void)showNextAlternative:(id)fp8;
- (void)_messageWouldHaveLoadedRemoteURL:(id)fp8;
- (void)downloadRemoteContent:(id)fp8;
- (void)showCertificate:(id)fp8;
- (void)showBestAlternative:(id)fp8;
- (void)changeTextEncoding:(id)fp8;
- (void)makeFontBigger:(id)fp8;
- (void)makeFontSmaller:(id)fp8;
- (void)jumpToSelection:(id)fp8;
- (void)takeFindStringFromSelection:(id)fp8;
- (void)saveAttachments:(id)fp8;

@end

#else

@class Message;
@class MessageViewingState;
@class ActivityMonitor;
@class TextMessageDisplay;
@class MessageHeaderDisplay;
@class AttachmentsView;
@class ObjectCache;
@class InvocationQueue;
@class MimeBody;
@class MFError;


@protocol MessageContentDisplay <NSObject>
- (void)updateURLMatches:fp8 viewingState:fp12;
- findTarget;
- (void)adjustFontSizeBy:(int)fp8 viewingState:fp12;
- selectedText;
- (void)highlightSearchText:fp8;
- (void)prepareToRemoveView;
- (void)display:fp8 inContainerView:fp12 replacingView:fp16;
- textView;
- contentView;
@end

extern NSString	*MessageWillBeDisplayedInView;
// Object is MessageContentController
// UserInfo:
// 	MessageKey = Message
// 	MessageViewKey = MessageTextView
extern NSString	*MessageWillNoLongerBeDisplayedInView;
// Object is MessageContentController
// UserInfo:
// 	MessageKey = Message
// 	MessageViewKey = MessageTextView

@interface MessageViewingState:NSObject
{
    @public
    NSAttributedString *_headerAttributedString;	// 4 = 0x4
    NSDictionary *_addressAttachments;	// 8 = 0x8
    NSDictionary *_plainAddresses;	// 12 = 0xc
    NSSet *_expandedAddressKeys;	// 16 = 0x10
    NSAttributedString *_attachmentsDescription;	// 20 = 0x14
    NSArray *_headerOrder;	// 24 = 0x18
    MimeBody *mimeBody;	// 28 = 0x1c
    id document;	// 32 = 0x20
    MFError *error;	// 36 = 0x24
    int headerIndent;	// 40 = 0x28
    int preferredAlternative:23;	// 44 = 0x2c
    int accountWasOffline:1;	// 46 = 0x2e
    int dontCache:1;	// 47 = 0x2f
    int showAllHeaders:1;	// 47 = 0x2f
    int showDefaultHeaders:1;	// 47 = 0x2f
    int isPrinting:1;	// 47 = 0x2f
    int viewSource:1;	// 47 = 0x2f
    int showControlChars:1;	// 47 = 0x2f
    int showAttachments:1;	// 47 = 0x2f
    int downloadRemoteURLs:1;	// 47 = 0x2f
    int triedToDownloadRemoteURLs:1;	// 48 = 0x30
    int urlificationDone:1;	// 48 = 0x30
    unsigned int preferredEncoding;	// 52 = 0x34
    ActivityMonitor *monitor;	// 56 = 0x38
    NSString *sender;	// 60 = 0x3c
    id displayer;	// 64 = 0x40
}

+ (void)initialize;
- (void)dealloc;
- init;
- mimeBody;
- headerAttributedString;
- (void)setHeaderAttributedString:fp8;
- plainAddresses;
- (void)setPlainAddresses:fp8;
- addressAttachments;
- (void)setAddressAttachments:fp8;
- expandedAddressKeys;
- (void)setExpandedAddressKeys:fp8;
- attachmentsDescription;
- (void)setAttachmentsDescription:fp8;
- headerOrder;
- (void)setHeaderOrder:fp8;

@end

@interface MessageContentController:NSResponder
{
    Message *_message;	// 8 = 0x8
    MessageViewingState *_viewingState;	// 12 = 0xc
    ActivityMonitor *_documentMonitor;	// 16 = 0x10
    id _currentDisplay;	// 20 = 0x14
    id _threadDisplay;	// 24 = 0x18
    TextMessageDisplay *textDisplay;	// 28 = 0x1c
    MessageHeaderDisplay *headerDisplay;	// 32 = 0x20
    NSView *contentContainerView;	// 36 = 0x24
    NSView *junkMailView;	// 40 = 0x28
    NSTextField *junkMailMessageField;	// 44 = 0x2c
    NSButton *junkMailLoadHTMLButton;	// 48 = 0x30
    NSView *loadImagesView;	// 52 = 0x34
    NSButton *loadImagesButton;	// 56 = 0x38
    NSBox *bannerBorderBox;	// 60 = 0x3c
    NSView *certificateView;	// 64 = 0x40
    NSButton *certificateButton;	// 68 = 0x44
    NSImageView *certificateImage;	// 72 = 0x48
    NSTextField *certificateMessageField;	// 76 = 0x4c
    AttachmentsView *attachmentsView;	// 80 = 0x50
    ObjectCache *_documentCache;	// 84 = 0x54
    InvocationQueue *invocationQueue;	// 88 = 0x58
    double _foregroundLoadStartTime;	// 92 = 0x5c
    double _backgroundLoadStartTime;	// 100 = 0x64
    double _backgroundLoadEndTime;	// 108 = 0x6c
    NSString *_messageIDToRestoreInitialStateFor;	// 116 = 0x74
    struct _NSRect_initialVisibleRect;	// 120 = 0x78
    struct _NSRange _initialSelectedRange;	// 136 = 0x88
    NSArray *mostRecentHeaderOrder;	// 144 = 0x90
    NSTimer *_fadeTimer;	// 148 = 0x94
    NSView *_currentBanner;	// 152 = 0x98
    char _hideBannerBorder;	// 156 = 0x9c
    char isForPrinting;	// 157 = 0x9d
    char showAllHeadersStickily;	// 158 = 0x9e
    char showDefaultHeadersStickily;	// 159 = 0x9f
}

+ (void)setClass:(Class)fp8 forDisplayType:fp12;
- init;
- (void)setIsForPrinting:(char)fp8;
- (void)setContentContainerView:fp8;
- (void)setLoadImagesView:fp8;
- (void)setJunkMailView:fp8;
- (void)setCertificateView:fp8;
- (void)readDefaultsFromDictionary:fp8;
- (void)writeDefaultsToDictionary:fp8;
- (void)dealloc;
- (void)stopAllActivity;
- documentView;
- currentDisplay;
- (void)_messageMayHaveBecomeAvailable;
- (void)fadeToEmpty;
- (void)_pushDocumentToCache;
- (void)_backgroundLoadFinished:fp8;
- (void)_backgroundUrlificationFinished:fp8 urlMatches:fp12;
- (void)setMessage:fp8 headerOrder:fp12;
- (void)_setMessage:fp8 headerOrder:fp12;
- (void)_fetchContentsForMessage:fp8 fromStore:fp12 withViewingState:fp16;
- (void)_startBackgroundLoad:fp8;
- message;
- (void)setMostRecentHeaderOrder:fp8;
- (void)reloadCurrentMessage;
- (void)viewerPreferencesChanged:fp8;
- (void)showJunkMailHelp:fp8;
- (void)_removeCurrentBanner;
- (void)_showBannerView:fp8;
- (void)_showLoadImagesBanner;
- (void)_showCertificateBanner;
- (void)_showJunkBanner;
- (void)_updateBanner;
- (void)setShowBannerBorder:(char)fp8;
- (void)_addRecentAddress:fp8;
- (void)markAsNotJunkMailClicked:fp8;
- (void)_messageFlagsDidChange:fp8;
- (void)_updateDisplay;
- (void)_setCurrentDisplay:fp8;
- (void)highlightSearchText:fp8;
- attachmentsView;
- textView;
- currentSelection;
- (void)clearCache;
- viewingState;
- viewingStateForMessage:fp8;
- (void)cacheViewingState:fp8 forMessage:fp12;
- (void)displayString:fp8;
- (void)initPrintInfo;
- (int)headerDetailLevel;
- (char)showingAllHeaders;
- (void)setShowAllHeaders:(char)fp8;
- (void)makeStickyShowAllHeaders;
- (void)makeStickyShowDefaultHeaders;
- (void)keyDown:fp8;
- (char)pageDown;
- (char)pageUp;
- (char)currentlyViewingSource;
- (char)_validateAction:(SEL)fp8 tag:(int)fp12;
- findTarget;
- (char)validateToolbarItem:fp8;
- (BOOL)validateMenuItem:fp8;
- (void)showAllHeaders:fp8;
- (void)showFilteredHeaders:fp8;
- (void)viewSource:fp8;
- (void)toggleShowControlCharacters:fp8;
- (void)toggleAttachmentsArea:fp8;
- (void)showFirstAlternative:fp8;
- (void)showPreviousAlternative:fp8;
- (void)showNextAlternative:fp8;
- (void)_messageWouldHaveLoadedRemoteURL:fp8;
- (void)downloadRemoteContent:fp8;
- (void)showCertificate:fp8;
- (void)showBestAlternative:fp8;
- (void)changeTextEncoding:fp8;
- (void)makeFontBigger:fp8;
- (void)makeFontSmaller:fp8;
- (void)jumpToSelection:fp8;
- (void)takeFindStringFromSelection:fp8;

@end

#endif
