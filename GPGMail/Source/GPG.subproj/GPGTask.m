/* GPGTask.m created by dave on Sat 30-Dec-2000 */

/*
 *	Copyright GPGMail Project Team (gpgmail-devel@lists.gpgmail.org), 2000-2010
 *	(see LICENSE.txt file for license information)
 */

#import "GPGTask.h"
#import <Foundation/Foundation.h>
#import <unistd.h>
#import <sys/wait.h>


@implementation GPGTask

+ (NSTask *)launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments {
	GPGTask * aTask = [[self alloc] init];

	[aTask setLaunchPath:path];
	[aTask setArguments:arguments];

	return [aTask autorelease];
}

- (int)terminationStatus {
	if (_isRunning || !_hasExeced) {
		[NSException raise:NSInvalidArgumentException format:@"Task has not been launched or is running."];
	}
	return _terminationStatus;
}

- (BOOL)isRunning {
	return _isRunning;
}

- (void)launch {
	if (_isRunning || _hasExeced) {
		[NSException raise:NSGenericException format:@"Task has already been launched or is running."];
	}

	fflush(stderr);
//    fflush(stdout);
//    fflush(stdin);

	_pid = fork();
	if (_pid == 0) {
		// Child process
		int retVal;
		NSString * launchPath = [self launchPath];
		NSString * aString;
		char ** taskArgv;
		NSPipe * aPipe;
		int i, count;
		NSArray * arguments = [self arguments];
		NSDictionary * environment = [self environment];

		for (i = 0; i < 32; i++) {
			signal(i, SIG_DFL);
		}
		setpgrp(getpid(), getpid());

		if (!launchPath) {
			[NSException raise:NSInvalidArgumentException format:@"No launch path set"];
		}

		aString = [self currentDirectoryPath];
		if (aString != nil) {
			if (chdir([aString cString]) != 0) {
				[NSException raise:NSInvalidArgumentException format:@"Invalid current directory path (%d: %s)", errno, strerror(errno)];
			}
		}

		aPipe = [_dictionary objectForKey:@"standardInput"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			if (dup2([[aPipe fileHandleForReading] fileDescriptor], 0) == -1) {
				[NSException raise:NSInvalidArgumentException format:@"Unable to dup2(%d, 0) (%d: %s)", [[aPipe fileHandleForReading] fileDescriptor], errno, strerror(errno)];
			} else {
				[[aPipe fileHandleForWriting] closeFile];
				[[aPipe fileHandleForReading] closeFile];
			}
		}
		aPipe = [_dictionary objectForKey:@"standardOutput"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			if (dup2([[aPipe fileHandleForWriting] fileDescriptor], 1) == -1) {
				[NSException raise:NSInvalidArgumentException format:@"Unable to dup2(%d, 1) (%d: %s)", [[aPipe fileHandleForWriting] fileDescriptor], errno, strerror(errno)];
			} else {
				[[aPipe fileHandleForWriting] closeFile];
				[[aPipe fileHandleForReading] closeFile];
			}
		}
		aPipe = [_dictionary objectForKey:@"statusPipe"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			[[aPipe fileHandleForReading] closeFile];
		}
		aPipe = [_dictionary objectForKey:@"standardError"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			if (dup2([[aPipe fileHandleForWriting] fileDescriptor], 2) == -1) {
				[NSException raise:NSInvalidArgumentException format:@"Unable to dup2(%d, 2) (%d: %s)", [[aPipe fileHandleForWriting] fileDescriptor], errno, strerror(errno)];
			} else {
				[[aPipe fileHandleForWriting] closeFile];
				[[aPipe fileHandleForReading] closeFile];
			}
		}

		count = [arguments count];
		taskArgv = NSZoneMalloc(NSDefaultMallocZone(), (sizeof * taskArgv) * (count + 1 + 1));
		taskArgv[0] = (char *)[launchPath cString];
		for (i = 0; i < count; i++) {
			taskArgv[i + 1] = (char *)[[arguments objectAtIndex:i] cString];
		}
		taskArgv[i + 1] = NULL;

		if (environment) {
			char ** envArray;

			arguments = [environment allKeys];
			count = [arguments count];
			envArray = NSZoneMalloc(NSDefaultMallocZone(), (sizeof * envArray) * (count + 1));
			for (i = 0; i < count; i++) {
				NSString * formattedEnv = [NSString stringWithFormat:@"%@=%@", [arguments objectAtIndex:i], [environment objectForKey:[arguments objectAtIndex:i]]];

				envArray[i] = (char *)[formattedEnv cString];
			}
			envArray[i] = NULL;

			retVal = execve([launchPath cString], taskArgv, envArray);
		} else {
			retVal = execv([launchPath cString], taskArgv);
		}

		// Never reached if exec was unsuccessful
		[NSException raise:NSInvalidArgumentException format:@"Unable to exec process (%d: %s)", errno, strerror(errno)];
	} else if (_pid < 0) {
		// Error!
		[NSException raise:NSInvalidArgumentException format:@"Unable to fork process (%d: %s)", errno, strerror(errno)];
	} else {
		// Parent process
		NSPipe * aPipe;

		aPipe = [_dictionary objectForKey:@"standardInput"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			[[aPipe fileHandleForReading] closeFile];
		}
		aPipe = [_dictionary objectForKey:@"standardOutput"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			[[aPipe fileHandleForWriting] closeFile];
		}
		aPipe = [_dictionary objectForKey:@"standardError"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			[[aPipe fileHandleForWriting] closeFile];
		}
		aPipe = [_dictionary objectForKey:@"statusPipe"];
		if (aPipe != nil && [aPipe isKindOfClass:[NSPipe class]]) {
			[[aPipe fileHandleForWriting] closeFile];
		}
		_isRunning = YES;
	}
}

- (void)setArguments:(NSArray *)arguments {
	if (_isRunning || _hasExeced) {
		[NSException raise:NSInvalidArgumentException format:@"Task has already been launched or is running."];
	}
	if (arguments != nil) {
		[_dictionary setObject:arguments forKey:@"arguments"];
	} else {
		[_dictionary removeObjectForKey:@"arguments"];
	}
}

- (void)setCurrentDirectoryPath:(NSString *)path {
	if (_isRunning || _hasExeced) {
		[NSException raise:NSInvalidArgumentException format:@"Task has already been launched or is running."];
	}
	NSParameterAssert(path != nil);

	[_dictionary setObject:path forKey:@"currentDirectoryPath"];
}

- (void)setEnvironment:(NSDictionary *)dict {
	if (_isRunning || _hasExeced) {
		[NSException raise:NSInvalidArgumentException format:@"Task has already been launched or is running."];
	}
	NSParameterAssert(dict != nil);

	[_dictionary setObject:dict forKey:@"environment"];
}

- (void)setLaunchPath:(NSString *)path {
	if (_isRunning || _hasExeced) {
		[NSException raise:NSInvalidArgumentException format:@"Task has already been launched or is running."];
	}
	NSParameterAssert(path != nil);

	[_dictionary setObject:path forKey:@"launchPath"];
}

- (void)interrupt {
	if (!_isRunning) {
		[NSException raise:NSInvalidArgumentException format:@"Task is not running."];
	}
	if (kill(_pid, SIGINT) != 0) {
		perror("On interrupt of process");
	}
}

- (void)terminate {
	if (!_isRunning && !_hasExeced) {
		[NSException raise:NSInvalidArgumentException format:@"Task has not yet been launched."];
	}
	if (kill(_pid, SIGTERM) != 0) {
		perror("On termination of process");
	}
}

- (NSString *)launchPath {
	return [_dictionary objectForKey:@"launchPath"];
}

- (NSDictionary *)environment {
	return [_dictionary objectForKey:@"environment"];
}

- (NSArray *)arguments {
	return [_dictionary objectForKey:@"arguments"];
}

- (NSString *)currentDirectoryPath {
	return [_dictionary objectForKey:@"currentDirectoryPath"];
}

- (void)setStandardInput:(id)input {
	NSParameterAssert(input != nil);

	[_dictionary setObject:input forKey:@"standardInput"];
}

- (void)setStandardOutput:(id)output {
	NSParameterAssert(output != nil);

	[_dictionary setObject:output forKey:@"standardOutput"];
}

- (void)setStandardError:(id)error {
	NSParameterAssert(error != nil);

	[_dictionary setObject:error forKey:@"standardError"];
}

- (void)setStatusPipe:(NSPipe *)statusPipe {
	NSParameterAssert(statusPipe != nil);

	[_dictionary setObject:statusPipe forKey:@"statusPipe"];
}

- (id)standardInput {
	return [_dictionary objectForKey:@"standardInput"];
}

- (id)standardOutput {
	return [_dictionary objectForKey:@"standardOutput"];
}

- (id)standardError {
	return [_dictionary objectForKey:@"standardError"];
}

- (NSPipe *)statusPipe {
	return [_dictionary objectForKey:@"statusPipe"];
}

- (id)init {
	if (self = [super init]) {
		_dictionary = [[NSMutableDictionary allocWithZone:[self zone]] init];
	}

	return self;
}

- (void)dealloc {
	[_dictionary release];

	[super dealloc];
}

- (void)waitUntilExit {
	if (_isRunning) {
		int status = 0;
		int retVal = waitpid(_pid, &status, 0);

		if (retVal == _pid) {
			if (WIFEXITED(status)) {
				_terminationStatus = WEXITSTATUS(status);
			} else if (WIFSIGNALED(status)) {
				_terminationStatus = -1;
				// x = WTERMSIG(status);
			} else if (WIFSTOPPED(status)) {
				_terminationStatus = -1;
				// x = WSTOPSIG(status);
			}
		} else {
			perror("On wait for process");
		}
		_isRunning = NO;
		_hasExeced = YES;
	}
}

@end
