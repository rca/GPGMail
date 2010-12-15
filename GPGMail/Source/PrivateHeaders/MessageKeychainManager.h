#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@interface MessageKeychainManager : NSObject
{
}

+ (void)initialize;
+ (unsigned int)_protocolForAccountType:(id)arg1;
+ (int)_setPassword:(id)arg1 forKeychainItem:(struct OpaqueSecKeychainItemRef *)arg2;
+ (id)_passwordForHost:(id)arg1 username:(id)arg2 port:(unsigned short)arg3 protocol:(unsigned int)arg4 itemRef:(struct OpaqueSecKeychainItemRef **)arg5;
+ (id)passwordForHost:(id)arg1 username:(id)arg2 port:(unsigned short)arg3 protocol:(id)arg4;
+ (void)setPassword:(id)arg1 forHost:(id)arg2 username:(id)arg3 port:(unsigned short)arg4 protocol:(id)arg5;
+ (void)removePasswordForHost:(id)arg1 username:(id)arg2 port:(unsigned short)arg3 protocol:(id)arg4;
+ (id)_passwordForGenericAccount:(id)arg1 service:(id)arg2 itemRef:(struct OpaqueSecKeychainItemRef **)arg3;
+ (id)passwordForServiceName:(id)arg1 accountName:(id)arg2;
+ (void)setPassword:(id)arg1 forServiceName:(id)arg2 accountName:(id)arg3;
+ (void)removePasswordForServiceName:(id)arg1 accountName:(id)arg2;
+ (void)setSessionTrustedCertificates:(id)arg1 forHost:(id)arg2;
+ (id)sessionTrustedCertificatesForHost:(id)arg1;
+ (struct OpaqueSecCertificateRef *)copyTrustedSigningCertificateForAddress:(id)arg1;
+ (struct OpaqueSecCertificateRef *)copyEncryptionCertificateForAddress:(id)arg1;
+ (BOOL)canSignMessagesFromAddress:(id)arg1;
+ (BOOL)canEncryptMessagesToAddress:(id)arg1;
+ (BOOL)canEncryptMessagesToAddresses:(id)arg1 sender:(id)arg2;
+ (struct OpaqueSecPolicyRef *)copySSLPolicyForHost:(id)arg1 isClientCertificate:(BOOL)arg2;
+ (struct OpaqueSecPolicyRef *)copySMIMEPolicyForAddress:(id)arg1 usage:(unsigned short)arg2;

@end

#elif defined(SNOW_LEOPARD)

@interface MessageKeychainManager : NSObject
{
}

+ (void)initialize;
+ (unsigned long)_protocolForAccountType:(id)arg1;
+ (long)_setPassword:(id)arg1 forKeychainItem:(struct OpaqueSecKeychainItemRef *)arg2;
+ (id)_passwordForHost:(id)arg1 username:(id)arg2 port:(unsigned short)arg3 protocol:(unsigned long)arg4 itemRef:(struct OpaqueSecKeychainItemRef **)arg5;
+ (id)passwordForHost:(id)arg1 username:(id)arg2 port:(unsigned short)arg3 protocol:(id)arg4;
+ (void)setPassword:(id)arg1 forHost:(id)arg2 username:(id)arg3 port:(unsigned short)arg4 protocol:(id)arg5;
+ (void)removePasswordForHost:(id)arg1 username:(id)arg2 port:(unsigned short)arg3 protocol:(id)arg4;
+ (id)_passwordForGenericAccount:(id)arg1 service:(id)arg2 itemRef:(struct OpaqueSecKeychainItemRef **)arg3;
+ (id)passwordForServiceName:(id)arg1 accountName:(id)arg2;
+ (void)setPassword:(id)arg1 forServiceName:(id)arg2 accountName:(id)arg3;
+ (void)removePasswordForServiceName:(id)arg1 accountName:(id)arg2;
+ (void)setSessionTrustedCertificates:(id)arg1 forHost:(id)arg2;
+ (id)sessionTrustedCertificatesForHost:(id)arg1;
+ (struct OpaqueSecCertificateRef *)copyTrustedSigningCertificateForAddress:(id)arg1;
+ (struct OpaqueSecCertificateRef *)copyEncryptionCertificateForAddress:(id)arg1;
+ (BOOL)canSignMessagesFromAddress:(id)arg1;
+ (BOOL)canEncryptMessagesToAddress:(id)arg1;
+ (BOOL)canEncryptMessagesToAddresses:(id)arg1 sender:(id)arg2;
+ (struct OpaqueSecPolicyRef *)copySSLPolicyForHost:(id)arg1 isClientCertificate:(BOOL)arg2;
+ (struct OpaqueSecPolicyRef *)copySMIMEPolicyForAddress:(id)arg1 usage:(unsigned short)arg2;

@end


#endif
