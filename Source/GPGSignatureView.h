#import <Cocoa/Cocoa.h>
#import <Libmacgpg/Libmacgpg.h>

@interface GPGSignatureView : NSObject <NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, NSSplitViewDelegate> {
	IBOutlet NSWindow *window;
	IBOutlet NSTableView *detailTable;
	NSSet *keyList;
	NSArray *signatures;
	BOOL running;
	NSIndexSet *signatureIndexes;
	GPGSignature *signature;
	GPGKey *gpgKey;
	
	IBOutlet NSView *scrollContentView;
	IBOutlet NSView *infoView;
	IBOutlet NSView *detailView;
	IBOutlet NSScrollView *scrollView;
}

//Private
@property (retain) NSIndexSet *signatureIndexes;
@property (readonly) GPGKey *gpgKey;

- (IBAction)switchDetailView:(NSButton *)sender;
- (IBAction)close:(id)sender;




//Public
@property (retain) NSSet *keyList;
@property (retain) NSArray *signatures;

+ (id)signatureView;

- (NSInteger)runModal;
- (void)beginSheetModalForWindow:(NSWindow *)modalWindow completionHandler:(void (^)(NSInteger result))handler;
- (NSString *)keyID;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end


@interface GPGSignatureCertImageTransformer : NSValueTransformer {} @end
@interface GPGFlippedView : NSView {} @end
@interface TopScrollView : NSScrollView {} @end
