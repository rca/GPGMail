/* GPGVersionComparator.m created by dave on Thu 29-Jun-2000 */

/*
 * Copyright (c) 2000-2011, GPGTools Project Team <gpgtools-devel@lists.gpgtools.org>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of GPGTools Project Team nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE GPGTools Project Team ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE GPGTools Project Team BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "GPGVersionComparator.h"
#import <Libmacgpg/Libmacgpg.h>

typedef enum {
	characterTypePeriod,
	characterTypeNumber,
	characterTypeString
} VersionCharacterType;

@interface GPGVersionComparator ()
- (VersionCharacterType)typeOfCharacter:(unichar)character;
- (NSArray *)splitVersionString:(NSString *)version;
@end


@implementation GPGVersionComparator
GPGVersionComparator *_sharedInstance = nil;




- (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB {
	if ([[GPGOptions sharedOptions] boolForKey:@"DownloadBetaVersions"] == NO) {
		NSCharacterSet *caracterSet = [NSCharacterSet characterSetWithCharactersInString:@"abAB"];
		if ([versionA rangeOfCharacterFromSet:caracterSet].length > 0) {
			versionA = nil;
		}
		if ([versionB rangeOfCharacterFromSet:caracterSet].length > 0) {
			versionB = nil;
		}
		if (!versionA && !versionB) {
			return NSOrderedSame;
		} else if (versionA) {
			return NSOrderedDescending;
		} else {
			return NSOrderedAscending;
		}
	}
	
	if ([versionA isEqualToString:versionB]) {
		return NSOrderedSame;
	}
	
	VersionCharacterType typeA, typeB;
	NSString *partA, *partB;
	NSInteger intA, intB;
	NSComparisonResult result;
	NSArray *versionAParts = [self splitVersionString:versionA];
	NSArray *versionBParts = [self splitVersionString:versionB];
	NSUInteger countA = [versionAParts count], countB = [versionBParts count], count, i;
	count = MIN(countA, countB);
	
	for (i = 0; i < count; i++) {
		partA = [versionAParts objectAtIndex:i];
		partB = [versionBParts objectAtIndex:i];
		typeA = [self typeOfCharacter:[partA characterAtIndex:0]];
		typeB = [self typeOfCharacter:[partB characterAtIndex:0]];
		
		if (typeA == typeB) {
			if (typeA == characterTypeNumber) {
				intA = [partA integerValue];
				intB = [partB integerValue];
				if (intA > intB) {
					return NSOrderedDescending;
				} else if (intA < intB) {
					return NSOrderedAscending;
				}
			} else if (typeA == characterTypeString) {
				result = [partA compare:partB];
				if (result != NSOrderedSame) {
					return result;
				}
			}
		} else {
			if (typeA != characterTypeString && typeB == characterTypeString) {
                return NSOrderedDescending;
            } else if (typeA == characterTypeString && typeB != characterTypeString) {
                return NSOrderedAscending;
            } else {
				return typeA == characterTypeNumber ? NSOrderedDescending : NSOrderedAscending;
            }
		}		
	}
	
	if (countA > countB) {
		if ([self typeOfCharacter:[[versionAParts objectAtIndex:i] characterAtIndex:0]] == characterTypeString) {
			return NSOrderedAscending;
		}
		return NSOrderedDescending;
	} else if (countA < countB) {
		if ([self typeOfCharacter:[[versionBParts objectAtIndex:i] characterAtIndex:0]] == characterTypeString) {
			return NSOrderedDescending;
		}
		return NSOrderedAscending;
	}
	
	return NSOrderedSame;
}

- (VersionCharacterType)typeOfCharacter:(unichar)character {
	if (character == '.') {
		return characterTypePeriod;
	} else if (character >= '0' && character <= '9') {
		return characterTypeNumber;
	}
	return characterTypeString;
}

- (NSArray *)splitVersionString:(NSString *)version {
    NSMutableArray *parts = [NSMutableArray array];
	NSUInteger length = [version length], i, startLocation = 0;
	VersionCharacterType characterType, oldCharacterType;
	
	if (length == 0) {
		return parts;
	}
	oldCharacterType = [self typeOfCharacter:[version characterAtIndex:0]];
	
	for (i = 0; i < length; i++) {
		unichar character = [version characterAtIndex:i];
		characterType = [self typeOfCharacter:character];
		
		if (oldCharacterType == characterTypePeriod || characterType != oldCharacterType) {
			if (i > 0) {
				[parts addObject:[version substringWithRange:NSMakeRange(startLocation, i - startLocation)]];
			}
			oldCharacterType = characterType;
			startLocation = i;
		}
	}
	[parts addObject:[version substringWithRange:NSMakeRange(startLocation, i - startLocation)]];
	
	return parts;
}

	 
	 
	 

/*
+ (SUStandardVersionComparator *)defaultComparator
{
	static SUStandardVersionComparator *defaultComparator = nil;
	if (defaultComparator == nil)
		defaultComparator = [[SUStandardVersionComparator alloc] init];
	return defaultComparator;
}

- (SUCharacterType)typeOfCharacter:(NSString *)character
{
    if ([character isEqualToString:@"."]) {
        return kPeriodType;
    } else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[character characterAtIndex:0]]) {
        return kNumberType;
    } else {
        return kStringType;
    }	
}
- (NSArray *)splitVersionString:(NSString *)version
{
    NSString *character;
    NSMutableString *s;
    NSInteger i, n, oldType, newType;
    NSMutableArray *parts = [NSMutableArray array];
    if ([version length] == 0) {
        // Nothing to do here
        return parts;
    }
    s = [[[version substringToIndex:1] mutableCopy] autorelease];
    oldType = [self typeOfCharacter:s];
    n = [version length] - 1;
    for (i = 1; i <= n; ++i) {
        character = [version substringWithRange:NSMakeRange(i, 1)];
        newType = [self typeOfCharacter:character];
        if (oldType != newType || oldType == kPeriodType) {
            // We've reached a new segment
			NSString *aPart = [[NSString alloc] initWithString:s];
            [parts addObject:aPart];
			[aPart release];
            [s setString:character];
        } else {
            // Add character to string and continue
            [s appendString:character];
        }
        oldType = newType;
    }
    
    // Add the last part onto the array
    [parts addObject:[NSString stringWithString:s]];
    return parts;
}
- (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB;
{
	NSArray *partsA = [self splitVersionString:versionA];
    NSArray *partsB = [self splitVersionString:versionB];
    
    NSString *partA, *partB;
    NSInteger i, n, typeA, typeB, intA, intB;
    
    n = MIN([partsA count], [partsB count]);
    for (i = 0; i < n; ++i) {
        partA = [partsA objectAtIndex:i];
        partB = [partsB objectAtIndex:i];
        
        typeA = [self typeOfCharacter:partA];
        typeB = [self typeOfCharacter:partB];
        
        // Compare types
        if (typeA == typeB) {
            // Same type; we can compare
            if (typeA == kNumberType) {
                intA = [partA intValue];
                intB = [partB intValue];
                if (intA > intB) {
                    return NSOrderedDescending;
                } else if (intA < intB) {
                    return NSOrderedAscending;
                }
            } else if (typeA == kStringType) {
                NSComparisonResult result = [partA compare:partB];
                if (result != NSOrderedSame) {
                    return result;
                }
            }
        } else {
            // Not the same type? Now we have to do some validity checking
            if (typeA != kStringType && typeB == kStringType) {
                // typeA wins
                return NSOrderedDescending;
            } else if (typeA == kStringType && typeB != kStringType) {
                // typeB wins
                return NSOrderedAscending;
            } else {
                // One is a number and the other is a period. The period is invalid
                if (typeA == kNumberType) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }
        }
    }
    // The versions are equal up to the point where they both still have parts
    // Lets check to see if one is larger than the other
    if ([partsA count] != [partsB count]) {
        // Yep. Lets get the next part of the larger
        // n holds the index of the part we want.
        NSString *missingPart;
        SUCharacterType missingType;
		NSComparisonResult shorterResult, largerResult;
        
        if ([partsA count] > [partsB count]) {
            missingPart = [partsA objectAtIndex:n];
            shorterResult = NSOrderedAscending;
            largerResult = NSOrderedDescending;
        } else {
            missingPart = [partsB objectAtIndex:n];
            shorterResult = NSOrderedDescending;
            largerResult = NSOrderedAscending;
        }
        
        missingType = [self typeOfCharacter:missingPart];
        // Check the type
        if (missingType == kStringType) {
            // It's a string. Shorter version wins
            return shorterResult;
        } else {
            // It's a number/period. Larger version wins
            return largerResult;
        }
    }
    
    // The 2 strings are identical
    return NSOrderedSame;
}
*/


+ (id)sharedVersionComparator {
    if (!_sharedInstance) {
        _sharedInstance = [[super allocWithZone:nil] init];
    }
    return _sharedInstance;	
}
- (id)init {
	return self;
}
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedVersionComparator] retain];	
}
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
- (id)retain {
    return self;
}
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}
- (oneway void)release {
}
- (id)autorelease {
    return self;
}


@end
