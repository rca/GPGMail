//
//  GPGAttachmentController.m
//  GPGMail
//
//  Created by Lukas Pitschl on 08.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#define localized(key) [[GPGMailBundle bundle] localizedStringForKey:(key) value:(key) table:@"SignatureView"]
#define localizedAttachmentMessage(key) [[GPGMailBundle bundle] localizedStringForKey:(key) value:(key) table:@"GPGAttachment"]

#import "MimePart.h"
#import "NSObject+LPDynamicIvars.h"
#import "MimePart+GPGMail.h"
#import "MFError.h"
#import "GPGAttachmentController.h"
#import "GPGSignatureView.h"
#import "GPGMailBundle.h"

@implementation GPGAttachmentController
@synthesize errorImageView;
@synthesize attachments;
@synthesize attachmentIndexes;
@synthesize currentAttachment;
@synthesize signature;
@synthesize keyList;
@synthesize gpgKey;

- (id)initWithAttachmentParts:(NSArray *)attachmentParts {
    if(self = [super initWithWindowNibName:@"GPGAttachments"]) {
        attachments = [[NSMutableArray alloc] init];
        for(MimePart_GPGMail *part in attachmentParts) {
            NSMutableDictionary *attachment = [[NSMutableDictionary alloc] init];
            [attachment setValue:@(part.PGPEncrypted) forKey:@"encrypted"];
            [attachment setValue:@(part.PGPSigned) forKey:@"signed"];
            [attachment setValue:part.PGPError forKey:@"error"];
            [attachment setValue:[part dispositionParameterForKey:@"filename"] forKey:@"decrypted-name"];
            if(part.PGPSignatures)
                [attachment setValue:(part.PGPSignatures)[0] forKey:@"signature"];
            BOOL decrypted = part.PGPDecrypted;
            [attachment setValue:@(decrypted) forKey:@"decrypted"];
            if(!part.PGPError) {
                [attachment setValue:@YES forKey:@"showErrorView"];
                if(decrypted && part.PGPVerified) {
                    [attachment setValue:@NO forKey:@"showSignatureView"];
                    [attachment setValue:@YES forKey:@"showDecryptedNoSignatureView"];
                }
                else if(part.PGPVerified) {
                    [attachment setValue:@NO forKey:@"showSignatureView"];
                    [attachment setValue:@YES forKey:@"showDecryptedNoSignatureView"];
                }
                else if(decrypted) {
                    [attachment setValue:@YES forKey:@"showSignatureView"];
                    [attachment setValue:@NO forKey:@"showDecryptedNoSignatureView"];
                    [attachment setValue:localizedAttachmentMessage(@"ATTACHMENT_DECRYPTED_SUCCESSFULLY_TITLE") forKey:@"decryptionSuccessTitle"];
                    [attachment setValue:localizedAttachmentMessage(@"ATTACHMENT_DECRYPTED_SUCCESSFULLY_MESSAGE") forKey:@"decryptionSuccessMessage"];
                }
            }
            else {
                [attachment setValue:@YES forKey:@"showSignatureView"];
                if(part.PGPSigned) {
                    [attachment setValue:[NSImage imageNamed:@"certificate"] forKey:@"errorBadgeImage"];
                    [attachment setValue:[[(MFError *)[attachment valueForKey:@"error"] userInfo] valueForKey:@"_MFShortDescription"] forKey:@"errorTitle"];
                    [attachment setValue:[[(MFError *)[attachment valueForKey:@"error"] userInfo] valueForKey:@"NSLocalizedDescription"] forKey:@"errorMessage"];
                }
                else if(!decrypted) {
                    [attachment setValue:[NSImage imageNamed:@"encryption"] forKey:@"errorBadgeImage"];
                    [attachment setValue:[[(MFError *)[attachment valueForKey:@"error"] userInfo] valueForKey:@"_MFShortDescription"] forKey:@"errorTitle"];
                    [attachment setValue:[[(MFError *)[attachment valueForKey:@"error"] userInfo] valueForKey:@"NSLocalizedDescription"] forKey:@"errorMessage"];
                }                
            }
            
            // Set the correct images at their correct positions.
            // 1.) signed && encrypted -> first icon = encrypted, second icon = signed
            // 2.) only signed -> first icon = signed, second icon = nil
            // 3.) only encrypted -> first icon = encrypted, second icon = nil
            
            if(part.PGPSigned && part.PGPEncrypted) {
                [attachment setValue:[self encryptedImageForPart:part] forKey:@"firstIcon"];
                [attachment setValue:[self signedImageForPart:part] forKey:@"secondIcon"];
            }
            else if(part.PGPSigned) {
                [attachment setValue:[self signedImageForPart:part] forKey:@"firstIcon"];
            }
            else if(part.PGPEncrypted) {
                [attachment setValue:[self encryptedImageForPart:part] forKey:@"firstIcon"];
            }
            
            
            
            [attachments addObject:attachment];
        }
    }
    return self;
}

- (NSImage *)signedImageForPart:(MimePart_GPGMail *)part {
    // If the attachment has pgp signature set and no error, display the
    // signature on icon otherwise the signature off icon.
    if(!part.PGPSigned)
        return nil;
    if(part.PGPVerified)
        return [NSImage imageNamed:@"SignatureOnTemplate"];
    
    return [NSImage imageNamed:@"SignatureOffTemplate"];
}

- (NSImage *)encryptedImageForPart:(MimePart_GPGMail *)part {
    // If the attachment has decrypted set, the part has been 
    // successfully decrypted and the open lock image is returned.
    if(!part.PGPEncrypted)
        return nil;
    
    if(part.PGPDecrypted)
        return [NSImage imageNamed:@"NSLockUnlockedTemplate"];
    
    return [NSImage imageNamed:@"NSLockLockedTemplate"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.errorImageView.image = [NSImage imageNamed:@"encryption"];
}

- (void)beginSheetModalForWindow:(NSWindow *)modalWindow completionHandler:(void (^)(NSInteger result))handler {
	[NSApp beginSheet:self.window modalForWindow:modalWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(handler)];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	((__bridge void (^)(NSInteger result))contextInfo)(NSOKButton);
}

- (void)setAttachmentParts:(NSArray *)attachmentParts {
    
}

- (void)setAttachmentIndexes:(NSIndexSet *)value {
	if (value != attachmentIndexes) {
		attachmentIndexes = value;
		NSUInteger index;
		if ([value count] > 0 && (index = [value firstIndex]) < [attachments count]) {
			self.currentAttachment = attachments[index];
            self.signature = [self.currentAttachment valueForKey:@"signature"];
		} else {
			self.currentAttachment = nil;
            self.signature = nil;
		}		
	}
}

- (void)setSignature:(GPGSignature *)value {
	if (value != signature) {
		signature = value;
		
		GPGKey *key = nil;
		if (signature) {
			NSString *fingerprint = signature.primaryFingerprint;
			if ((key = [keyList member:fingerprint])) {
				goto found;
			}
			fingerprint = signature.fingerprint;
			if ([fingerprint length] >= 8) {
				if ((key = [keyList member:fingerprint])) {
					goto found;
				}
				fingerprint = [fingerprint stringByAppendingString:@"\n"];
				for (key in keyList) {
					if ([[key allFingerprints] member:fingerprint]) {
						goto found;
					}
				}
			}					
		}
	found:
		self.gpgKey = key;
	}
}

- (id)valueForKeyPath:(NSString *)keyPath {
    if ([keyPath hasPrefix:@"signature."]) {
		if (signature == nil) {
			return nil;
		}
		keyPath = [keyPath substringFromIndex:10];
        if([self respondsToSelector:NSSelectorFromString(keyPath)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			return [self performSelector:NSSelectorFromString(keyPath)];
#pragma clang diagnostic pop
		}
        if ([signature respondsToSelector:NSSelectorFromString(keyPath)]) {
			return [signature valueForKey:keyPath];
		}
	}
    
	return [super valueForKeyPath:keyPath];
}

- (NSString *)unlocalizedValidityKey {
	NSString *text = nil;
	
	switch (signature.status) {
		case GPGErrorNoError:
			if (signature.trust > 1) {
				text = @"VALIDITY_OK";
			} else {
				text = @"VALIDITY_NO_TRUST";
			}
			break;
		case GPGErrorBadSignature:
			text = @"VALIDITY_BAD_SIGNATURE";
			break;
		case GPGErrorSignatureExpired:
			text = @"VALIDITY_SIGNATURE_EXPIRED";
			break;
		case GPGErrorKeyExpired:
			text = @"VALIDITY_KEY_EXPIRED";
			break;
		case GPGErrorCertificateRevoked:
			text = @"VALIDITY_KEY_REVOKED";
			break;
		case GPGErrorUnknownAlgorithm:
			text = @"VALIDITY_UNKNOWN_ALGORITHM";
			break;
		case GPGErrorNoPublicKey:
			text = @"VALIDITY_NO_PUBLIC_KEY";
			break;
		default:
			text = @"VALIDITY_UNKNOWN_ERROR";
			break;
	}
	return text;
}



- (NSImage *)validityImage {
	if (![signature isKindOfClass:[GPGSignature class]]) {
		return nil;
	}
	if (signature.status != 0 || signature.trust <= 1) {
		return [NSImage imageNamed:@"InvalidBadge"];
	} else {
		return [NSImage imageNamed:@"ValidBadge"];
	}
}

- (NSString *)emailAndID {
    
    NSMutableString *value = [[NSMutableString alloc] init];
    if(gpgKey.email)
        [value appendFormat:@"%@", gpgKey.email];
    
    NSString *keyID = [self keyID];
    if(keyID) {
        if(gpgKey.email)
            [value appendString:@" ("];
        [value appendFormat:@"%@", keyID];
        if(gpgKey.email)
            [value appendString:@")"];
    }
    
    return value;
}

- (NSString *)validityDescription {
	if (!signature) return nil;
	
	NSString *text = [self unlocalizedValidityKey];
	if (text) {
		return localized(text);
	} else {
		return @"";
	}
}

- (NSString *)validityToolTip {
	if (!signature) return nil;
	
	NSString *text = [self unlocalizedValidityKey];
	text = [text stringByAppendingString:@"_TOOLTIP"];
	if (text) {
		return localized(text);
	} else {
		return @"";
	}
}

- (NSString *)keyID {
	NSString *keyID = gpgKey.keyID;
	if (!keyID) {
		keyID = signature.fingerprint;
	}
	return [keyID shortKeyID];
}

- (NSImage *)signatureImage {
	if (![signature isKindOfClass:[GPGSignature class]]) {
		return nil;
	}
	if (signature.status != 0 || signature.trust <= 1) {
		return [NSImage imageNamed:@"CertLargeNotTrusted"];
	} else {
		return [NSImage imageNamed:@"CertLargeStd"];
	}
}

- (IBAction)close:(id)sender {
	[self close];
    [NSApp stopModal];
	[NSApp endSheet:self.window];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMinimumPosition + 20;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
	return proposedMaximumPosition - 90;
}
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
	NSArray *subviews = [splitView subviews];
	NSView *view1 = subviews[0];
	NSView *view2 = subviews[1];
	NSSize splitViewSize = [splitView frame].size;
	NSSize size1 = [view1 frame].size;
	NSRect frame2 = [view2 frame];
	CGFloat dividerThickness = [splitView dividerThickness];
	
	size1.width = splitViewSize.width;
	frame2.size.width = splitViewSize.width;
	
	frame2.size.height = splitViewSize.height - dividerThickness - size1.height;
	if (frame2.size.height < 60) {
		frame2.size.height = 60;
		size1.height = splitViewSize.height - 60 - dividerThickness;
	}
	frame2.origin.y = splitViewSize.height - frame2.size.height;
	
    [view1 setFrameSize:size1];
	[view2 setFrame:frame2];
}

- (void)awakeFromNib {
    // Get attachment for row.
    NSDictionary *attachment = attachments[0];
    if([attachment valueForKey:@"error"])
        [scrollView setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:0.9451 blue:0.6074 alpha:1.0]];
    else
        [scrollView setBackgroundColor:[NSColor whiteColor]];
    [detailView setFrameOrigin:NSMakePoint(0, [scrollContentView frame].size.height)];
}

- (IBAction)switchDetailView:(NSButton *)sender {
	static CGFloat minHeight = 0;
	static CGFloat maxHeight = 450;
	NSRect windowFrame = self.window.frame;
	NSSize windowSize = windowFrame.size;
	NSSize scrollContentSize = [scrollContentView frame].size;
	NSSize detailSize = [detailView frame].size;
    
    if ([detailView superview]) {
		if (minHeight > 0 && minHeight < windowSize.height) {
			maxHeight = windowSize.height;
			windowSize.height = minHeight;
		} else {
			maxHeight = 0;
		}
        
		scrollContentSize.height -= detailSize.height;
		//infoSize.width = [infoView frame].size.width;
        
		[detailView removeFromSuperview];
	} else {
		if (maxHeight > 0 && windowSize.height < maxHeight) {
			minHeight = windowSize.height;
			windowSize.height = maxHeight;
		} else {
			minHeight = 0;
		}
        
		scrollContentSize.height += detailSize.height;
		[detailView setFrameSize:NSMakeSize(scrollContentSize.width, [detailView frame].size.height)];
		//infoSize.width = [detailView frame].size.width;
		
		[scrollContentView addSubview:detailView];
	}
    [scrollContentView setFrameSize:scrollContentSize];
	
	windowFrame.origin.x = windowFrame.origin.x + (windowSize.width - windowFrame.size.width) / 2;
	windowFrame.origin.y = windowFrame.origin.y + windowFrame.size.height - windowSize.height;
	windowFrame.size = windowSize;
    
	[self.window setFrame:windowFrame display:YES animate:YES];
}

#pragma mark - Table delegate

#pragma mark - Table data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return 1;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    id value = nil;
    if([aTableColumn.identifier isEqualToString:@"encrypted"])
        value = [NSImage imageNamed:@"NSLockUnlockedTemplate"];
    else if([aTableColumn.identifier isEqualToString:@"signed"])
        value = [NSImage imageNamed:@"SignatureOffTemplate"];
    else if([aTableColumn.identifier isEqualToString:@"name"])
        value = @"gpgmail.png";
    
    return value;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    // Get attachment for row.
    NSDictionary *attachment = attachments[rowIndex];
    if([attachment valueForKey:@"error"])
        [scrollView setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:0.9451 blue:0.6074 alpha:1.0]];
    else
        [scrollView setBackgroundColor:[NSColor whiteColor]];
    
    return YES;
}

@end
