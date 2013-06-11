#import "GPGMailBundle.h"

@interface GPGMailBundle ()
@property (nonatomic, retain) SUUpdater *updater;
@property GPGErrorCode gpgStatus;
@property (nonatomic, retain) NSDictionary *publicKeyMapping;
@property (nonatomic, retain) NSDictionary *secretKeyMapping;
@property (nonatomic, retain) NSSet *secretGPGKeys;
@property (nonatomic, retain) NSSet *publicGPGKeys;
@property (nonatomic, retain) NSDictionary *publicGPGKeysByID;
@property (nonatomic, retain) NSDictionary *secretGPGKeysByID;

- (void)updateGPGKeys:(NSObject <EnumerationList> *)keys;
- (void)flushGPGKeys;

/**
 Returns all keys which were mapped by the user, email -> fingerprint(s).
 */
- (NSDictionary *)userMappedKeysSecretOnly:(BOOL)secretOnly;

/**
 Returns all groups defined in gpg.conf.
 */
- (NSDictionary *)groups;

/**
 Contains GPGKeys with the E-Mail as key
 */
- (NSDictionary *)publicKeysByEmail;
- (NSDictionary *)secretKeysByEmail;

/**
 Find matching keys by checking all mappings.
 */
- (NSMutableSet *)keysForAddresses:(NSArray *)addresses onlySecret:(BOOL)onlySecret stopOnFound:(BOOL)stop;


- (void)initGPGC;
@end



// Remove registerBundle warning.
@interface NSObject (GPGMail)
- (void)registerBundle;
@end
