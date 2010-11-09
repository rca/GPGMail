//
//  GPGDefaultsController.h
//  GPGMail
//
//  Created by Roman Zechmeister on 05.11.10.
//  Copyright 2010 Roman Zechmeister. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GPGDefaults : NSObject {
	NSString *_domain;
	NSMutableDictionary *_defaults;
	NSLock *_defaultsLock;
	NSSet *_defaultDictionarys;
}

@property (retain) NSString *domain;

+ (id)gpgDefaults;
+ (id)standardDefaults;
+ (id)defaultsWithDomain:(NSString *)domain;
- (id)initWithDomain:(NSString *)aDomain;

- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;

- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;

- (NSString *)stringForKey:(NSString *)defaultName;

- (NSArray *)arrayForKey:(NSString *)defaultName;

- (NSDictionary *)dictionaryRepresentation;

- (void)registerDefaults:(NSDictionary *)dictionary;

@end

@interface GPGConfiguration : NSObject {
	NSString *confFile;
}

@property (retain) NSString *confFile;

+ (void)gpgAgentFlush;
+ (id)gpgConf;
+ (id)gpgAgentConf;
- (id)initWithConfFile:(NSString *)path;

- (void)setString:(NSString *)value forKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;

@end

