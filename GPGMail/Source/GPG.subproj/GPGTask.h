/* GPGTask.h created by dave on Sat 30-Dec-2000 */

/*
 *	Copyright Stephane Corthesy (stephane@sente.ch), 2000-2001
 *	(see LICENSE.txt file for license information)
 */

#import <Foundation/NSTask.h>
#import <sys/types.h>


@class NSMutableDictionary;
@class NSPipe;


/*
 *	We need to create our own NSTask's concrete subclass, as processes 
 *	launched by NSTask do not inherit file descriptors from their
 *	parent process, except stdin, stdout and stderr.
 *	Do NOT try to use this class for anything else, as the implementation
 *	is far from complete; currently it just fits my needs :-)
 *	A big THANK YOU to the GNUstep guys! Their code helped me understand
 *	how I could implement this class.
 */

@interface GPGTask : NSTask
{
    NSMutableDictionary	*_dictionary;
    BOOL				_hasExeced;
    BOOL				_isRunning;
    pid_t				_pid;
    int					_terminationStatus;
}

////+ (id) allocWithZone:(NSZone *)zone;
////+ currentTaskDictionary;
////+ launchedTaskWithDictionary:fp12;
+ (NSTask *) launchedTaskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments;
////+ launchedTaskWithPath:fp12 arguments:fp16;
- (int) terminationStatus;
- (BOOL) isRunning;
- (void) launch;
- (void) setArguments:(NSArray *)arguments;
- (void) setCurrentDirectoryPath:(NSString *)path;
- (void) setEnvironment:(NSDictionary *)dict;
- (void) setLaunchPath:(NSString *)path;
- (void) interrupt;
- (void) terminate;
- (NSString *) launchPath;
- (NSDictionary *) environment;
- (NSArray *) arguments;
- (NSString *) currentDirectoryPath;
- (void) setStandardInput:(id)input;
- (void) setStandardOutput:(id)output;
- (void) setStandardError:(id)error;
- (id) standardInput;
- (id) standardOutput;
- (id) standardError;
- (id) init;
- (void) dealloc;

- (void) waitUntilExit;
//- (void)launchWithDictionary:fp12;
//- (void)setTaskDictionary:fp12;
//- taskDictionary;
//- (BOOL)taskExitedNormally;
//- (void)terminateTask;
//- (int)_procid;
//- (unsigned int)processIdentifier;
//- (void)_requestNotification;
//- (void)handleMachMessage:(void *)fp12;

// gnupg specific!
- (void) setStatusPipe:(NSPipe *)statusPipe;
- (NSPipe *) statusPipe;

@end
