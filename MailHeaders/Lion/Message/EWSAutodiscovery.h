/*
 *     Generated by class-dump 3.3.3 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2010 by Steve Nygard.
 */



#import "EWSAutodiscoverBindingDelegate-Protocol.h"

@class NSDictionary, NSError, NSString, NSURL;

@interface EWSAutodiscovery : NSObject <EWSAutodiscoverBindingDelegate>
{
    NSString *_emailAddress;
    NSString *_password;
    NSString *_userName;
    NSURL *_preferredAutodiscoverURL;
    NSDictionary *_receivingAccountInfo;
    long long _status;
    NSError *_lastError;
}

+ (void)initialize;
- (id)init;
- (id)initWithEmailAddress:(id)arg1 userName:(id)arg2 password:(id)arg3 preferredAutodiscoverURL:(id)arg4;
- (void)dealloc;
- (long long)executeSynchronouslyWithMonitor:(id)arg1;
- (void)autodiscoverBinding:(id)arg1 didCancelAuthenticationChallenge:(id)arg2;
- (void)autodiscoverBinding:(id)arg1 didReceiveAuthenticationChallenge:(id)arg2;
- (void)autodiscoverBinding:(id)arg1 didFinishWithResponse:(id)arg2;
- (void)autodiscoverBinding:(id)arg1 didFailWithError:(id)arg2;
- (void)autodiscoverBinding:(id)arg1 didReceiveCertificateError:(id)arg2;
@property(copy) NSError *lastError; // @synthesize lastError=_lastError;
@property long long status; // @synthesize status=_status;
@property(copy) NSDictionary *receivingAccountInfo; // @synthesize receivingAccountInfo=_receivingAccountInfo;
@property(copy, nonatomic) NSURL *preferredAutodiscoverURL; // @synthesize preferredAutodiscoverURL=_preferredAutodiscoverURL;
@property(copy) NSString *userName; // @synthesize userName=_userName;
@property(copy, nonatomic) NSString *password; // @synthesize password=_password;
@property(copy, nonatomic) NSString *emailAddress; // @synthesize emailAddress=_emailAddress;

@end

