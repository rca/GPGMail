//
//  GPGMailTextAttachmentPoser.m
//  GPGMail
//
//  Created by Dave Lopper on Sat May 31 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "GPGMailTextAttachmentPoser.h"
#import "GPGMailPatching.h"
//#import <MimePart.h>

// Currently useless, because Content-Description header is not parsed:
// -contentDescription always returns nil

@implementation MailTextAttachment(GPGMail)

static IMP  MailTextAttachment_toolTip = NULL;

+ (void) load
{
    MailTextAttachment_toolTip = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(toolTip), [MailTextAttachment class], @selector(gpgToolTip), [MailTextAttachment class]);
}

- gpgToolTip
{
    NSString	*toolTip = ((id (*)(id, SEL))MailTextAttachment_toolTip)(self, _cmd);
    NSString	*contentDescription = [[self mimePart] contentDescription];

    if(contentDescription != nil && [contentDescription length] > 0){
        toolTip = [contentDescription stringByAppendingFormat:@"\n\n%@", toolTip];
    }
    return toolTip;
}

@end
