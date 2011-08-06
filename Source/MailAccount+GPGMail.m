//
//  MailAccount.m
//  GPGMail
//
//  Created by Lukas Pitschl on 03.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MailAccount+GPGMail.h"

@implementation MailAccount_GPGMail

// TODO: Only display security view if OpenPGP keys are available
//       for signing. Analog to S/MIME
+ (BOOL)MAAccountExistsForSigning {
    return YES;
}

@end
