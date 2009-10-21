#import <Cocoa/Cocoa.h>

#ifdef LEOPARD

@class WebViewEditor;
@class HeadersEditor;
@class EditingMessageWebView;
@class ComposeBackEnd;
@class EditingWebMessageController;
@class LoadingOverlay;
@class MailDocumentEditor;
@class OldCompletionController;
@class ComposeHeaderView;
@class AccountStatusDataSource;
@class AddressTextField;
@class DraggingTextView;
@class DeliveryFailure;
@class ColorBackgroundView;
@class StationerySelector;
@class StationeryAnimator;
@class Stationery;
@class AccountStatusDataSource;
@class AccountStatusDataSource;
@class AccountStatusDataSource;

@interface MessageEditor : NSObject
{
}

+ (id)sharedMessageEditor;
- (id)init;
- (id)retain;
- (unsigned int)retainCount;
- (void)release;
- (id)autorelease;
- (id)objectSpecifier;
- (void)setBackEnd:(id)fp8;

@end

@interface DocumentEditor : NSObject
{
    WebViewEditor *webViewEditor;
    HeadersEditor *headersEditor;
    NSWindow *_window;
    EditingMessageWebView *composeWebView;
    ComposeBackEnd *_backEnd;
    NSToolbar *_toolbar;
    NSMutableDictionary *_toolbarItems;
    EditingWebMessageController *webMessageController;
    LoadingOverlay *loadingOverlay;
    NSDictionary *settings;
    struct {
        unsigned int userSavedMessage:1;
        unsigned int userWantsToCloseWindow:1;
        unsigned int userKnowsSaveFailed:1;
        unsigned int registeredForNotifications:1;
        unsigned int alwaysSave:1;
        unsigned int userCanApplyStationery:1;
        unsigned int autoShowEditor:1;
        unsigned int isLoaded:1;
        unsigned int isAutoSaving:1;
    } _flags;
    int _messageType;
#ifdef SNOW_LEOPARD
    struct CGPoint _originalCascadePoint;
#else
    struct _NSPoint _originalCascadePoint;
#endif
    NSMutableDictionary *_bodiesByAttachmentURL;
    NSOperationQueue *operationQueue;
    NSOperation *loadInterfaceOperation;
    NSOperation *showInterfaceOperation;
    NSOperation *prepareContentOperation;
    NSOperation *loadInitialDocumentOperation;
    NSOperation *finishLoadingEditorOperation;
    id _loadDelegate;
    double _lastSaveTime;
}

+ (void)initialize;
+ (id)autoSaveTimer;
+ (void)setAutosaveTimer:(id)fp8;
+ (id)_documentEditors;
+ (id)documentEditors;
+ (id)typedDocumentEditors;
+ (void)registerDocumentEditor:(id)fp8;
+ (void)unregisterDocumentEditor:(id)fp8;
+ (int)documentType;
+ (id)documentWebPreferences;
+ (id)existingEditorForMessage:(id)fp8 editorClass:(Class)fp12;
+ (id)editorsForDocumentID:(id)fp8 editorClass:(Class)fp12;
+ (id)existingEditorForMessage:(id)fp8;
+ (void)saveDefaults;
+ (void)restoreFromDefaults;
+ (void)showEditorWithSavedState:(id)fp8;
+ (void)setNeedsAutosave;
+ (void)autoSaveTimerFired;
- (id)documentID;
- (BOOL)isEditingDocumentID:(id)fp8;
- (id)description;
- (id)initWithType:(int)fp8 settings:(id)fp12 backEnd:(id)fp16;
- (BOOL)isLoaded;
- (void)setLoaded:(BOOL)fp8;
- (BOOL)isAutoSaving;
- (BOOL)load;
- (id)loadInterfaceOperation;
- (id)showInterfaceOperation;
- (id)prepareContentOperation;
- (id)loadInitialDocumentOperation;
- (void)loadInitialDocument;
- (id)finishLoadingEditorOperation;
- (BOOL)isFinishedLoading;
- (void)markFinishedLoading;
- (void)performOperationAfterLoad:(id)fp8;
- (void)finishLoadingEditor;
- (void)setShowInterfaceOperation:(id)fp8;
- (void)setLoadInterfaceOperation:(id)fp8;
- (void)setPrepareContentOperation:(id)fp8;
- (void)setLoadInitialDocumentOperation:(id)fp8;
- (void)setFinishLoadingEditorOperation:(id)fp8;
- (Class)backEndClass;
- (void)release;
- (void)dealloc;
- (BOOL)loadEditorNib;
- (id)operationQueue;
- (void)setOperationQueue:(id)fp8;
- (int)editorSharedNib;
- (void)show;
- (void)setHeaders:(id)fp8;
- (id)backEnd;
- (void)setBackEnd:(id)fp8;
- (id)webViewEditor;
- (id)headersEditor;
- (id)webMessageDocument;
- (id)toolbar;
- (id)window;
- (BOOL)autoShowEditor;
- (void)setAutoShowEditor:(BOOL)fp8;
- (BOOL)userCanApplyStationery;
- (void)setUserCanApplyStationery:(BOOL)fp8;
- (BOOL)wantsToClose;
- (void)setWantsToClose:(BOOL)fp8;
- (void)readDefaultsFromDictionary:(id)fp8;
- (void)writeDefaultsToDictionary:(id)fp8;
- (void)saveState;
- (void)_appendDefaultsToArray:(id)fp8;
- (id)_frameSaveName;
- (void)prepareContent;
- (void)backEndDidLoadInitialContent:(id)fp8;
- (id)webArchiveFromSettings:(id)fp8;
- (void)continueLoadingInitialContent;
- (void)postDocumentEditorDidFinishSetup;
- (void)_registerForNotificationsIfNeeded;
- (void)_setupSpellingAndGrammarChecking;
- (id)windowWillReturnFieldEditor:(id)fp8 toObject:(id)fp12;
- (void)backEnd:(id)fp8 didBeginBackgroundLoadActivity:(id)fp12;
- (void)loadingOverlayDidEnd:(id)fp8 returnCode:(int)fp12;
- (BOOL)autoSave;
- (BOOL)canSave;
- (BOOL)shouldSave;
- (void)saveMessageDueToUserAction:(BOOL)fp8;
- (void)backEnd:(id)fp8 willCreateMessageWithHeaders:(id)fp12;
- (BOOL)backEnd:(id)fp8 shouldSaveMessage:(id)fp12;
- (void)setUserSavedMessage:(BOOL)fp8;
- (BOOL)hasChanges;
- (void)reportSaveFailure:(id)fp8;
- (id)associatedMessage;
- (void)backEnd:(id)fp8 didUpdateMessage:(id)fp12;
- (void)backEndDidSaveMessage:(id)fp8 result:(int)fp12;
- (void)failedToSaveDraftSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)backEndDidChange:(id)fp8;
- (void)webViewDidChange:(id)fp8;
- (void)updateWindowContent;
- (void)updateUIAfterAppleScriptModification:(id)fp8;
- (void)composePrefsChanged;
- (void)mailAttachmentsAdded:(id)fp8;
- (void)openPanelSheetDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (id)mimeBodyForAttachmentWithURL:(id)fp8;
- (BOOL)validateAction:(SEL)fp8 tag:(int)fp12;
- (BOOL)validateMenuItem:(id)fp8;
- (void)makeRichText:(id)fp8;
- (void)makePlainText:(id)fp8;
- (void)toggleRich:(id)fp8;
- (void)insertNumberedList:(id)fp8;
- (void)insertBulletedList:(id)fp8;
- (void)convertToNumberedList:(id)fp8;
- (void)convertToBulletedList:(id)fp8;
- (void)increaseListNestingLevel:(id)fp8;
- (void)decreaseListNestingLevel:(id)fp8;
- (void)saveDocument:(id)fp8;
- (void)saveChangedDocument:(id)fp8;
- (void)saveMessageToDrafts:(id)fp8;
- (void)performClose:(id)fp8;
- (void)messageSizeDidChange:(id)fp8;
- (void)insertFile:(id)fp8;
- (void)removeAttachments:(id)fp8;
- (void)createToDo:(id)fp8;
- (void)changeTextEncoding:(id)fp8;
- (void)showPrintPanel:(id)fp8;
- (void)searchIndex:(id)fp8;
- (void)changeSpellCheckingBehavior:(id)fp8;
- (void)toggleCheckGrammarWithSpelling:(id)fp8;
- (void)showAddressPanel:(id)fp8;
- (void)windowDidResize:(id)fp8;
- (void)windowDidMove:(id)fp8;
- (id)shouldSaveTitle;
- (id)shouldSaveDescription;
- (id)shouldSaveHelptag;
- (void)beginDocumentMove;
- (void)endDocumentMove;
- (void)documentsWillBeginTransfer:(id)fp8;
- (void)documentsDidEndTransfer:(id)fp8;
- (BOOL)windowShouldClose:(id)fp8;
- (void)forceClose;
- (void)closeConfirmSheetDidEnd:(id)fp8 returnCode:(int)fp12 forSave:(void *)fp16;
- (void)nowWouldBeAGoodTimeToTerminate:(id)fp8;
- (double)lastSaveTime;
- (void)setLastSaveTime:(double)fp8;
- (id)loadDelegate;
- (void)setLoadDelegate:(id)fp8;
- (id)settings;
- (void)setSettings:(id)fp8;

@end

@interface DocumentEditor (DocumentEditorToolbar)
- (BOOL)validateToolbarItem:(id)fp8;
- (void)setupToolbar;
- (id)toolbarIdentifier;
- (void)_synchronizeChangeReplyItem:(id)fp8 messageType:(int)fp12;
- (void)toggleReplyType:(int)fp8;
- (void)updateSendButtonStateInToolbar;
- (void)toolbarWillAddItem:(id)fp8;
- (void)configureSegmentedItem:(id)fp8 withDictionary:(id)fp12 forSegment:(int)fp16;
- (id)previousIdentifierForUpgradingToolbar:(id)fp8;
- (id)toolbar:(id)fp8 upgradedItemIdentifiers:(id)fp12;
- (id)toolbar:(id)fp8 itemForItemIdentifier:(id)fp12 willBeInsertedIntoToolbar:(BOOL)fp16;
- (id)toolbarDefaultItemIdentifiers:(id)fp8;
- (id)toolbarAllowedItemIdentifiers:(id)fp8;
- (id)menuForListsItem;
@end

@interface HeadersEditor : NSObject /*<AccountStatusDataSourceDelegate>*/
{
    MailDocumentEditor *documentEditor;
    OldCompletionController *completionController;
    ComposeHeaderView *composeHeaderView;
    NSPopUpButton *fromPopup;
    NSPopUpButton *signaturePopup;
    NSPopUpButton *priorityPopup;
    NSButton *signButton;
    NSButton *encryptButton;
    AccountStatusDataSource *_deliveryASDS;
    NSPopUpButton *deliveryPopUp;
    AddressTextField *toField;
    AddressTextField *ccField;
    NSTextField *subjectField;
    AddressTextField *bccField;
    AddressTextField *replyToField;
    DraggingTextView *addressFieldEditor;
    NSMutableArray *accessoryViewOwners;
    BOOL chatShouldBeEnabled;
    BOOL _hasChanges;
}

- (void)setUpFieldsAndButtons;
- (void)finishSetUp;
- (void)setAGoodFirstResponder;
- (void)configureButtonsAndPopUps;
- (void)initializePriorityPopUp;
- (void)composePrefsChanged;
- (void)mailAccountsDidChange;
- (void)accountInfoDidChange:(id)fp8;
- (void)windowDidBecomeKey:(id)fp8;
- (void)windowDidResignKey:(id)fp8;
- (void)updatePriorityPopUpMakeActive:(BOOL)fp8;
- (void)updateSecurityControls;
- (void)updateSignButtonImages;
- (void)updateSignButtonTooltip;
- (void)updateEncryptButtonImages;
- (void)updateEncryptButtonTooltip;
- (void)updateFromAndSignatureControls;
- (void)updateSignatureControlOverridingExistingSignature:(BOOL)fp8;
- (void)updateDeliveryAccountControl;
- (void)configureDeliveryPopupButton;
- (float)deliveryPopUpSizeToFitWidth;
- (void)updateCcOrBccMyselfFieldWithSender:(id)fp8 oldSender:(id)fp12;
- (void)updatePresenceButtonState;
- (void)presenceChanged:(id)fp8;
- (void)presencePreferenceChanged:(id)fp8;
- (void)updatePresenceButtonStateForAddresses:(id)fp8;
- (void)webViewDidLoadStationery:(id)fp8;
- (void)setupAddressField:(id)fp8;
- (void)_setupField:(id)fp8 withAddressesForKey:(id)fp12 visibleSelector:(SEL)fp16;
- (void)_configureTextField:(id)fp8 isAddressField:(BOOL)fp12;
- (id)fieldForHeader:(id)fp8;
- (id)headerKeyForView:(id)fp8;
- (void)enableCompletion:(BOOL)fp8 forTextField:(id)fp12;
- (void)loadHeadersFromBackEnd;
- (void)textFieldBeganOrEndedEditing:(id)fp8;
- (void)recipientsDidChange:(id)fp8;
- (void)subjectChanged;
- (void)addressFieldChanged;
- (BOOL)headerFieldIsNonEmpty:(id)fp8;
- (id)windowWillReturnFieldEditor:(id)fp8 toObject:(id)fp12;
- (void)setHeaders:(id)fp8;
- (void)appendAddresses:(id)fp8 toHeader:(id)fp12;
- (void)setInlineSpellCheckingEnabled:(BOOL)fp8;
- (void)setCheckGrammarWithSpelling:(BOOL)fp8;
- (void)turnOffEncryption;
- (void)changeSignatureFrom:(id)fp8 to:(id)fp12;
- (BOOL)messageIsToBeSigned;
- (BOOL)messageIsToBeEncrypted;
- (BOOL)messageHasRecipients;
- (BOOL)canSignFromAnyAccount;
- (BOOL)chatShouldBeEnabled;
- (BOOL)isOkayToSaveMessage:(id)fp8;
- (void)editServerList:(id)fp8 selectedAccount:(id)fp12;
- (void)toggleAccountLock:(id)fp8;
- (void)setSelectedAccount:(id)fp8;
- (void)setDeliveryAccount:(id)fp8;
- (id)deliveryAccount;
- (id)mailAccount;
- (void)accountStatusDidChange:(id)fp8;
- (void)changeHeaderField:(id)fp8;
- (void)changeFromHeader:(id)fp8;
- (void)setMessagePriority:(id)fp8;
- (void)securityControlChanged:(id)fp8;
- (void)_recipientsWithoutKeysSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)chatWithRecipients:(id)fp8;
- (void)editSignatures:(id)fp8;
- (void)changeSignature:(id)fp8;
- (void)composeHeaderViewWillBeginCustomization:(id)fp8;
- (void)composeHeaderViewDidEndCustomization:(id)fp8;
- (BOOL)headerCustomizationIsInProgress;
- (void)addCcHeader:(id)fp8;
- (void)addBccHeader:(id)fp8;
- (void)addReplyToHeader:(id)fp8;
- (void)_clearFieldIfHidden:(id)fp8;
- (void)prepareToCloseWindow;
- (void)dealloc;
- (BOOL)validateAction:(SEL)fp8 tag:(int)fp12;
- (BOOL)validateMenuItem:(id)fp8;
- (BOOL)validateToolbarItem:(id)fp8;
- (id)senderMarkupStringIncludeBrackets:(BOOL)fp8;
- (BOOL)hasChanges;
- (void)setHasChanges:(BOOL)fp8;

@end

@interface MailDocumentEditor : DocumentEditor
{
    DeliveryFailure *deliveryFailure;
    ColorBackgroundView *stationeryPane;
    StationerySelector *stationerySelector;
    NSTextField *stationeryNameTextField;
    NSButton *stationeryNameSaveButton;
    ColorBackgroundView *borderView;
    NSScroller *fakeScroller;
    NSViewAnimation *stationeryPaneAnimator;
    StationeryAnimator *stationeryTransitionAnimator;
    BOOL shouldAnimateTransitions;
    NSView *imageStatusView;
    NSTextField *imageFileSizeLabel;
    NSTextField *imageFileSizeTextField;
    NSPopUpButton *imageSizePopup;
    NSProgressIndicator *imageResizingProgressWheel;
    NSTextField *imageResizingProgressField;
    NSMutableArray *_imageResizers;
    unsigned int _textLengthForLastEstimatedMessageSize;
    unsigned int _signatureOverhead;
    unsigned int _encryptionOverhead;
    BOOL sendWhenFinishLoading;
    BOOL showAllHeaders;
    BOOL hasIncludedAttachmentsFromOriginal;
    NSMutableArray *_unapprovedRecipients;
    NSMutableArray *userActionQueue;
    Stationery *_stationeryWaitingToBeLoaded;
}

+ (int)documentType;
+ (id)documentEditors;
+ (id)createEditorWithType:(int)fp8 settings:(id)fp12;
+ (void)restoreDraftMessage:(id)fp8 withSavedState:(id)fp12;
+ (void)emailAddressesApproved:(id)fp8;
+ (void)emailsRejected:(id)fp8;
+ (void)_emailAddresses:(id)fp8 approvedOrRejected:(BOOL)fp12;
+ (void)handleFailedDeliveryOfMessage:(id)fp8 store:(id)fp12 error:(id)fp16;
- (id)init;
- (id)initWithBackEnd:(id)fp8;
- (id)initWithType:(int)fp8 settings:(id)fp12;
- (id)initWithType:(int)fp8 settings:(id)fp12 backEnd:(id)fp16;
- (BOOL)load;
- (void)finishLoadingEditor;
- (void)dealloc;
- (void)show;
- (int)messageType;
- (void)changeReplyMode:(id)fp8;
- (void)replyMessage:(id)fp8;
- (void)replyAllMessage:(id)fp8;
- (void)loadInitialDocument;
- (void)backEndDidLoadInitialContent:(id)fp8;
- (void)attachmentFinishedDownloading:(id)fp8;
- (id)document;
- (id)webView;
- (id)webArchiveFromSettings:(id)fp8;
- (void)continueLoadingInitialContent;
- (float)animationDuration;
- (void)showOrHideStationery:(id)fp8;
- (void)animationDidEnd:(id)fp8;
- (BOOL)stationeryPaneIsVisible;
- (id)currentStationery;
- (void)setStationeryWaitingToBeLoaded:(id)fp8;
- (void)loadStationery:(id)fp8;
- (void)stationeryAnimatorDidFinishAnimating;
- (void)loadStationery:(id)fp8 animate:(BOOL)fp12;
- (void)saveAsStationery:(id)fp8;
- (void)continueSaveAsStationery:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)controlTextDidChange:(id)fp8;
- (void)cancelSaveAsStationery:(id)fp8;
- (void)saveSaveAsStationery:(id)fp8;
- (void)saveAsStationeryErrorSheetDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (void)queueUserAction:(id)fp8;
- (void)handleQueuedUserActions;
- (BOOL)canSave;
- (void)saveMessageToDrafts:(id)fp8;
- (void)backEnd:(id)fp8 willCreateMessageWithHeaders:(id)fp12;
- (BOOL)backEnd:(id)fp8 shouldSaveMessage:(id)fp12;
- (void)backEndDidChange:(id)fp8;
- (void)backEndSenderDidChange:(id)fp8;
- (void)removeAttachments:(id)fp8;
- (void)createToDo:(id)fp8;
- (void)insertOriginalAttachments:(id)fp8;
- (BOOL)_restoreOriginalAttachments;
- (void)alwaysSendWindowsFriendlyAttachments:(id)fp8;
- (void)sendWindowsFriendlyAttachments:(id)fp8;
- (void)_setSendWindowsFriendlyAttachments:(BOOL)fp8;
- (void)alwaysAttachFilesAtEnd:(id)fp8;
- (void)attachFilesAtEnd:(id)fp8;
- (void)insertFile:(id)fp8;
- (void)openPanelSheetDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (BOOL)validateAction:(SEL)fp8 tag:(int)fp12;
- (BOOL)validateMenuItem:(id)fp8;
- (BOOL)_sendButtonShouldBeEnabled;
- (void)_setUnapprovedRecipients:(id)fp8;
- (void)askApprovalSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)send:(id)fp8;
- (void)sendMessageAfterChecking:(id)fp8;
- (void)backEndDidCancelMessageDeliveryForAttachmentError:(id)fp8;
- (void)attachmentErrorSheetDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)cancelSendingStationery:(id)fp8;
- (void)continueSendingStationery:(id)fp8;
- (void)emptyMessageSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)malformedAddressSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)noRecipientsSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)backEndDidAppendMessageToOutbox:(id)fp8 result:(int)fp12;
- (void)failedToAppendToOutboxSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (BOOL)backEnd:(id)fp8 shouldDeliverMessage:(id)fp12;
- (void)_setMessageStatusOnOriginalMessage;
- (void)backEnd:(id)fp8 didCancelMessageDeliveryForError:(id)fp12;
- (void)reportDeliveryFailure:(id)fp8;
- (void)backEnd:(id)fp8 didCancelMessageDeliveryForMissingCertificatesForRecipients:(id)fp12;
- (id)missingCertificatesMessageForRecipients:(id)fp8 uponDelivery:(BOOL)fp12;
- (void)backEnd:(id)fp8 didCancelMessageDeliveryForEncryptionError:(id)fp12;
- (void)shouldDeliverMessageAlertWithoutEncryptionSheetDidDismiss:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)setDeliveryAccount:(id)fp8;
- (id)deliveryAccount;
- (void)changeSignature:(id)fp8;
- (void)imageSizePopupChanged:(id)fp8;
- (void)messageSizeDidChange:(id)fp8;
- (void)encryptionStatusDidChange;
- (void)updateAttachmentStatus;
- (unsigned char)_isAttachmentScalable:(id)fp8;
- (unsigned char)_attachmentsContainScalableImage:(id)fp8 scalables:(id)fp12;
- (void)_updateImageSizePopup;
- (BOOL)_imageStatusHidden;
- (void)_showImageStatusView;
- (void)_hideImageStatusView;
#ifdef SNOW_LEOPARD
- (struct CGSize)_imageSizeForTag:(int)fp8;
- (struct CGSize)_selectedImageSize;
#else
- (struct _NSSize)_imageSizeForTag:(int)fp8;
- (struct _NSSize)_selectedImageSize;
#endif
- (id)_maxImageSizeAsString;
- (void)_processNextImageResizer;
- (void)_ImageResizeDidFinish:(id)fp8;
- (BOOL)_isResizingImages;
- (id)_resizerForAttatchment:(id)fp8;
- (BOOL)_resizeAttachment:(id)fp8;
- (BOOL)_resizeImageAttachments:(id)fp8;
- (unsigned long long)textLengthEstimate;
- (unsigned int)_signatureOverhead;
- (unsigned int)_encryptionOverhead;
- (unsigned long long)_estimateMessageSize;
- (void)_saveImageSizeToDefaults;
- (void)_setImageSizePopupToSize:(id)fp8;
- (id)attachmentStatusNeighbourView;
- (void)_mailAttachmentsDeleted;
- (void)mailAttachmentsDeleted:(id)fp8;
- (void)mailAttachmentsAdded:(id)fp8;
- (BOOL)windowShouldClose:(id)fp8;
- (void)appendMessages:(id)fp8;
- (void)appendMessageArray:(id)fp8;
- (void)_appendMessages:(id)fp8 withWebArchives:(id)fp12;
- (void)_generateWebArchivesToAppendForMessages:(id)fp8;
- (void)makeRichText:(id)fp8;
- (void)makePlainText:(id)fp8;
- (void)makeFontBigger:(id)fp8;
- (void)makeFontSmaller:(id)fp8;
- (void)addCcHeader:(id)fp8;
- (void)addBccHeader:(id)fp8;
- (void)addReplyToHeader:(id)fp8;
- (void)setMessagePriority:(id)fp8;

@end

#if 0
@interface WebViewEditor : NSObject
{
    EditingMessageWebView *webView;
    DocumentEditor *documentEditor;
    ComposeBackEnd *backEnd;
    HyperlinkEditor *hyperlinkEditor;
    EditingWebMessageController *messageController;
    WebFrame *frameAllowedToLoadContent;
    NSArray *attachmentsForContextualMenu;
    BOOL finalSpellCheckingIsInProgress;
    NSMutableSet *largeFilesAddedWhileEditing;
    BOOL containsRichText;
    BOOL containsRichTextFlagIsValid;
    BOOL needToCheckRichnessInRange;
    NSDictionary *infoForRichnessTest;
}

- (id)init;
- (void)dealloc;
- (void)earlySetUp;
- (void)setUp;
- (void)close;
- (id)webView;
- (BOOL)useDesignMode;
- (id)documentEditor;
- (void)setBackEnd:(id)fp8;
- (id)document;
- (void)setMessageController:(id)fp8;
- (void)setFrameAllowedToLoadContent:(id)fp8;
- (void)webView:(id)fp8 decidePolicyForNavigationAction:(id)fp12 request:(id)fp16 frame:(id)fp20 decisionListener:(id)fp24;
- (id)webView:(id)fp8 resource:(id)fp12 willSendRequest:(id)fp16 redirectResponse:(id)fp20 fromDataSource:(id)fp24;
- (void)setInlineSpellCheckingEnabled:(BOOL)fp8;
- (void)setCheckGrammarWithSpelling:(BOOL)fp8;
- (BOOL)startFinalSpellCheck;
- (void)endFinalSpellCheck;
- (void)finalSpellCheckCompleted:(id)fp8;
- (void)setFinalSpellCheckingIsInProgress:(BOOL)fp8;
- (BOOL)finalSpellCheckingIsInProgress;
- (void)updateIgnoredWordsForHeader:(id)fp8;
- (BOOL)validateUserInterfaceItem:(id)fp8;
- (BOOL)validateAction:(SEL)fp8 tag:(int)fp12;
- (void)_editLink;
- (void)editLink;
- (void)continueEditLink:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (void)removeSelectedLink;
- (void)insertList:(id)fp8;
- (BOOL)allowQuoting;
- (void)increaseIndentation;
- (void)decreaseIndentation;
- (void)changeIndentationIfAllowed:(int)fp8;
- (void)continueChangeIndentation:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (BOOL)selectionIsInList;
- (BOOL)selectionIsInListType:(id)fp8;
- (BOOL)selectionIsInEmptyListItem;
- (void)insertNumberedList:(id)fp8;
- (void)insertBulletedList:(id)fp8;
- (void)_insertListWithNumbers:(BOOL)fp8 undoTitle:(id)fp12;
- (void)insertListWithNumbers:(BOOL)fp8 undoTitle:(id)fp12;
- (void)continueInsertListWithNumbers:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (void)convertToNumberedList:(id)fp8;
- (void)convertToBulletedList:(id)fp8;
- (void)convertListFromType:(id)fp8 toType:(id)fp12 undoTitle:(id)fp16;
- (void)increaseListNestingLevel:(id)fp8;
- (void)decreaseListNestingLevel:(id)fp8;
- (void)_setFloat:(id)fp8 ofNode:(id)fp12 inView:(id)fp16 undoTitle:(id)fp20;
- (void)setFloat:(id)fp8 ofNode:(id)fp12 inView:(id)fp16 undoTitle:(id)fp20;
- (void)continueSetFloat:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (BOOL)webView:(id)fp8 shouldShowDeleteInterfaceForElement:(id)fp12;
- (BOOL)webView:(id)fp8 canInsertFromPasteboard:(id)fp12 forDrag:(BOOL)fp16;
- (BOOL)allowsRichText;
- (void)removeAllFormattingFromWebView;
- (void)setAllowsRichText:(BOOL)fp8;
- (BOOL)containsRichText;
- (void)setContainsRichText:(BOOL)fp8;
- (void)invalidateRichTextCache;
- (void)changeSendFormatInBackEndAndView:(int)fp8;
- (void)checkRichnessForEditedRange:(id)fp8;
- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12;
- (void)webViewDidInsertRichText:(id)fp8;
- (BOOL)webView:(id)fp8 shouldApplyStyle:(id)fp12 toElementsInDOMRange:(id)fp16;
- (void)continueShouldApplyStyle:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (id)alertForConvertingToRichText;
- (void)beginConvertToRichTextAlert:(id)fp8 context:(id)fp12;
- (void)convertToRichAlertDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (BOOL)isSelectionEditable;
- (void)appendFragment:(id)fp8 toDocument:(id)fp12 asQuote:(BOOL)fp16;
- (void)appendWebArchive:(id)fp8 toDocument:(id)fp12 asQuote:(BOOL)fp16;
- (void)appendAttributedString:(id)fp8 toDocument:(id)fp12 asQuote:(BOOL)fp16;
- (BOOL)webView:(id)fp8 shouldInsertText:(id)fp12 replacingDOMRange:(id)fp16 givenAction:(int)fp20;
- (BOOL)webView:(id)fp8 shouldInsertNode:(id)fp12 replacingDOMRange:(id)fp16 givenAction:(int)fp20;
- (void)webViewDidChange:(id)fp8;
- (BOOL)webView:(id)fp8 doCommandBySelector:(SEL)fp12;
- (id)validRangeFromSelection:(id)fp8;
- (id)webView:(id)fp8 shouldReplaceSelectionWithWebArchive:(id)fp12 givenAction:(int)fp16;
- (BOOL)webView:(id)fp8 shouldInsertAttachments:(id)fp12 context:(id)fp16;
- (void)webView:(id)fp8 didAddMailAttachment:(id)fp12;
- (void)webView:(id)fp8 willRemoveMailAttachment:(id)fp12;
- (BOOL)removeAttachmentsLeavingPlaceholder:(BOOL)fp8;
- (void)replaceRiskyAttachmentsWithLinks;
- (id)selectedAttachments;
- (id)attachmentForEvent:(id)fp8;
- (id)selectedAttachmentNode;
- (id)directoryForAttachment:(id)fp8;
- (void)removeAttachments:(id)fp8;
- (void)viewAttachments:(id)fp8 inLine:(BOOL)fp12;
- (void)redisplayChangedAttachment:(id)fp8;
- (void)addFileWrappersForPaths:(id)fp8;
- (void)insertAttributedStringOfAttachments:(id)fp8 allAttachmentsAreOkay:(BOOL)fp12;
- (BOOL)isOkayToInsertAttachment:(id)fp8;
- (void)pasteAsMarkup;
- (void)saveDocument:(id)fp8;
- (void)saveChangedDocument:(id)fp8;
- (id)largeFilesAddedWhileEditing;
- (void)largeFileAdded:(id)fp8;
- (void)webViewWillStartLiveResize:(id)fp8;
- (void)webViewDidEndLiveResize:(id)fp8;
- (id)infoForRichnessTest;
- (void)setInfoForRichnessTest:(id)fp8;

@end

@interface MailWebViewEditor : WebViewEditor <DOMEventListener>
{
    BOOL needToFinishMakingPlainAfterRemovingStationery;
    NSArray *backgroundTilingElements;
    NSArray *backgroundTilingDivs;
    NSArray *backgroundTilingFixedSizes;
    NSMutableArray *uneditedEditableElements;
    NSMutableArray *editedEditableElements;
    DOMNode *editableElementWithMouseDown;
    BOOL shouldAttachFilesAtEnd;
}

- (id)insertablePasteboardTypes;
- (void)prepareToGoAway;
- (void)dealloc;
- (void)setUp;
- (void)setBackEnd:(id)fp8;
- (BOOL)allowQuoting;
- (void)setAllowsRichText:(BOOL)fp8;
- (id)alertForConvertingToRichText;
- (BOOL)webView:(id)fp8 shouldInsertAttachments:(id)fp12 context:(id)fp16;
- (BOOL)isOkayToLoadStationery;
- (void)continueCannotInsertStationery:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (BOOL)shouldAttachFilesAtEnd;
- (void)_insertAttributedStringOfAttachments:(id)fp8 allAttachmentsAreOkay:(BOOL)fp12;
- (void)continueShouldInsertAttachments:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (BOOL)isOkayToInsertAttachment:(id)fp8;
- (void)insertAttributedStringOfAttachments:(id)fp8 allAttachmentsAreOkay:(BOOL)fp12;
- (void)continueInsertAttributedStringOfAttachments:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (BOOL)webView:(id)fp8 canInsertFromPasteboard:(id)fp12 forDrag:(BOOL)fp16;
- (void)prepareToRemoveStationery;
- (void)webViewDidLoadStationery:(id)fp8;
- (void)stationeryDidFinishLoadingResources:(id)fp8;
- (void)handleEvent:(id)fp8;
- (void)doOrUndoEditingInSignatureWithInfo:(id)fp8;
- (id)editedEditableElements;
- (void)mouseDownDidHappen:(id)fp8 inWebView:(id)fp12;
- (void)mouseUpDidHappen:(id)fp8 inWebView:(id)fp12;
- (void)webViewDidChange:(id)fp8;
- (id)replaceOldSignatureWithNewSignature:(id)fp8;
- (void)webViewDidChangeSelection:(id)fp8;
- (BOOL)webView:(id)fp8 doCommandBySelector:(SEL)fp12;
- (BOOL)insertNewline:(id)fp8;
- (void)webView:(id)fp8 didWriteSelectionToPasteboard:(id)fp12;
- (void)changeDocumentBackgroundColorWithContext:(id)fp8;
- (void)continueChangeDocumentBackgroundColor:(id)fp8 returnCode:(int)fp12 contextInfo:(id)fp16;
- (id)backgroundTilingFixedSizes;
- (void)setBackgroundTilingFixedSizes:(id)fp8;
- (id)backgroundTilingDivs;
- (void)setBackgroundTilingDivs:(id)fp8;
- (id)backgroundTilingElements;
- (void)setBackgroundTilingElements:(id)fp8;
- (void)setShouldAttachFilesAtEnd:(BOOL)fp8;

@end

#endif

#elif defined(TIGER)

@class TilingView;
@class AddressTextField;
@class MessageTextView;
@class CompletionController;
@class ComposeBackEnd;
@class Favorites;
@class MailDelivery;
@class OldCompletionController;
@class ComposeHeaderView;
@class DraggingTextView;
@class ActivityProgressPanel;

@interface MessageEditor : NSObject
{
    NSPopUpButton *fromPopup;
    NSPopUpButton *signaturePopup;
    NSPopUpButton *priorityPopup;
    AddressTextField *_toField;
    AddressTextField *_ccField;
    NSTextField *_subjectField;
    AddressTextField *_bccField;
    AddressTextField *_replyToField;
    ComposeHeaderView *_composeHeaderView;
    OldCompletionController *completionController;
    NSButton *signButton;
    NSButton *encryptButton;
    NSWindow *_window;
    ComposeBackEnd *_backEnd;
    NSMutableArray *accessoryViewOwners;
    struct {
        unsigned int showAllHeaders:1;
        unsigned int hasRichText:1;
        unsigned int userSavedMessage:1;
        unsigned int userWantsToCloseWindow:1;
        unsigned int hasIncludedAttachmentsFromOriginal:1;
        unsigned int userKnowsSaveFailed:1;
        unsigned int chatShouldBeEnabled:1;
        unsigned int finalSpellCheckingInProgress:1;
        unsigned int canSignFromAnyAccount:1;
        unsigned int knowsCanSignFromAnyAccount:1;
        unsigned int registeredForNotifications:1;
    } _flags;
    NSToolbar *_toolbar;
    NSMutableDictionary *_toolbarItems;
    int _messageType;
    DraggingTextView *addressFieldEditor;
    NSPanel *_deliveryFallbackPanel;
    id _deliveryErrorLabel;
    id _deliveryFallbackErrorLabel;
    id _deliveryFallbackPopupButton;
    struct _NSPoint _originalCascadePoint;
    ActivityProgressPanel *_progressAlert;
    NSView *imageStatusView;
    NSTextField *imageFileSizeLabel;
    NSTextField *imageFileSizeTextField;
    NSPopUpButton *imageSizePopup;
    NSProgressIndicator *imageResizingProgressWheel;
    NSTextField *imageResizingProgressField;
    NSMutableArray *_imageResizers;
    unsigned int _textLengthForLastEstimatedMessageSize;
    unsigned int _signatureOverhead;
    unsigned int _encryptionOverhead;
    NSMutableArray *_unapprovedRecipients;
}

+ (id)allocWithZone:(struct _NSZone *)fp8;
+ (id)createEditorWithType:(int)fp8 settings:(id)fp12;
+ (id)existingEditorViewingMessage:(id)fp8;
+ (void)handleFailedDeliveryOfMessage:(id)fp8 store:(id)fp12 error:(id)fp16;
+ (void)restoreDraftMessage:(id)fp8 withSavedState:(id)fp12;
+ (void)saveDefaults;
+ (void)restoreFromDefaults;
+ (void)setNeedsAutosave;
+ (void)autosaveTimerFired;
+ (void)showEditorWithSavedState:(id)fp8;
+ (void)_emailAddresses:(id)fp8 approvedOrRejected:(BOOL)fp12;
+ (void)emailAddressesApproved:(id)fp8;
+ (void)emailsRejected:(id)fp8;
- (void)_setSendWindowsFriendlyAttachments:(BOOL)fp8;
- (void)show;
- (void)readDefaultsFromDictionary:(id)fp8;
- (void)_appendDefaultsToArray:(id)fp8;
- (void)writeDefaultsToDictionary:(id)fp8;
- (void)setHeaders:(id)fp8;
- (id)window;
- (void)appendAddresses:(id)fp8 toHeader:(id)fp12;
- (void)addBccHeader:(id)fp8;
- (void)addReplyToHeader:(id)fp8;
- (void)saveMessageToDrafts:(id)fp8;
- (void)makeRichText:(id)fp8;
- (void)makePlainText:(id)fp8;
- (void)changeTextEncoding:(id)fp8;
- (void)showPrintPanel:(id)fp8;
- (void)searchIndex:(id)fp8;
- (BOOL)validateAction:(SEL)fp8 tag:(int)fp12;
- (BOOL)validateMenuItem:(id)fp8;
- (void)_reallySend;
- (void)_sendMessageCheckRecipients:(BOOL)fp8 checkSpelling:(BOOL)fp12;
- (void)_send:(id)fp8;
- (void)noRecipientsSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)send:(id)fp8;
- (void)emptyMessageSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)malformedAddressSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)changeReplyMode:(id)fp8;
- (void)alwaysSendWindowsFriendlyAttachments:(id)fp8;
- (void)sendWindowsFriendlyAttachments:(id)fp8;
- (void)insertFile:(id)fp8;
- (void)showAddressPanel:(id)fp8;
- (void)appendMessagesWithGatekeeperApproval:(id)fp8;
- (void)appendMessages:(id)fp8;
- (void)chatWithRecipients:(id)fp8;
- (void)changeHeaderField:(id)fp8;
- (void)recipientsDidChange:(id)fp8;
- (void)nowWouldBeAGoodTimeToTerminate:(id)fp8;
- (id)windowWillReturnFieldEditor:(id)fp8 toObject:(id)fp12;
- (BOOL)windowShouldClose:(id)fp8;
- (void)windowDidResize:(id)fp8;
- (void)windowDidMove:(id)fp8;
- (void)windowDidBecomeKey:(id)fp8;
- (void)windowDidResignKey:(id)fp8;
- (void)changeFromHeader:(id)fp8;
- (void)undoSignatureChange:(id)fp8;
- (void)changeSignature:(id)fp8;
- (void)editSignatures:(id)fp8;
- (void)changeSpellCheckingBehavior:(id)fp8;
- (void)setMessagePriority:(id)fp8;
- (id)directoryForAttachment:(id)fp8;
- (void)textView:(id)fp8 doubleClickedOnCell:(id)fp12 inRect:(struct _NSRect)fp16 atIndex:(unsigned int)fp32;
- (void)textView:(id)fp8 clickedOnCell:(id)fp12 inRect:(struct _NSRect)fp16 atIndex:(unsigned int)fp32;
- (void)textView:(id)fp8 draggedCell:(id)fp12 inRect:(struct _NSRect)fp16 event:(id)fp32 atIndex:(unsigned int)fp36;
- (BOOL)cachedGatekeeperApprovalStatusForAttachment:(id)fp8;
- (void)cacheGatekeeperApprovalStatus:(BOOL)fp8 forAttachment:(id)fp12;
- (BOOL)textView:(id)fp8 shouldReadSelectionFromPasteboard:(id)fp12 type:(id)fp16 result:(char *)fp20;
- (unsigned int)_signatureOverhead;
- (unsigned int)_encryptionOverhead;
- (unsigned long long)_estimateMessageSize;
- (void)_updateAttachmentStatus;
- (unsigned char)_isAttachmentScalable:(id)fp8;
- (unsigned char)_attachmentsContainScalableImage:(id)fp8 scalables:(id)fp12;
- (void)_updateImageSizePopup;
- (void)mailAttachmentsAdded:(id)fp8;
- (void)_mailAttachmentsDeleted;
- (void)mailAttachmentsDeleted:(id)fp8;
- (void)enableCompletion:(BOOL)fp8 forTextField:(id)fp12;
- (id)backEnd;
- (void)setBackEnd:(id)fp8;
- (void)updateUIAfterAppleScriptModification:(id)fp8;
- (void)deliveryFallbackPanelSendLater:(id)fp8;
- (void)deliveryFallbackPanelEditMessage:(id)fp8;
- (void)deliveryFallbackPanelTryOtherAccount:(id)fp8;
- (void)presenceChanged:(id)fp8;
- (id)_frameSaveName;
- (void)_configureTextField:(id)fp8 isAddressField:(BOOL)fp12;
- (void)_setupAddressField:(id)fp8;
- (void)dealloc;
- (id)init;
- (void)subjectChanged;
- (void)addressFieldChanged;
- (BOOL)_sendButtonShouldBeEnabled;
- (void)_setupInlineSpellChecking;
- (void)composePrefsChanged;
- (id)initWithType:(int)fp8 settings:(id)fp12;
- (void)backEnd:(id)fp8 didBeginBackgroundLoadActivity:(id)fp12;
- (void)_registerForNotificationsIfNeeded;
- (void)backEnd:(id)fp8 didCompleteLoadForEditorSettings:(id)fp12;
- (void)backEnd:(id)fp8 didCompleteMessageContentLoadForEditorSettings:(id)fp12;
- (void)_progressAlertDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (BOOL)_prepareMessageToBeSaved:(id)fp8;
- (BOOL)_shouldSaveDraft;
- (void)saveMessage;
- (void)_clearFieldIfHidden:(id)fp8;
- (void)composeHeaderViewWillBeginCustomization:(id)fp8;
- (void)composeHeaderViewDidEndCustomization:(id)fp8;
- (void)mailAccountsDidChange;
- (void)updateFromAndSignatureControls;
- (void)updateSignatureControlOverridingExistingSignature:(BOOL)fp8;
- (void)updateSignButtonImages;
- (void)updateSignButtonTooltip;
- (void)updateEncryptButtonImages;
- (void)updateEncryptButtonTooltip;
- (BOOL)canSignFromAnyAccount;
- (void)updateSecurityControls;
- (void)updateIgnoredWords;
- (void)updateCcOrBccMyselfFieldWithSender:(id)fp8 oldSender:(id)fp12;
- (void)_setupField:(id)fp8 withAddressesForKey:(id)fp12 visibleSelector:(SEL)fp16;
- (void)updateHeaderFields;
- (void)configureButtonsAndPopUps;
- (void)backEndDidChange:(id)fp8;
- (void)_setMessageStatusOnOriginalMessage;
- (void)backEndDidAppendMessageToOutbox:(id)fp8 result:(int)fp12;
- (BOOL)backEnd:(id)fp8 shouldDeliverMessage:(id)fp12;
- (BOOL)backEnd:(id)fp8 shouldSaveMessage:(id)fp12;
- (void)_setUserSavedMessage:(BOOL)fp8;
- (void)backEndDidSaveMessage:(id)fp8 result:(int)fp12;
- (id)_missingCertificatesMessageForRecipients:(id)fp8 uponDelivery:(BOOL)fp12;
- (void)backEnd:(id)fp8 didCancelMessageDeliveryForMissingCertificatesForRecipients:(id)fp12;
- (void)backEnd:(id)fp8 didCancelMessageDeliveryForError:(id)fp12;
- (void)shouldDeliverMessageAlertWithoutEncryptionSheetDidDismiss:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)backEnd:(id)fp8 didCancelMessageDeliveryForEncryptionError:(id)fp12;
- (void)reportDeliveryFailure:(id)fp8;
- (void)chooseAlternateDeliveryAccountSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)deliveryFailureSheetDidClose:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)textFieldBeganOrEndedEditing:(id)fp8;
- (void)openPanelSheetDidEnd:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)saveState;
- (void)forceWindowClose;
- (void)closeConfirmSheetDidEnd:(id)fp8 returnCode:(int)fp12 forSave:(void *)fp16;
- (void)replyMessage:(id)fp8;
- (void)replyAllMessage:(id)fp8;
- (void)presencePreferenceChanged:(id)fp8;
- (void)updatePresenceButtonState;
- (void)updatePresenceButtonStateForAddresses:(id)fp8;
- (void)_recipientsWithoutKeysSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)securityControlChanged:(id)fp8;
- (BOOL)_imageStatusHidden;
- (void)_showImageStatusView;
- (void)_hideImageStatusView;
- (struct _NSSize)_imageSizeForTag:(int)fp8;
- (struct _NSSize)_selectedImageSize;
- (id)_maxImageSizeAsString;
- (void)_processNextImageResizer;
- (void)_ImageResizeDidFinish:(id)fp8;
- (BOOL)_isResizingImages;
- (id)_resizerForAttatchment:(id)fp8;
- (BOOL)_resizeAttachment:(id)fp8;
- (BOOL)_resizeImageAttachments:(id)fp8;
- (void)imageSizePopupChanged:(id)fp8;
- (void)_setUnapprovedRecipients:(id)fp8;
- (void)askApprovalSheetClosed:(id)fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)_finalSpellCheckCompleted:(id)fp8;
- (BOOL)loadEditorNib;
- (void)appendAttributedString:(id)fp8;
- (void)updateMainContentView;
- (Class)backEndClass;
- (id)mainContentView;
- (id)attachmentStatusNeighbourView;
- (id)attachments;
- (void)insertOriginalAttachments:(id)fp8;
- (void)removeAttachments:(id)fp8;
- (void)toggleRich:(id)fp8;
- (void)pasteAsQuotation:(id)fp8;
- (void)updateContentsToShowSignature:(id)fp8;
- (unsigned long long)textLengthEstimate;
- (BOOL)isRichText;
- (void)setRichText:(BOOL)fp8;
- (void)appendMessageArray:(id)fp8;
- (void)addFileWrappersForPaths:(id)fp8;
- (void)redisplayChangedAttachment:(id)fp8;
- (void)updateRichTextFlag;

@end

@interface MessageEditor (MessageEditorToolbar)
- (BOOL)validateToolbarItem:(id)fp8 forSegment:(int)fp12;
- (void)_setupToolBarOnWindow:(id)fp8 messageType:(int)fp12;
- (void)_synchronizeChangeReplyItem:(id)fp8 messageType:(int)fp12;
- (void)toggleReplytype:(int)fp8;
- (void)_updateSendButtonStateInToolbar;
- (void)toolbarWillAddItem:(id)fp8;
- (id)toolbar:(id)fp8 itemForItemIdentifier:(id)fp12 willBeInsertedIntoToolbar:(BOOL)fp16;
- (id)toolbarDefaultItemIdentifiers:(id)fp8;
- (id)toolbarAllowedItemIdentifiers:(id)fp8;
@end

@interface MessageEditor (ScriptingAdditions)
- (id)objectSpecifier;
@end

#else

@class TilingView;
@class AddressTextField;
@class MessageTextView;
@class CompletionController;
@class ComposeBackEnd;
@class Favorites;
@class MailDelivery;
@class OldCompletionController;

@interface MessageEditor:NSObject
{
    TilingView *headerContainer;	// 4 = 0x4
    AddressTextField *fieldPrototype;	// 8 = 0x8
    NSView *fromAndSignatureContainer;	// 12 = 0xc
    NSPopUpButton *fromPopup;	// 16 = 0x10
    NSTextField *fromLabel;	// 20 = 0x14
    NSPopUpButton *signaturePopup;	// 24 = 0x18
    NSTextField *signatureLabel;	// 28 = 0x1c
    MessageTextView *composeText;	// 32 = 0x20
    OldCompletionController *completionController;	// 36 = 0x24
    NSButton *signButton;	// 40 = 0x28
    NSButton *encryptButton;	// 44 = 0x2c
    NSView *composeContentView;	// 48 = 0x30
    ComposeBackEnd *backEnd;	// 52 = 0x34
    NSMutableArray *accessoryViewOwners;	// 56 = 0x38
    struct {
        int showAllHeaders:1;
        int showRichSendButton:1;
        int userSavedMessage:1;
        int userWantsToCloseWindow:1;
        int hasIncludedAttachmentsFromOriginal:1;
        int userKnowsSaveFailed:1;
        int chatShouldBeEnabled:1;
    } _flags;	// 60 = 0x3c
    NSToolbar *_toolbar;	// 64 = 0x40
    NSMutableDictionary *_toolbarItems;	// 68 = 0x44
    int _messageType;	// 72 = 0x48
    NSPanel *_deliveryFallbackPanel;	// 76 = 0x4c
    id _deliveryFallbackErrorLabel;	// 80 = 0x50
    id _deliveryFallbackPopupButton;	// 84 = 0x54
    NSWindow *becomeRichSheetWindow;	// 88 = 0x58
    float oldFromAndSignatureContainerWidth;	// 92 = 0x5c
}

+ createEditorWithType:(int)fp8 originalMessage:fp12 forwardedText:fp16 showAllHeaders:(char)fp20;
+ existingEditorViewingMessage:fp8;
+ (void)handleFailedDeliveryOfMessage:fp8 store:fp12 error:fp16;
+ (void)restoreDraftMessage:fp8 withSavedState:fp12;
+ (void)saveDefaults;
+ (void)restoreFromDefaults;
+ (void)setIsInlineSpellCheckingEnabled:(char)fp8;
+ (void)setNeedsAutosave;
+ (void)autosaveTimerFired;
+ sharedContextMenu;
+ (void)showEditorWithSavedState:fp8;
- (void)show;
- (void)readDefaultsFromDictionary:fp8;
- (void)writeDefaultsToArray:fp8;
- (void)setHeaders:fp8;
- (void)appendAttributedString:fp8;
- window;
- (void)appendAddresses:fp8 toHeader:fp12;
- (void)addBccHeader:fp8;
- (void)addReplyToHeader:fp8;
- (void)saveMessageToDrafts:fp8;
- (void)insertOriginalAttachments:fp8;
- (void)removeAttachments:fp8;
- (void)_toggleRichSheetDidEnd:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)toggleRich:fp8;
- (void)makeRichText:fp8;
- (void)makePlainText:fp8;
- (void)changeTextEncoding:fp8;
- (void)showPrintPanel:fp8;
- (void)pasteAsQuotation:fp8;
- (void)searchIndex:fp8;
- (char)_validateAction:(SEL)fp8 tag:(int)fp12;
- (BOOL)validateMenuItem:fp8;
- (void)_send:fp8;
- (void)noRecipientsSheetClosed:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)send:fp8;
- (void)emptyMessageSheetClosed:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)malformedAddressSheetClosed:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)changeReplyMode:fp8;
- (void)alwaysSendWindowsFriendlyAttachments:fp8;
- (void)sendWindowsFriendlyAttachments:fp8;
- (void)insertFile:fp8;
- (void)showAddressPanel:fp8;
- (void)appendMessages:fp8;
- (void)chatWithRecipients:fp8;
- (void)changeHeaderField:fp8;
- (void)recipientsDidChange:fp8;
- (void)nowWouldBeAGoodTimeToTerminate:fp8;
- windowWillReturnFieldEditor:fp8 toObject:fp12;
- (char)textView:fp8 doCommandBySelector:(SEL)fp12;
- (void)stayPlainOrBecomeRich:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (char)windowShouldClose:fp8;
- (void)windowDidResize:fp8;
- (void)windowDidMove:fp8;
- (void)changeFromHeader:fp8;
- (void)undoSignatureChange:fp8;
- (void)changeSignature:fp8;
- directoryForAttachment:fp8;
- (void)textView:fp8 doubleClickedOnCell:fp12 inRect:(struct _NSRect)fp16 atIndex:(unsigned int)fp32;
- (void)textView:fp8 clickedOnCell:fp12 inRect:(struct _NSRect)fp16 atIndex:(unsigned int)fp32;
- (void)textView:fp8 draggedCell:fp12 inRect:(struct _NSRect)fp16 event:fp32 atIndex:(unsigned int)fp36;
- (char)textView:fp8 shouldReadSelectionFromPasteboard:fp12 type:fp16 result:(char *)fp20;
- attachmentContextMenu;
- (void)enableCompletion:(char)fp8 forTextField:fp12;
- backEnd;
- (void)setBackEnd:fp8;
- (void)updateUIAfterAppleScriptModification:fp8;
- (void)deliveryFallbackPanelSendLater:fp8;
- (void)deliveryFallbackPanelEditMessage:fp8;
- (void)deliveryFallbackPanelTryOtherAccount:fp8;
- (void)presenceChanged:fp8;
- _frameSaveName;
- (void)awakeFromNib;
- (void)dealloc;
- init;
- (void)subjectChanged;
- (void)addressFieldChanged;
- (char)_sendButtonShouldBeEnabled;
- (void)_setupTextViewInlineSpellChecking;
- (void)composePrefsChanged:fp8;
- (void)_configureComposeWindowForType:(int)fp8 message:fp12;
- initWithType:(int)fp8 message:fp12 showAllHeaders:(char)fp16;
- (char)_prepareMessageToBeSaved:fp8;
- (char)_shouldSaveDraft;
- (void)saveMessage;
- (void)fromAndSignatureContainerFrameChanged:fp8;
- (void)updateFromAndSignatureControls;
- (void)updateFromAndSignatureViewLayout;
- (void)updateSignButtonImages;
- (void)updateEncryptButtonImages;
- (void)updateSecurityControls:(char)fp8;
- (void)updateHeaderFields;
- (void)configureInitialText:fp8;
- (char)isRichText;
- (void)setRichText:(char)fp8;
- (void)backEndDidChange:fp8;
- (void)reloadContentsFromMessage:fp8;
- (void)messageWillNeedRecoloring:fp8;
- (void)_setMessageStatusOnOriginalMessage;
- (void)backEndDidAppendMessageToOutbox:fp8 result:(int)fp12;
- (BOOL)backEnd:fp8 shouldDeliverMessage:fp12;
- (char)backEnd:fp8 shouldSaveMessage:fp12;
- (void)_setUserSavedMessage:(char)fp8;
- (void)backEndDidSaveMessage:fp8 result:(int)fp12;
- _nameForRecipient:fp8;
- (void)backEnd:fp8 didCancelMessageDeliveryForMissingCertificatesForRecipients:fp12;
- (void)backEnd:fp8 didCancelMessageDeliveryForError:fp12;
- (void)shouldDeliverMessageAlertWithoutEncryptionSheetDidDismiss:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)backEnd:fp8 didCancelMessageDeliveryForEncryptionError:fp12;
- (void)reportDeliveryFailure:fp8;
- (void)chooseAlternateDeliveryAccountSheetClosed:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)deliveryFailureSheetDidClose:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)completionControllerDidSelectAddress:fp8;
- (void)textFieldBeganOrEndedEditing:fp8;
- (void)appendMessageArray:fp8;
- (void)addFileWrappersForPaths:fp8;
- (void)openPanelSheetDidEnd:fp8 returnCode:(int)fp12 contextInfo:(void *)fp16;
- (void)saveState;
- (void)forceWindowClose;
- (void)closeConfirmSheetDidEnd:fp8 returnCode:(int)fp12 forSave:(void *)fp16;
- (void)replyMessage:fp8;
- (void)replyAllMessage:fp8;
- (void)presencePreferenceChanged:fp8;
- (void)updatePresenceButtonState;
- (void)updatePresenceButtonStateForAddresses:fp8;
- (void)securityControlChanged:fp8;

@end

@interface MessageEditor(MessageEditorToolbar)
- (BOOL)validateToolbarItem:fp8;
- (void)_setupToolBarOnWindow:fp8 messageType:(int)fp12;
- (void)_synchronizeChangeReplyItem:fp8 messageType:(int)fp12;
- (void)toggleReplytype:(int)fp8;
- (void)_updateSendButtonStateInToolbar;
- (void)_updateSendButtonInToolbarWithImage:fp8;
- (void)toolbarWillAddItem:fp8;
- toolbar:fp8 itemForItemIdentifier:fp12 willBeInsertedIntoToolbar:(BOOL)fp16;
- toolbarDefaultItemIdentifiers:fp8;
- toolbarAllowedItemIdentifiers:fp8;
@end

@interface MessageEditor(ScriptingAdditions)
- objectSpecifier;
@end

#endif
