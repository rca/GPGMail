//
//  main.m
//  GPG Snip
//
//  Created by Lukas Pitschl on 15.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <Libmacgpg/Libmacgpg.h>
#import "NSSet+Functional.h"

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        
        GPGController *gpgc = [[GPGController alloc] init];
        NSSet *keys = [gpgc allKeys];
        
        for(GPGKey *key in [keys map:^(id obj) { return ((GPGKey *)obj).secret ? obj : NULL; }]) {
            NSLog(@"%@ <%@>: %@", key.name, key.email, key.fingerprint);
            for(GPGKey *subkey in [key subkeys]) {
                NSLog(@"** %@ <%@>: %@", subkey.name, subkey.email, subkey.fingerprint);    
            }
        }
        
        // Decode an email.
        NSData *encryptedData = [NSData dataWithContentsOfFile:@"/Users/lukele/Desktop/PGP.asc"];
        NSData *decryptedData = [gpgc decryptData:encryptedData];
        NSLog(@"Out data: %@", [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]); 
        
    }
    return 0;
}

