//
//  MessageAttachment+GPGMail.m
//  GPGMail
//
//  Created by Lukas Pitschl on 17.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+GPGMail.h"
#import "MessageAttachment+GPGMail.h"

@implementation MessageAttachment_GPGMail

- (id)MAFilename {
    id filename = [self MAFilename];
    MimePart *part = [((MessageAttachment *)self) mimePart];
    if(part.PGPAttachment && part.PGPDecrypted)
        return [[filename lastPathComponent] stringByDeletingPGPExtension];
    
    return filename;
}

@end
