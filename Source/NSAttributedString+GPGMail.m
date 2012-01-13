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
    // If link is nil, just create the attachment with the image.
    if(link) {
        [attachmentString addAttribute:NSLinkAttributeName value:link 
                                 range:NSMakeRange(0, [attachmentString length])];
    }
    [attachmentString addAttribute:NSCursorAttributeName value:[NSCursor arrowCursor] 
                             range:NSMakeRange(0, [attachmentString length])];
    float offset = -1.0;
    if([link isEqualToString:@"gpgmail://show-signature"])
        offset = -2.0;
    
    if([link isEqualToString:@"gpgmail://show-attachments"])
        offset = -3.0;
    
    [attachmentString addAttribute:NSBaselineOffsetAttributeName 
                             value:[NSNumber numberWithFloat:offset]
                             range:NSMakeRange(0,[attachmentString length])];
    NSAttributedString *nonMutableAttachmentString = [[NSAttributedString alloc] initWithAttributedString:attachmentString];
    [attachmentString release];
    return [nonMutableAttachmentString autorelease];
}

+ (NSAttributedString *)attributedStringWithString:(NSString *)string {
    return [[[NSAttributedString alloc] initWithString:string] autorelease];
}

@end
