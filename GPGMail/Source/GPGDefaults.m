//
//  GPGDefaultsController.m
//  GPGMail
//
//  Created by Roman Zechmeister on 05.11.10.
//  Copyright 2010 Roman Zechmeister. All rights reserved.
//

#import "GPGDefaults.h"

NSString *gpgDefaultsDomain = @"org.gpgtools.common";
NSString *GPGDefaultsUpdatedNotification = @"org.gpgtools.GPGDefaultsUpdatedNotification";

@interface GPGDefaults (Private)
- (void)refreshDefaults;
- (NSMutableDictionary *)defaults;
- (void)writeToDisk;
- (void)defaultsDidUpdated:(NSNotification *)notification;
- (void)setGPGConf:(id)value forKey:(NSString *)defaultName;
@end


@implementation GPGDefaults
static NSMutableDictionary *_sharedInstances = nil;

+ (id)gpgDefaults {
	return [self defaultsWithDomain:gpgDefaultsDomain];
}
+ (id)standardDefaults {
	return [self defaultsWithDomain:[[NSBundle bundleForClass:[self class]] bundleIdentifier]];
}
+ (id)defaultsWithDomain:(NSString *)domain  {
	if (!_sharedInstances) {
		_sharedInstances = [[NSMutableDictionary alloc] initWithCapacity:2];
	}
	GPGDefaults *defaultsController = [_sharedInstances objectForKey:domain];
	if (!defaultsController) {
		defaultsController = [[self alloc] initWithDomain:domain];
		[_sharedInstances setObject:defaultsController forKey:domain];
		[defaultsController release];
	}
	return defaultsController;
}
- (id)initWithDomain:(NSString *)domain {
	if ([self init]) {
		self.domain = domain;
	}
	return self;
}
- (id)init {
	if (self = [super init]) {
		_defaults = nil;
		_defaultDictionarys = nil;
		_defaultsLock = [[NSLock alloc] init];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsDidUpdated:) name:GPGDefaultsUpdatedNotification object:nil];
	}
	return self;
}

- (void)setDomain:(NSString *)value {
	if (value != _domain) {
		NSString *old = _domain;
		_domain = [value retain];
		[old release];
	}
}
- (NSString *)domain {
	return _domain;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
	[_defaultsLock lock];
	[self.defaults setObject:value forKey:defaultName];
	[_defaultsLock unlock];
	[self writeToDisk];
	[self setGPGConf:[value description] forKey:defaultName];
}
- (id)objectForKey:(NSString *)defaultName {
	[_defaultsLock lock];
	NSDictionary *dict = self.defaults;
	NSObject *obj = [dict objectForKey:defaultName];
	if (!obj && _defaultDictionarys) {
		for	(NSDictionary *dictionary in _defaultDictionarys) {
			obj = [dictionary objectForKey:defaultName];
			if (obj) {
				break;
			}
		}
	}
	[_defaultsLock unlock];
	return obj;
}
- (void)removeObjectForKey:(NSString *)defaultName {
	[_defaultsLock lock];
	[self.defaults removeObjectForKey:defaultName];
	[_defaultsLock unlock];
	[self writeToDisk];
	[self setGPGConf:nil forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
	[self setObject:[NSNumber numberWithInteger:value] forKey:defaultName];
}
- (NSInteger)integerForKey:(NSString *)defaultName {
	return [[self objectForKey:defaultName] integerValue];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
	[self setObject:[NSNumber numberWithBool:value] forKey:defaultName];
}
- (BOOL)boolForKey:(NSString *)defaultName {
	return [[self objectForKey:defaultName] boolValue];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName {
	[self setObject:[NSNumber numberWithFloat:value] forKey:defaultName];
}
- (float)floatForKey:(NSString *)defaultName {
	return [[self objectForKey:defaultName] floatValue];
}

- (NSString *)stringForKey:(NSString *)defaultName {
	NSString *obj = [self objectForKey:defaultName];
	if (obj && [obj isKindOfClass:[NSString class]]) {
		return obj;
	}
	return nil;
}

- (NSArray *)arrayForKey:(NSString *)defaultName {
	NSArray *obj = [self objectForKey:defaultName];
	if (obj && [obj isKindOfClass:[NSArray class]]) {
		return obj;
	}
	return nil;	
}

- (NSDictionary *)dictionaryRepresentation {
	[_defaultsLock lock];
	NSDictionary *retDict = [self.defaults copy];
	[_defaultsLock unlock];
	return [retDict autorelease];
}

- (void)registerDefaults:(NSDictionary *)dictionary {
	if (!_defaultDictionarys) {
		_defaultDictionarys = [[NSSet alloc] initWithObjects:dictionary, nil];
	} else {
		NSSet *oldDictionary = _defaultDictionarys;
		_defaultDictionarys = [[_defaultDictionarys setByAddingObject:dictionary] retain];
		[oldDictionary release];
	}
}


//Private

- (void)setGPGConf:(id)value forKey:(NSString *)defaultName {
	GPGConfiguration *conf;
	NSString *key;
	
	
	if ([defaultName isEqualToString:@"GPGPassphraseFlushTimeout"]) {
		conf = [GPGConfiguration gpgAgentConf];
		
		NSInteger cacheTime = [value integerValue];
		if (cacheTime == 0) {
			cacheTime = 600;
		}
		[conf setString:[NSString stringWithFormat:@"%i", cacheTime] forKey:@"default-cache-ttl"];

		cacheTime *= 12;
		if (cacheTime <= 600) {
			cacheTime = 600;
		}
		[conf setString:[NSString stringWithFormat:@"%i", cacheTime] forKey:@"max-cache-ttl"];
		
		[GPGConfiguration gpgAgentFlush]; // gpg-agent should read the new configuration.
	} else if ([defaultName isEqualToString:@"GPGDefaultKeyFingerprint"]) {
		conf = [GPGConfiguration gpgConf];
		[conf setString:value forKey:@"default-key"];
	} else if ([defaultName isEqualToString:@"GPGRemembersPassphrasesDuringSession"]) {
		conf = [GPGConfiguration gpgAgentConf];
		
		if ([value boolValue]) {
			NSInteger cacheTime = [[conf stringForKey:@"default-cache-ttl"] integerValue];
			if (cacheTime <= 600) {
				cacheTime = 600;
			}
			[conf setString:[NSString stringWithFormat:@"%i", cacheTime] forKey:@"max-cache-ttl"];
		} else {
			[conf setString:@"0" forKey:@"max-cache-ttl"];
		}

		[GPGConfiguration gpgAgentFlush]; // gpg-agent should read the new configuration.
	}
}

- (void)refreshDefaults {
	NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] persistentDomainForName:_domain];
	NSMutableDictionary *old = _defaults;
	if (dictionary) {
		_defaults = [[dictionary mutableCopy] retain];
	} else {
		_defaults = [[NSMutableDictionary alloc] initWithCapacity:1];
	}
	[old release];
}

- (NSMutableDictionary *)defaults {
	if (!_defaults) {
		[self refreshDefaults];
	}
	return [[_defaults retain] autorelease];
}

- (void)writeToDisk {
	[_defaultsLock lock];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:self.defaults forName:_domain];
	[_defaultsLock unlock];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_domain, @"domain", [NSNumber numberWithInteger:(NSInteger)self], @"sender", nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:GPGDefaultsUpdatedNotification object:@"org.gpgtools.GPGDefaults" userInfo:userInfo];
}

- (void)defaultsDidUpdated:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	if ([[userInfo objectForKey:@"sender"] integerValue] != (NSInteger)self) {
		if ([[userInfo objectForKey:@"domain"] isEqualToString:_domain]) {
			[self refreshDefaults];
		}
	}
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[_defaults release];
	self.domain = nil;
	[_defaultsLock release];
	[_defaultDictionarys release];
	[super dealloc];
}

@end

@implementation GPGConfiguration
@synthesize confFile;

+ (void)gpgAgentFlush {
	system("killall -SIGHUP gpg-agent");	
}
+ (id)gpgConf {
	GPGConfiguration *obj = [[self alloc] initWithConfFile:[@"~/.gnupg/gpg.conf" stringByExpandingTildeInPath]];
	return obj;
}
+ (id)gpgAgentConf {
	GPGConfiguration *obj = [[self alloc] initWithConfFile:[@"~/.gnupg/gpg-agent.conf" stringByExpandingTildeInPath]];
	return obj;
}
- (id)initWithConfFile:(NSString *)path {
	if ([self init]) {
		self.confFile = path;
	}
	return self;
}

- (void)setString:(NSString *)value forKey:(NSString *)key {
	NSError *error;
	NSStringEncoding encoding;
	NSMutableString *confText = [NSMutableString stringWithContentsOfFile:confFile usedEncoding:&encoding error:&error];
	
	
	BOOL edited = NO;
	if (confText == nil) {
		if ([error code] != 260) {
			return;
		}
		edited = YES;
		confText = [NSMutableString string];
		encoding = NSUTF8StringEncoding;
	}
	
	NSString *rawKey, *rawNoKey;
	if ([key hasPrefix:@"no-"]) {
		rawKey = [key substringFromIndex:3];
		rawNoKey = key;
	} else {
		rawKey = key;
		rawNoKey = [@"no-" stringByAppendingString:key];
	}
	
	
	NSUInteger length = [confText length];
	NSInteger foundPos = -1;
	NSRange range, lineRange, searchRange;
	searchRange.location = 0;
	searchRange.length = length;
	
	while ((range = [confText rangeOfString:rawKey options:NSCaseInsensitiveSearch range:searchRange]).length > 0) {
		lineRange = [confText lineRangeForRange:range];
		NSString *lineText = [[confText substringWithRange:lineRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		NSUInteger charPos = [lineText rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location;
		
		if ([lineText hasPrefix:rawKey] && [rawKey length] == charPos || [lineText hasPrefix:rawNoKey] && [rawNoKey length] == charPos) {
			edited = YES;
			[confText deleteCharactersInRange:lineRange];
			foundPos = lineRange.location;
			length -= lineRange.length;
			lineRange.length = 0;			
		}
		
		searchRange.location = lineRange.location + lineRange.length;
		searchRange.length = length - searchRange.location;
	}
	
	if (value) {
		edited = YES;
		if (foundPos == -1) {
			foundPos = length;
		}
		[confText insertString:[NSString stringWithFormat:@"%@ %@\n", key, value] atIndex:foundPos];		
	}
	if (edited) {
		[confText writeToFile:confFile atomically:YES encoding:encoding error:nil];
	}
}

- (NSString *)stringForKey:(NSString *)key {
	NSMutableString *confText = [NSMutableString stringWithContentsOfFile:confFile usedEncoding:nil error:nil];
	if (confText == nil) {
		return nil;
	}
	
	
	NSString *rawKey, *rawNoKey;
	if ([key hasPrefix:@"no-"]) {
		rawKey = [key substringFromIndex:3];
		rawNoKey = key;
	} else {
		rawKey = key;
		rawNoKey = [@"no-" stringByAppendingString:key];
	}
	
	
	NSUInteger length = [confText length];
	NSRange range, lineRange, searchRange;
	searchRange.location = 0;
	searchRange.length = length;
	
	while ((range = [confText rangeOfString:rawKey options:NSCaseInsensitiveSearch range:searchRange]).length > 0) {
		lineRange = [confText lineRangeForRange:range];
		NSString *lineText = [[confText substringWithRange:lineRange] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		NSUInteger charPos = [lineText rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location;
		
		if ([lineText hasPrefix:rawKey] && [rawKey length] == charPos) {
			range.location = [rawKey length] + 1;
			range.length = lineRange.length - range.location - 1;
			NSString *retText = [[lineText substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if ([retText length] == 0) {
				return rawKey;
			} else {
				return retText;
			}
		} else if ([lineText hasPrefix:rawNoKey] && [rawNoKey length] == charPos) {
			return rawNoKey;
		}
		
		searchRange.location = lineRange.location + lineRange.length;
		searchRange.length = length - searchRange.location;
	}
	return nil;
}


@end




