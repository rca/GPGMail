#import <Cocoa/Cocoa.h>

#ifdef LEOPARD

@interface MessageKeychainManager : NSObject
{
}

+ (void)initialize;
+ (unsigned long)_protocolForAccountType:(id)fp8;
+ (long)_setPassword:(id)fp8 forKeychainItem:(struct OpaqueSecKeychainItemRef *)fp12;
+ (id)_passwordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(unsigned long)fp20 itemRef:(struct OpaqueSecKeychainItemRef **)fp24;
+ (id)passwordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(id)fp20;
+ (void)setPassword:(id)fp8 forHost:(id)fp12 username:(id)fp16 port:(int)fp20 protocol:(id)fp24;
+ (void)removePasswordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(id)fp20;
+ (id)_passwordForGenericAccount:(id)fp8 service:(id)fp12 itemRef:(struct OpaqueSecKeychainItemRef **)fp16;
+ (id)passwordForServiceName:(id)fp8 accountName:(id)fp12;
+ (void)setPassword:(id)fp8 forServiceName:(id)fp12 accountName:(id)fp16;
+ (void)removePasswordForServiceName:(id)fp8 accountName:(id)fp12;
+ (void)setSessionTrustedCertificates:(id)fp8 forHost:(id)fp12;
+ (id)sessionTrustedCertificatesForHost:(id)fp8;
+ (struct OpaqueSecCertificateRef *)copyTrustedSigningCertificateForAddress:(id)fp8;
+ (struct OpaqueSecCertificateRef *)copyTrustedEncryptionCertificateForAddress:(id)fp8;
+ (BOOL)canSignMessagesFromAddress:(id)fp8;
+ (BOOL)canEncryptMessagesToAddress:(id)fp8;
+ (BOOL)canEncryptMessagesToAddresses:(id)fp8 sender:(id)fp12;
+ (struct OpaqueSecPolicyRef *)copySSLPolicyForHost:(id)fp8 isClientCertificate:(BOOL)fp12;
+ (struct OpaqueSecPolicyRef *)copySMIMEPolicyForAddress:(id)fp8 usage:(unsigned short)fp12;

@end

#elif defined(TIGER)

@interface MessageKeychainManager : NSObject
{
}

+ (void)initialize;
+ (unsigned long)_protocolForAccountType:(id)fp8;
+ (long)_setPassword:(id)fp8 forKeychainItem:(struct OpaqueSecKeychainItemRef *)fp12;
+ (id)_passwordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(unsigned long)fp20 itemRef:(struct OpaqueSecKeychainItemRef **)fp24;
+ (id)passwordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(id)fp20;
+ (void)setPassword:(id)fp8 forHost:(id)fp12 username:(id)fp16 port:(int)fp20 protocol:(id)fp24;
+ (void)removePasswordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(id)fp20;
+ (id)_passwordForGenericAccount:(id)fp8 service:(id)fp12 itemRef:(struct OpaqueSecKeychainItemRef **)fp16;
+ (id)passwordForServiceName:(id)fp8 accountName:(id)fp12;
+ (void)setPassword:(id)fp8 forServiceName:(id)fp12 accountName:(id)fp16;
+ (void)removePasswordForServiceName:(id)fp8 accountName:(id)fp12;
+ (int)systemTrustForCertificate:(struct OpaqueSecCertificateRef *)fp8 trust:(struct OpaqueSecTrustRef *)fp12 address:(id)fp16 policy:(int)fp20 usage:(int)fp24;
+ (int)userTrustForCertificate:(struct OpaqueSecCertificateRef *)fp8 address:(id)fp12 policy:(int)fp16 usage:(int)fp20;
+ (int)trustForCertificate:(struct OpaqueSecCertificateRef *)fp8 address:(id)fp12 policy:(int)fp16 usage:(int)fp20;
+ (int)trustForTrust:(struct OpaqueSecTrustRef *)fp8 certificate:(struct OpaqueSecCertificateRef *)fp12 policy:(int)fp16;
+ (struct OpaqueSecCertificateRef *)copyTrustedCertificateForAddress:(id)fp8 policy:(int)fp12 usage:(int)fp16;
+ (struct OpaqueSecCertificateRef *)copyTrustedSigningCertificateForAddress:(id)fp8;
+ (BOOL)canSignMessagesFromAddress:(id)fp8;
+ (struct OpaqueSecCertificateRef *)copyTrustedEncryptionCertificateForAddress:(id)fp8;
+ (BOOL)canEncryptMessagesToAddress:(id)fp8;
+ (struct OpaqueSecPolicyRef *)copyPolicy:(int)fp8 address:(id)fp12 usage:(int)fp16;
+ (int)userTrustForCertificate:(const struct OpaqueSecCertificateRef *)fp8 policy:(int)fp12;
+ (void)setUserTrust:(int)fp8 forCertificate:(const struct OpaqueSecCertificateRef *)fp12 policy:(int)fp16;

@end

#else

@interface MessageKeychainManager:NSObject
{
}

+ (void)initialize;
+ (unsigned long)_protocolForAccountType:fp8;
+ (long)_setPassword:fp8 forKeychainItem:(struct OpaqueSecKeychainItemRef *)fp12;
+ _passwordForHost:fp8 username:fp12 port:(int)fp16 protocol:(unsigned long)fp20 itemRef:(struct OpaqueSecKeychainItemRef **)fp24;
+ passwordForHost:fp8 username:fp12 port:(int)fp16 protocol:fp20;
+ (void)setPassword:fp8 forHost:fp12 username:fp16 port:(int)fp20 protocol:fp24;
+ (void)removePasswordForHost:fp8 username:fp12 port:(int)fp16 protocol:fp20;
+ _passwordForGenericAccount:fp8 service:fp12 itemRef:(struct OpaqueSecKeychainItemRef **)fp16;
+ passwordForServiceName:fp8 accountName:fp12;
+ (void)setPassword:fp8 forServiceName:fp12 accountName:fp16;
+ (void)removePasswordForServiceName:fp8 accountName:fp12;
+ (int)systemTrustForCertificate:(struct OpaqueSecCertificateRef *)fp8 trust:(struct OpaqueSecTrustRef *)fp12 address:fp16 policy:(int)fp20 usage:(int)fp24;
+ (int)userTrustForCertificate:(struct OpaqueSecCertificateRef *)fp8 address:fp12 policy:(int)fp16 usage:(int)fp20;
+ (int)trustForCertificate:(struct OpaqueSecCertificateRef *)fp8 address:fp12 policy:(int)fp16 usage:(int)fp20;
+ (int)trustForTrust:(struct OpaqueSecTrustRef *)fp8 certificate:(struct OpaqueSecCertificateRef *)fp12 policy:(int)fp16;
+ (struct OpaqueSecCertificateRef *)copyTrustedCertificateForAddress:fp8 policy:(int)fp12 usage:(int)fp16;
+ (struct OpaqueSecCertificateRef *)copyTrustedSigningCertificateForAddress:fp8;
+ (char)canSignMessagesFromAddress:fp8;
+ (struct OpaqueSecCertificateRef *)copyTrustedEncryptionCertificateForAddress:fp8;
+ (char)canEncryptMessagesToAddress:fp8;
+ (struct OpaqueSecPolicyRef *)copyPolicy:(int)fp8 address:fp12 usage:(int)fp16;
+ (int)userTrustForCertificate:(const struct OpaqueSecCertificateRef *)fp8 policy:(int)fp12;
+ (void)setUserTrust:(int)fp8 forCertificate:(const struct OpaqueSecCertificateRef *)fp12 policy:(int)fp16;

@end

#endif
