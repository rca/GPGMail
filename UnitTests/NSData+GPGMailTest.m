//
//  NSData+GPGMailTest.m
//  GPGMail
//
//  Created by Chris Fraire on 3/5/12.
//  Copyright (c) 2012 Chris Fraire. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NSData+GPGMail.h"

@interface NSData_GPGMailTest : SenTestCase

@end

@implementation NSData_GPGMailTest

- (void)testMightContainPGPEncryptedDataOrSignatures_1 {
    NSBundle *execBundl = [NSBundle bundleForClass:[self class]];
    NSString *file = [execBundl pathForResource:@"PGPMessageBlockGood" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    STAssertNotNil(data, @"Did not read Resource!");
    BOOL rc = [data mightContainPGPEncryptedDataOrSignatures];
    STAssertTrue(rc, @"Unexpected rc!");
}

- (void)testMightContainPGPEncryptedDataOrSignatures_2 {
    NSBundle *execBundl = [NSBundle bundleForClass:[self class]];
    NSString *file = [execBundl pathForResource:@"PGPMessageBlockBad" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    STAssertNotNil(data, @"Did not read Resource!");
    BOOL rc = [data mightContainPGPEncryptedDataOrSignatures];
    STAssertFalse(rc, @"Unexpected rc!");
}

- (void)testMightContainPGPEncryptedDataOrSignatures_3 {
    NSBundle *execBundl = [NSBundle bundleForClass:[self class]];
    NSString *file = [execBundl pathForResource:@"PGPMessageBlockGood2" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    STAssertNotNil(data, @"Did not read Resource!");
    BOOL rc = [data mightContainPGPEncryptedDataOrSignatures];
    STAssertTrue(rc, @"Unexpected rc!");
}

- (void)testMightContainPGPEncryptedDataOrSignatures_4 {
    NSBundle *execBundl = [NSBundle bundleForClass:[self class]];
    NSString *file = [execBundl pathForResource:@"PGPSignatureBlockGood" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    STAssertNotNil(data, @"Did not read Resource!");
    BOOL rc = [data mightContainPGPEncryptedDataOrSignatures];
    STAssertTrue(rc, @"Unexpected rc!");
}

- (void)testMightContainPGPEncryptedDataOrSignatures_5 {
    NSBundle *execBundl = [NSBundle bundleForClass:[self class]];
    NSString *file = [execBundl pathForResource:@"PGPSignatureBlockBad" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    STAssertNotNil(data, @"Did not read Resource!");
    BOOL rc = [data mightContainPGPEncryptedDataOrSignatures];
    STAssertFalse(rc, @"Unexpected rc!");
}

- (void)testRangeOfPGPPublicKey {
    NSBundle *execBundl = [NSBundle bundleForClass:[self class]];
    NSString *file = [execBundl pathForResource:@"PGPPublicKey" ofType:@"txt"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    STAssertNotNil(data, @"Did not read Resource!");
    NSRange match = [data rangeOfPGPPublicKey];
    STAssertEquals(21ul, match.location, @"Did not match public key!");
    STAssertEquals(72ul, match.length, @"Did not match public key!");
}

@end
