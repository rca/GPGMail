//
//  GPGMailTest.m
//  GPGMail
//
//  Created by Lukas Pitschl on 03.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GPGMailTest.h"


@implementation GPGMailTest

- (id)init {
	if((self = [super init])) {
		NSBundle *main = [NSBundle mainBundle];
		NSString *path = [[main builtInPlugInsPath] stringByAppendingPathComponent:@"GPGMail.mailbundle"];
		NSBundle *bundle = [NSBundle bundleWithPath:path];
		NSLog(@"Bundle: %@", bundle);
		NSError *error = nil;
		[bundle loadAndReturnError:&error];
		NSLog(@"error: %@", error);
	}
	return self;
}

@end
