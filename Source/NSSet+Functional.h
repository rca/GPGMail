//
//  NSSet+Functional.h
//  GPGMail
//
//  Created by Lukas Pitschl on 15.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSSet (Functional)

- (NSSet *)map:(id (^)(id))block;

@end

