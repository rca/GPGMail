//
//  GPGMessageSignature.h
//  GPGMail
//
//  Created by Dave Lopper on 11/26/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GPGSignature;


@interface GPGMessageSignature : NSObject {
	GPGSignature *signature;
	NSRange signedRange;
}

- (id)initWithSignature:(GPGSignature *)signature range:(NSRange)range;

- (GPGSignature *)signature;
- (NSRange)signedRange;
- (BOOL)coversWholeMessage;

@end
