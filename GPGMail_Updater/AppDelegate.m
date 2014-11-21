#import "AppDelegate.h"

@implementation AppDelegate

- (id)init {
	self = [super init];
	if (!self) {
		return nil;
	}
	
	GPGOptions *options = [GPGOptions sharedOptions];
	options.standardDomain = @"org.gpgtools.gpgmail";
	
	NSDictionary *defaults = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SparkleDefaults" ofType:@"plist"]];
	[options registerDefaults:defaults];
	
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

- (NSString *)feedURLStringForUpdater:(SUUpdater *)updater {
	NSString *updateSourceKey = @"UpdateSource";
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	
	NSString *feedURLKey = @"SUFeedURL";
	NSString *appcastSource = [[GPGOptions sharedOptions] stringForKey:updateSourceKey];
	if ([appcastSource isEqualToString:@"nightly"]) {
		feedURLKey = @"SUFeedURL_nightly";
	} else if ([appcastSource isEqualToString:@"prerelease"]) {
		feedURLKey = @"SUFeedURL_prerelease";
	} else {
		NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
		if ([version rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"nN"]].length > 0) {
			feedURLKey = @"SUFeedURL_nightly";
		} else if ([version rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"abAB"]].length > 0) {
			feedURLKey = @"SUFeedURL_prerelease";
		}
	}
	
	NSString *appcastURL = [bundle objectForInfoDictionaryKey:feedURLKey];
	if (!appcastURL) {
		appcastURL = [bundle objectForInfoDictionaryKey:@"SUFeedURL"];
	}
	return appcastURL;
}

@end
