//
//  GPGTextDocumentViewerPoser.h
//  GPGMail
//
//  Created by Stéphane Corthésy on Mon Sep 16 2002.
//

/*
 *	Copyright Stephane Corthesy (stephane@sente.ch), 2000-2003
 *	(see LICENSE.txt file for license information)
 */

#import <TextDocumentViewer.h>


@interface GPGTextDocumentViewerPoser : TextDocumentViewer
{

}

- (void) gpgShowPGPSignatureBanner;
- (void) gpgShowPGPEncryptedBanner;
- (void) gpgHideBanner;

- (BOOL) gpgValidateAction:(SEL)anAction;

// Actions connected to menus
- (IBAction) gpgDecrypt:(id)sender;
- (IBAction) gpgAuthenticate:(id)sender;

@end
