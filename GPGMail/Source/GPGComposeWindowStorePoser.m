/* GPGComposeWindowStorePoser.m created by dave on Sun 14-Jan-2001 */

#import "GPGComposeWindowStorePoser.h"


@interface NSObject (GPGComposeWindowStorePoserRevelation)
- (id)textObject;
@end


@implementation GPGComposeWindowStorePoser

+ (void)load {
	[GPGComposeWindowStorePoser poseAsClass:[ComposeWindowStore class]];
}

- (void)gpgForwardAction:(SEL)actionSelector sender:(id)sender {
	NSEnumerator * anEnum = [_accessoryViewOwners objectEnumerator];
	id anOwner;

	while (anOwner = [anEnum nextObject])
		if ([anOwner respondsToSelector:actionSelector]) {
			[anOwner performSelector:actionSelector withObject:sender];
		}
}

- (IBAction)gpgToggleEncryptionForNewMessage:(id)sender {
	[self gpgForwardAction:_cmd sender:sender];
}

- (IBAction)gpgToggleSignatureForNewMessage:(id)sender {
	[self gpgForwardAction:_cmd sender:sender];
}

- (IBAction)gpgChoosePublicKeys:(id)sender {
	[self gpgForwardAction:_cmd sender:sender];
}

- (IBAction)gpgChoosePersonalKey:(id)sender {
	[self gpgForwardAction:_cmd sender:sender];
}

- (IBAction)gpgChoosePublicKey:(id)sender {
	[self gpgForwardAction:_cmd sender:sender];
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem {
	SEL anAction = [menuItem action];

	if (anAction == @selector(gpgChoosePublicKeys:) || anAction == @selector(gpgChoosePersonalKey:) || anAction == @selector(gpgChoosePublicKey:)) {
		NSEnumerator * anEnum = [_accessoryViewOwners objectEnumerator];
		id anOwner;

		while (anOwner = [anEnum nextObject])
			if ([anOwner respondsToSelector:anAction]) {
				return [anOwner validateMenuItem:menuItem];
			}
	}

	return [super validateMenuItem:menuItem];
}


- (void)textDidEndEditing:(NSNotification *)notification {
	if ([notification object] != [composeView textObject]) {
		[self gpgForwardAction:_cmd sender:notification];
	}

	[super textDidEndEditing:notification];
}

@end
