#import "AppDelegate.h"

@implementation AppDelegate

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	GPGOptions *options = [GPGOptions sharedOptions];
	options.standardDomain = @"org.gpgtools.gpgmail";
	return self;
}

- (void)terminateIfIdle {
	if (![updater updateInProgress]) {
		[NSApp terminate:nil];
	}
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	updater = [SUUpdater sharedUpdater];
	updater.delegate = self;
	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
	if ([arguments containsObject:@"checkNow"]) {
		[updater checkForUpdates:nil];
	}
	[NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(terminateIfIdle) userInfo:nil repeats:YES];
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)updater {
	return @"/Applications/Mail.app";
}
- (id)userDefaults {
    return [GPGOptions sharedOptions];
}

/*- (BOOL)updater:(id / *GPGTSUUpdater * /)updater relaunchUsingPath:(NSString *)path arguments:(NSArray *)arguments {
    [GPGTask launchGeneralTask:path withArguments:arguments];
    return YES;
}*/

- (void)updateAlert:(SUUpdateAlert *)updateAlert willShowReleaseNotesWithSize:(NSSize *)size {
	size->width = 600;
	size->height = 350;
}

@end
