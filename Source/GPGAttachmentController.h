//
//  GPGAttachmentController.h
//  GPGMail
//
//  Created by Lukas Pitschl on 08.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GPGSignatureView.h"

@interface GPGAttachmentController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, NSSplitViewDelegate> {
    NSImageView *errorImageView;
    NSMutableArray *attachments;
    GPGSignature *signature;
    GPGKey *gpgKey;
    NSDictionary *currentAttachment;
    NSSet *keyList;
    NSIndexSet *attachmentIndexes;

    IBOutlet NSView *detailView;
    IBOutlet NSView *scrollContentView;
	IBOutlet NSView *infoView;
	IBOutlet NSScrollView *scrollView;
    IBOutlet NSView *errorView;
    IBOutlet NSTableView *tableView;
}

- (IBAction)switchDetailView:(NSButton *)sender;

- (id)initWithAttachmentParts:(NSArray *)attachmentParts;
- (void)beginSheetModalForWindow:(NSWindow *)modalWindow completionHandler:(void (^)(NSInteger result))handler;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@property (assign) IBOutlet NSImageView *errorImageView;
@property (retain) NSArray *attachments;
@property (nonatomic, retain) NSIndexSet *attachmentIndexes;
@property (retain) NSDictionary *currentAttachment;
@property (nonatomic, retain) GPGSignature *signature;
@property (retain) NSSet *keyList;
@property (retain) GPGKey *gpgKey;


/**
 Returns the correctly signed or signature failure image, depending
 on the part status.
 */
- (NSImage *)signedImageForPart:(MimePart *)part;

/**
 Returns the encrypted or decrypted image, depending on the part
 status.
 */
- (NSImage *)encryptedImageForPart:(MimePart *)part;

@end

