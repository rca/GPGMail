/* NSString+Message.h created by dave on Sun 09-Jan-2000 */

#import <Cocoa/Cocoa.h>

#ifdef SNOW_LEOPARD_64

@interface NSString (EmailAddressString)
+ (id)nameExtensions;
+ (id)nameExtensionsThatDoNotNeedCommas;
+ (id)partialSurnames;
+ (id)formattedAddressWithName:(id)arg1 email:(id)arg2 useQuotes:(BOOL)arg3;
- (id)uncommentedAddress;
- (id)uncommentedAddressRespectingGroups;
- (BOOL)isEmptyGroup;
- (id)addressComment;
- (void)firstName:(id *)arg1 middleName:(id *)arg2 lastName:(id *)arg3 extension:(id *)arg4;
- (BOOL)appearsToBeAnInitial;
- (id)addressList;
- (id)trimCommasSpacesQuotes;
- (id)componentsSeparatedByCommaRespectingQuotesAndParens;
- (id)componentsSeparatedByCharactersRespectingQuotesAndParens:(id)arg1;
- (id)searchStringComponents;
- (BOOL)isLegalEmailAddress;
- (id)addressDomain;
@end

@interface NSString (FormatFlowedSupport)
- (id)convertFromFlowedText:(unsigned long long)arg1;
@end

@interface NSString (IMAPNameEncoding)
- (id)encodedIMAPMailboxName;
- (id)decodedIMAPMailboxName;
@end

@interface NSString (LibraryID)
+ (id)stringWithLibraryID:(long long)arg1;
- (id)initWithLibraryID:(long long)arg1;
@end

@interface NSString (MimeCharsetSupport)
- (id)bestMimeCharset;
- (id)_bestMimeCharset:(id)arg1;
- (id)bestMimeCharsetUsingHint:(unsigned int)arg1;
@end

@interface NSString (MimeEnrichedReader)
+ (id)htmlStringFromMimeRichTextString:(id)arg1;
+ (id)htmlStringFromMimeEnrichedString:(id)arg1;
+ (id)stringFromMimeEnrichedString:(id)arg1;
@end

@interface NSString (MimeHeaderEncoding)
- (id)encodedHeaderData;
- (id)encodedHeaderDataWithEncodingHint:(unsigned int)arg1;
- (id)encodedHeaderDataWithEncodingHint:(unsigned int)arg1 encodingUsed:(unsigned int *)arg2;
- (id)decodeMimeHeaderValue;
- (id)decodeMimeHeaderValueWithCharsetHint:(id)arg1;
@end

@interface NSString (NSStringUtils)
+ (id)messageIDStringWithDomainHint:(id)arg1;
+ (id)messageIDStringFromCidUrl:(id)arg1;
+ (id)stringWithData:(id)arg1 encoding:(unsigned long long)arg2;
+ (id)stringWithAttachmentCharacter;
+ (id)createUniqueIdString;
- (unsigned int)hexIntValue;
- (unsigned long long)hexLongLongValue;
- (id)smartCapitalizedString;
- (id)stringByReplacingString:(id)arg1 withString:(id)arg2;
- (id)stringByRemovingCharactersInSet:(id)arg1;
- (id)stringByApplyingBodyClassName:(id)arg1;
- (id)createStringByApplyingBodyClassName:(id)arg1;
- (id)stringByChangingBodyTagToDiv;
- (id)stringByRemovingLineEndingsForHTML;
- (id)stringByReplacingNonBreakingSpacesWithString:(id)arg1;
- (id)specialSlash;
- (id)stringByReplacingSlashesWithSpecialSlashes;
- (id)stringByReplacingSpecialSlashesWithSlashes;
- (id)stringByReplacingSpecialSlashesWith:(id)arg1;
- (BOOL)containsOnlyWhitespace;
- (BOOL)containsOnlyBreakingWhitespace;
- (id)stringByLocalizingReOrFwdPrefix;
- (unsigned long long)effectivePrefixLength;
- (id)fileSystemString;
- (id)stringWithNormalizedUnicodeCompositionForMail;
- (id)stringSuitableForHTML;
- (id)stringWithNoExtraSpaces;
- (long long)compareAsInts:(id)arg1;
- (id)MD5Digest;
- (id)messageIDSubstring;
- (id)encodedMessageID;
- (id)encodedMessageIDString;
- (id)createStringByEndTruncatingForWidth:(double)arg1 usingFont:(id)arg2;
- (id)uniqueFilenameWithRespectToFilenames:(id)arg1;
- (long long)caseInsensitiveCompareExcludingXDash:(id)arg1;
- (id)componentsSeparatedByPattern:(id)arg1;
- (id)spotlightQueryStringWithQualifier:(int)arg1;
- (BOOL)isValidUniqueIdString;
- (id)feedURLString;
- (id)firstLine;
- (id)secondToLastPathComponent;
- (BOOL)hasPrefixIgnoreCaseAndDiacritics:(id)arg1;
- (BOOL)isEqualToStringIgnoreCaseAndDiacritics:(id)arg1;
- (BOOL)isEqualToStringIgnoringCase:(id)arg1;
- (id)validURL;
- (BOOL)isEqualExceptForFinalSlash:(id)arg1;
@end

@interface NSString (PathUtils)
+ (id)pathWithDirectory:(id)arg1 filename:(id)arg2 extension:(id)arg3;
- (id)uniquePathWithMaximumLength:(unsigned long long)arg1;
- (BOOL)deletePath;
- (BOOL)isSubdirectoryOfPath:(id)arg1;
- (id)stringByReallyAbbreviatingWithTildeInPath;
- (id)betterStringByResolvingSymlinksInPath;
@end

@interface NSString (StationeryUtilities)
- (id)urlStringByIncrementingCompositeVersionNumber;
- (id)urlStringByInsertingCompositeVersionNumber;
@end

@interface NSString (iCalInvitationSupport)
- (BOOL)isICalInvitation;
@end

#elif defined(SNOW_LEOPARD)

@interface NSString (EmailAddressString)
+ (id)nameExtensions;
+ (id)nameExtensionsThatDoNotNeedCommas;
+ (id)partialSurnames;
+ (id)formattedAddressWithName:(id)arg1 email:(id)arg2 useQuotes:(BOOL)arg3;
- (id)uncommentedAddress;
- (id)uncommentedAddressRespectingGroups;
- (BOOL)isEmptyGroup;
- (id)addressComment;
- (void)firstName:(id *)arg1 middleName:(id *)arg2 lastName:(id *)arg3 extension:(id *)arg4;
- (BOOL)appearsToBeAnInitial;
- (id)addressList;
- (id)trimCommasSpacesQuotes;
- (id)componentsSeparatedByCommaRespectingQuotesAndParens;
- (id)componentsSeparatedByCharactersRespectingQuotesAndParens:(id)arg1;
- (id)searchStringComponents;
- (BOOL)isLegalEmailAddress;
- (id)addressDomain;
@end

@interface NSString (FormatFlowedSupport)
- (id)convertFromFlowedText:(unsigned int)arg1;
@end

@interface NSString (iCalInvitationSupport)
- (BOOL)isICalInvitation;
@end

@interface NSString (IMAPNameEncoding)
- (id)encodedIMAPMailboxName;
- (id)decodedIMAPMailboxName;
@end

@interface NSString (LibraryID)
+ (id)stringWithLibraryID:(long long)arg1;
- (id)initWithLibraryID:(long long)arg1;
@end

@interface NSString (MimeCharsetSupport)
- (id)bestMimeCharset;
- (id)_bestMimeCharset:(id)arg1;
- (id)bestMimeCharsetUsingHint:(unsigned long)arg1;
@end

@interface NSString (MimeEnrichedReader)
+ (id)htmlStringFromMimeRichTextString:(id)arg1;
+ (id)htmlStringFromMimeEnrichedString:(id)arg1;
+ (id)stringFromMimeEnrichedString:(id)arg1;
@end

@interface NSString (MimeHeaderEncoding)
- (id)encodedHeaderData;
- (id)encodedHeaderDataWithEncodingHint:(unsigned long)arg1;
- (id)encodedHeaderDataWithEncodingHint:(unsigned long)arg1 encodingUsed:(unsigned int *)arg2;
- (id)decodeMimeHeaderValue;
- (id)decodeMimeHeaderValueWithCharsetHint:(id)arg1;
@end

@interface NSString (StationeryUtilities)
- (id)urlStringByIncrementingCompositeVersionNumber;
- (id)urlStringByInsertingCompositeVersionNumber;
@end

@interface NSString (NSStringUtils)
+ (id)messageIDStringWithDomainHint:(id)arg1;
+ (id)messageIDStringFromCidUrl:(id)arg1;
+ (id)stringWithData:(id)arg1 encoding:(unsigned int)arg2;
+ (id)stringWithAttachmentCharacter;
+ (id)createUniqueIdString;
- (unsigned int)hexIntValue;
- (unsigned long long)hexLongLongValue;
- (id)smartCapitalizedString;
- (id)stringByReplacingString:(id)arg1 withString:(id)arg2;
- (id)stringByRemovingCharactersInSet:(id)arg1;
- (id)stringByApplyingBodyClassName:(id)arg1;
- (id)createStringByApplyingBodyClassName:(id)arg1;
- (id)stringByChangingBodyTagToDiv;
- (id)stringByRemovingLineEndingsForHTML;
- (id)stringByReplacingNonBreakingSpacesWithString:(id)arg1;
- (id)specialSlash;
- (id)stringByReplacingSlashesWithSpecialSlashes;
- (id)stringByReplacingSpecialSlashesWithSlashes;
- (id)stringByReplacingSpecialSlashesWith:(id)arg1;
- (BOOL)containsOnlyWhitespace;
- (BOOL)containsOnlyBreakingWhitespace;
- (id)stringByLocalizingReOrFwdPrefix;
- (unsigned int)effectivePrefixLength;
- (id)fileSystemString;
- (id)stringWithNormalizedUnicodeCompositionForMail;
- (id)stringSuitableForHTML;
- (id)stringWithNoExtraSpaces;
- (int)compareAsInts:(id)arg1;
- (id)MD5Digest;
- (id)messageIDSubstring;
- (id)encodedMessageID;
- (id)encodedMessageIDString;
- (id)createStringByEndTruncatingForWidth:(float)arg1 usingFont:(id)arg2;
- (id)uniqueFilenameWithRespectToFilenames:(id)arg1;
- (int)caseInsensitiveCompareExcludingXDash:(id)arg1;
- (id)componentsSeparatedByPattern:(id)arg1;
- (id)spotlightQueryStringWithQualifier:(int)arg1;
- (BOOL)isValidUniqueIdString;
- (id)feedURLString;
- (id)firstLine;
- (id)secondToLastPathComponent;
- (BOOL)hasPrefixIgnoreCaseAndDiacritics:(id)arg1;
- (BOOL)isEqualToStringIgnoreCaseAndDiacritics:(id)arg1;
- (BOOL)isEqualToStringIgnoringCase:(id)arg1;
- (id)validURL;
- (BOOL)isEqualExceptForFinalSlash:(id)arg1;
@end

@interface NSString (PathUtils)
+ (id)pathWithDirectory:(id)arg1 filename:(id)arg2 extension:(id)arg3;
- (id)uniquePathWithMaximumLength:(unsigned int)arg1;
- (BOOL)deletePath;
- (BOOL)isSubdirectoryOfPath:(id)arg1;
- (id)stringByReallyAbbreviatingWithTildeInPath;
- (id)betterStringByResolvingSymlinksInPath;
@end

@interface NSString (AtomicAddress)
- (id)atomicAddress;
- (id)atomicAddressStringForRepresentedRecord:(id)arg1 type:(int)arg2;
- (id)atomicAddressStringForRepresentedRecord:(id)arg1 type:(int)arg2 showComma:(BOOL)arg3;
- (id)atomicAddressArrayForRepresentedRecord:(id)arg1 type:(int)arg2;
- (id)atomicAddressWithRepresentedRecord:(id)arg1 type:(int)arg2;
- (id)atomicAddressWithRepresentedRecord:(id)arg1 type:(int)arg2 showComma:(BOOL)arg3;
@end

@interface NSString (FindPanelSupport)
- (struct _NSRange)findString:(id)arg1 selectedRange:(struct _NSRange)arg2 options:(unsigned long)arg3 wrap:(BOOL)arg4;
@end

@interface NSString (MailAdditions)
- (void)_drawInRect:(struct CGRect)arg1 font:(id)arg2 color:(id)arg3 truncate:(BOOL)arg4;
- (void)drawEtchedInRect:(struct CGRect)arg1 withTopColor:(id)arg2 bottomColor:(id)arg3 shadowBelow:(BOOL)arg4 font:(id)arg5 centered:(BOOL)arg6 flipped:(BOOL)arg7 truncate:(BOOL)arg8;
- (BOOL)doesMatchLocalizedDateName:(id)arg1;
- (BOOL)matchesLocalizedDateIntervalFrom:(id *)arg1 to:(id *)arg2;
@end

@interface NSString (HTMLConversion)
- (id)markupString;
- (id)webArchiveForRange:(struct _NSRange)arg1;
- (id)webArchiveForRange:(struct _NSRange)arg1 signatureID:(id *)arg2;
@end

@interface NSString (ToDoAdditions)
+ (id)nodeIDForTodoID:(id)arg1 nodeClass:(id)arg2;
- (id)todoIDFromNodeID:(id)arg1;
@end

#elif defined(LEOPARD)

@interface NSString (IMAPNameEncoding)
- (id)encodedIMAPMailboxName;
- (id)decodedIMAPMailboxName;
@end

@interface NSString (MimeEnrichedReader)
+ (id)htmlStringFromMimeRichTextString:(id)fp8;
+ (id)htmlStringFromMimeEnrichedString:(id)fp8;
+ (id)stringFromMimeEnrichedString:(id)fp8;
@end

@interface NSString (MimeHeaderEncoding)
- (id)encodedHeaderData;
- (id)encodedHeaderDataWithEncodingHint:(unsigned long)fp8;
- (id)decodeMimeHeaderValue;
- (id)decodeMimeHeaderValueWithCharsetHint:(id)fp8;
@end

@interface NSString (FormatFlowedSupport)
- (id)convertFromFlowedText:(unsigned int)fp8;
@end

@interface NSString (EmailAddressString)
+ (id)nameExtensions;
+ (id)nameExtensionsThatDoNotNeedCommas;
+ (id)partialSurnames;
+ (id)formattedAddressWithName:(id)fp8 email:(id)fp12 useQuotes:(BOOL)fp16;
- (id)uncommentedAddress;
- (id)uncommentedAddressRespectingGroups;
- (BOOL)isEmptyGroup;
- (id)addressComment;
- (void)firstName:(id *)fp8 middleName:(id *)fp12 lastName:(id *)fp16 extension:(id *)fp20;
- (BOOL)appearsToBeAnInitial;
- (id)addressList;
- (id)trimCommasSpacesQuotes;
- (id)componentsSeparatedByCommaRespectingQuotesAndParens;
- (id)componentsSeparatedByCharactersRespectingQuotesAndParens:(id)fp8;
- (id)searchStringComponents;
- (BOOL)isLegalEmailAddress;
- (id)addressDomain;
@end

@interface NSString (StationeryUtilities)
- (id)urlStringByIncrementingCompositeVersionNumber;
- (id)urlStringByInsertingCompositeVersionNumber;
@end

@interface NSString (NSStringUtils)
+ (id)messageIDStringWithDomainHint:(id)fp8;
+ (id)messageIDStringFromCidUrl:(id)fp8;
+ (id)stringWithData:(id)fp8 encoding:(unsigned int)fp12;
+ (id)stringRepresentationForBytes:(long long)fp8;
+ (id)stringWithAttachmentCharacter;
+ (id)createUniqueIdString;
- (unsigned int)hexIntValue;
- (id)smartCapitalizedString;
- (id)stringByReplacingString:(id)fp8 withString:(id)fp12;
- (id)stringByRemovingCharactersInSet:(id)fp8;
- (id)stringByApplyingBodyClassName:(id)fp8;
- (id)createStringByApplyingBodyClassName:(id)fp8;
- (id)stringByChangingBodyTagToDiv;
- (id)stringByRemovingLineEndingsForHTML;
- (id)stringByReplacingNonBreakingSpacesWithString:(id)fp8;
- (BOOL)containsOnlyWhitespace;
- (BOOL)containsOnlyBreakingWhitespace;
- (id)stringByLocalizingReOrFwdPrefix;
- (unsigned int)subjectPrefixLength;
- (id)fileSystemString;
- (id)stringSuitableForHTML;
- (id)stringWithNoExtraSpaces;
- (int)compareAsInts:(id)fp8;
- (id)MD5Digest;
- (id)messageIDSubstring;
- (id)encodedMessageID;
- (id)encodedMessageIDString;
- (id)createStringByEndTruncatingForWidth:(float)fp8 usingFont:(id)fp12;
- (id)uniqueFilenameWithRespectToFilenames:(id)fp8;
- (int)caseInsensitiveCompareExcludingXDash:(id)fp8;
- (id)componentsSeparatedByPattern:(id)fp8;
- (id)spotlightQueryString;
- (BOOL)isValidUniqueIdString;
- (id)feedURLString;
- (id)firstLine;
- (id)secondToLastPathComponent;
- (const char *)functioningLossyCString;
- (BOOL)hasPrefixIgnoreCaseAndDiacritics:(id)fp8;
- (BOOL)isEqualToStringIgnoreCaseAndDiacritics:(id)fp8;
@end

@interface NSString (PathUtils)
+ (id)pathWithDirectory:(id)fp8 filename:(id)fp12 extension:(id)fp16;
- (id)uniquePathWithMaximumLength:(int)fp8;
- (BOOL)deletePath;
- (BOOL)makeDirectoryWithMode:(int)fp8;
- (BOOL)makePathWritable:(int *)fp8;
- (BOOL)makePathReadOnly:(int *)fp8;
- (BOOL)makePathReadOnly:(int *)fp8 recursively:(BOOL)fp12;
- (void)setPosixFilePermissions:(int)fp8;
- (BOOL)isSubdirectoryOfPath:(id)fp8;
- (id)stringByReallyAbbreviatingWithTildeInPath;
- (id)betterStringByResolvingSymlinksInPath;
@end

@interface NSString (MimeCharsetSupport)
- (id)bestMimeCharset;
- (id)_bestMimeCharset:(id)fp8;
- (id)bestMimeCharsetUsingHint:(unsigned long)fp8;
@end

@interface NSString (iCalInvitationSupport)
- (BOOL)isICalInvitation;
@end

#elif defined(TIGER)

@interface NSString (IMAPNameEncoding)
- (id)encodedIMAPMailboxName;
- (id)decodedIMAPMailboxName;
@end

@interface NSString (MimeEnrichedReader)
+ (id)stringFromMimeEnrichedString:(id)fp8;
@end

@interface NSString (MimeHeaderEncoding)
- (id)encodedHeaderData;
- (id)encodedHeaderDataWithEncodingHint:(unsigned long)fp8;
- (id)decodeMimeHeaderValue;
- (id)decodeMimeHeaderValueWithCharsetHint:(id)fp8;
@end

@interface NSString (FormatFlowedSupport)
- (id)convertFromFlowedText:(unsigned int)fp8;
@end

@interface NSString (NSEmailAddressString)
+ (id)nameExtensions;
+ (id)nameExtensionsThatDoNotNeedCommas;
+ (id)partialSurnames;
+ (id)formattedAddressWithName:(id)fp8 email:(id)fp12 useQuotes:(BOOL)fp16;
- (id)uncommentedAddress;
- (id)uncommentedAddressRespectingGroups;
- (id)addressComment;
- (void)firstName:(id *)fp8 middleName:(id *)fp12 lastName:(id *)fp16 extension:(id *)fp20;
- (BOOL)appearsToBeAnInitial;
- (id)addressList;
- (id)trimCommasSpacesQuotes;
- (id)componentsSeparatedByCommaRespectingQuotesAndParens;
- (id)searchStringComponents;
- (BOOL)isLegalEmailAddress;
- (id)addressDomain;
@end

@interface NSString (NSStringUtils)
+ (id)messageIDStringWithDomainHint:(id)fp8;
+ (id)stringWithData:(id)fp8 encoding:(unsigned int)fp12;
+ (id)stringRepresentationForBytes:(long long)fp8;
+ (id)stringWithAttachmentCharacter;
- (BOOL)boolValue;
- (id)smartCapitalizedString;
- (id)stringByReplacingString:(id)fp8 withString:(id)fp12;
- (id)stringByRemovingCharactersInSet:(id)fp8;
- (id)stringByRemovingLineEndingsForHTML;
- (BOOL)containsOnlyWhitespace;
- (BOOL)containsOnlyBreakingWhitespace;
- (id)stringByLocalizingReOrFwdPrefix;
- (unsigned int)subjectPrefixLength;
- (id)fileSystemString;
- (id)stringWithNoExtraSpaces;
- (int)compareAsInts:(id)fp8;
- (id)MD5Digest;
- (id)messageIDSubstring;
- (id)encodedMessageID;
- (id)createStringByEndTruncatingForWidth:(float)fp8 usingFont:(id)fp12;
- (id)uniqueFilenameWithRespectToFilenames:(id)fp8;
- (int)caseInsensitiveCompareExcludingXDash:(id)fp8;
- (id)componentsSeparatedByPattern:(id)fp8;
@end

@interface NSString (PathUtils)
+ (id)pathWithDirectory:(id)fp8 filename:(id)fp12 extension:(id)fp16;
- (id)uniquePathWithMaximumLength:(int)fp8;
- (BOOL)deletePath;
- (BOOL)makeDirectoryWithMode:(int)fp8;
- (BOOL)makePathWritable:(int *)fp8;
- (BOOL)makePathReadOnly:(int *)fp8;
- (BOOL)makePathReadOnly:(int *)fp8 recursively:(BOOL)fp12;
- (void)setPosixFilePermissions:(int)fp8;
- (BOOL)isSubdirectoryOfPath:(id)fp8;
- (id)stringByReallyAbbreviatingWithTildeInPath;
- (id)betterStringByResolvingSymlinksInPath;
@end

@interface NSString (MimeCharsetSupport)
- (id)bestMimeCharset;
@end

@interface NSString (LibraryMessageIDSupport)
- (id)encodedMessageIDString;
@end

@interface NSString (iCalInvitationSupport)
- (BOOL)isICalInvitation;
@end

#else

@interface NSString(IMAPNameEncoding)
- encodedIMAPMailboxName;
- decodedIMAPMailboxName;
@end

@interface NSString(shell_escape)
- _fixStringForShell;
@end

@interface NSString(MimeEnrichedReader)
+ stringFromMimeEnrichedString:fp8;
@end

@interface NSString(MimeHeaderEncoding)
- encodedHeaderData;
- decodeMimeHeaderValue;
- decodeMimeHeaderValueWithCharsetHint:fp8;
@end

@interface NSString(FormatFlowedSupport)
- convertFromFlowedText:(unsigned int)fp8;
@end

@interface NSString(NSEmailAddressString)
+ nameExtensions;
+ nameExtensionsThatDoNotNeedCommas;
+ partialSurnames;
+ formattedAddressWithName:fp8 email:fp12 useQuotes:(char)fp16;
- uncommentedAddress;
- uncommentedAddressRespectingGroups;
- addressComment;
- (void)firstName:(id *)fp8 middleName:(id *)fp12 lastName:(id *)fp16 extension:(id *)fp20;
- (char)appearsToBeAnInitial;
- fullName;
- addressList;
- trimCommasSpacesQuotes;
- componentsSeparatedByCommaRespectingQuotesAndParens;
- searchStringComponents;
- (char)isLegalEmailAddress;
- addressDomain;
@end

@interface NSString(next_reference)
- _nextReferenceName;
@end

@interface NSString(NSStringUtils)
+ stringWithData:fp8 encoding:(unsigned int)fp12;
+ stringRepresentationForBytes:(long long)fp8;
+ stringWithAttachmentCharacter;
- (BOOL)boolValue;
- smartCapitalizedString;
- stringByReplacingString:fp8 withString:fp12;
- stringByLocalizingReOrFwdPrefix;
- (unsigned int)subjectPrefixLength;
- fileSystemString;
- stringWithNoExtraSpaces;
- (int)compareAsInts:fp8;
- MD5Digest;
- messageIDSubstring;
- createStringByEndTruncatingForWidth:(float)fp8 usingFont:fp12;
- uniqueFilenameWithRespectToFilenames:fp8;
- (int)caseInsensitiveCompareExcludingXDash:fp8;
@end

@interface NSString(PathUtils)
+ pathWithDirectory:fp8 filename:fp12 extension:fp16;
- uniquePathWithMaximumLength:(int)fp8;
- (char)deletePath;
- (char)makeDirectoryWithMode:(int)fp8;
- (char)makePathWritable:(int *)fp8;
- (char)makePathReadOnly:(int *)fp8;
- (void)setPosixFilePermissions:(int)fp8;
- (char)isSubdirectoryOfPath:fp8;
- stringByReallyAbbreviatingWithTildeInPath;
- betterStringByResolvingSymlinksInPath;
@end

@interface NSString(MimeCharsetSupport)
- bestMimeCharset;
@end

@interface NSString(AtomicAddress)
- atomicAddress;
- atomicAddressStringForRepresentedRecord:fp8 type:(int)fp12;
- atomicAddressStringForRepresentedRecord:fp8 type:(int)fp12 showComma:(char)fp16;
- atomicAddressArrayForRepresentedRecord:fp8 type:(int)fp12;
- atomicAddressWithRepresentedRecord:fp8 type:(int)fp12;
- atomicAddressWithRepresentedRecord:fp8 type:(int)fp12 showComma:(char)fp16;
@end

@interface NSString(FindPanelSupport)
- (struct _NSRange)findString:fp8 selectedRange:(struct _NSRange)fp12 options:(unsigned int)fp20 wrap:(char)fp24;
@end

@interface NSMutableString(convenience)
- (void)replaceString:fp8 withString:fp12;
@end

#endif
