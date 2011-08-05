//
//  NSAttributedString+GPGMail.m
//  GPGMail
//
//  Created by Lukas Pitschl on 31.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GPGTextAttachmentCell.h"
#import "NSAttributedString+GPGMail.h"

@implementation NSAttributedString (GPGMail)

+ (NSAttributedString *)attributedStringWithAttachment:(NSTextAttachment *)attachment image:(NSImage *)image link:(NSString *)link {
    GPGTextAttachmentCell *cell = [[GPGTextAttachmentCell alloc] init];
    cell.image = image;
    attachment.attachmentCell = cell;
    [cell release];
    NSMutableAttributedString *attachmentString = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    // Now this is unusual but comfortable.
    // Set a link attribute on the attachment, so we get an event
    // when the attachment is clicked in the MessageHeaderDisplay.
    // See textView:clickOnLink:
    [attachmentString addAttribute:NSLinkAttributeName value:link 
                             range:NSMakeRange(0, [attachmentString length])];
    [attachmentString addAttribute:NSCursorAttributeName value:[NSCursor arrowCursor] 
                             range:NSMakeRange(0, [attachmentString length])];
    [attachmentString addAttribute:NSBaselineOffsetAttributeName 
                             value:[NSNumber numberWithFloat:-1.0]
                             range:NSMakeRange(0,[attachmentString length])];
    NSAttributedString *nonMutableAttachmentString = [[NSAttributedString alloc] initWithAttributedString:attachmentString];
    [attachmentString release];
    return [nonMutableAttachmentString autorelease];
}

+ (NSAttributedString *)attributedStringWithString:(NSString *)string {
    return [[[NSAttributedString alloc] initWithString:string] autorelease];
}

@end
