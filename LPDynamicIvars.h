//
//  Category.h
//  GPGMail
//
//  Created by Lukas Pitschl on 17.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LPDynamicIvars)

- (void)setIvar:(id)key value:(id)value;
- (id)getIvar:(id)key;
- (void)removeIvar:(id)key;
- (BOOL)ivarExists:(id)key;

@end
