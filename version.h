#define MAJOR_VERSION 2
#define MINOR_VERSION 0
/*#define MAINTENANCE_VERSION 0		*/
#define PRERELEASE_VERSION a31		/**/
#define SPARKLE_URL "http://www.gpgtools.org/gpgmail/appcast.xml"


/* DON'T CHANGE ANYTHING BELOW THIS LINE! */

#define INCREMENTAL_BUILD_NUMBER 201


#if defined(MAINTENANCE_VERSION) && defined(PRERELEASE_VERSION)
#define TEMP_VERSION_JOIN(a,b,c,d) a ## . ## b ## . ## c ## d
#elif defined(MAINTENANCE_VERSION)
#define TEMP_VERSION_JOIN(a,b,c,d) a ## . ## b ## . ## c
#elif defined(PRERELEASE_VERSION)
#define TEMP_VERSION_JOIN(a,b,c,d) a ## . ## b ## d
#else
#define TEMP_VERSION_JOIN(a,b,c,d) a ## . ## b
#endif

#define TEMP_VERSION_JOIN2(a,b,c,d) TEMP_VERSION_JOIN(a,b,c,d)
#define BUNDLE_VERSION TEMP_VERSION_JOIN2(MAJOR_VERSION,MINOR_VERSION,MAINTENANCE_VERSION,PRERELEASE_VERSION)


#ifdef PRERELEASE_VERSION
#define BUILD_NUMBER INCREMENTAL_BUILD_NUMBER (PRERELEASE_VERSION)
#else
#define BUILD_NUMBER INCREMENTAL_BUILD_NUMBER
#endif
