/*
 * Copyright (c) 2000-2008, Stéphane Corthésy <stephane at sente.ch>
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Stéphane Corthésy nor the names of GPGMail
 *       contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY STÉPHANE CORTHÉSY AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL STÉPHANE CORTHÉSY AND CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Cocoa/Cocoa.h>

/*
 * Implementation note:
 * We cannot use 'self' as key in the extra ivars dictionary, because in -dealloc -gpgExtraIVars might be called when invoking original -dealloc
 * and thus puts 'self' back in mapTable; by using the NSValue and changing the dealloc order,
 * it corrects the problem. 
 */

/*!
 * Declares static variables, proper to given clazz.
 * Declares also +gpgInitExtraIvars, which initializes static ivars, and reimplements -dealloc.
 * +gpgInitExtraIvars must be called in +load.
 * Declares -gpgExtraIVars, which returns a NSMutableDictionary.
 * Declares -gpgDealloc, which is invoked automatically on -dealloc, and removes all extra ivars.
 * Do not put a semi-colon after GPG_DECLARE_EXTRA_IVARS().
 *
 * @param clazz A class name.
 */
#define GPG_DECLARE_EXTRA_IVARS(clazz)             \
static NSMapTable	*clazz##_extraIVars = NULL;    \
static NSLock		*clazz##_extraIVarsLock = nil; \
static IMP          clazz##_dealloc = NULL;        \
\
+ (void) gpgInitExtraIvars \
{ \
    clazz##_extraIVars = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 100, [self zone]); \
    clazz##_extraIVarsLock = [[NSLock alloc] init]; \
    clazz##_dealloc = GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(@selector(dealloc), [clazz class], @selector(gpgDealloc), [clazz class]); \
} \
\
- (NSMutableDictionary *) gpgExtraIVars \
{\
    NSMutableDictionary	*aDict;\
    NSValue             *aValue = [NSValue valueWithNonretainedObject:self];\
    \
    [clazz##_extraIVarsLock lock]; \
    aDict = NSMapGet(clazz##_extraIVars, aValue); \
    if(aDict == nil){ \
        aDict = [NSMutableDictionary dictionaryWithCapacity:3]; \
        NSMapInsert(clazz##_extraIVars, aValue, aDict); \
    } \
    [clazz##_extraIVarsLock unlock]; \
    \
    return aDict;\
}\
\
- (void) gpgDealloc \
{ \
    id	originalSelf = self; \
    \
    ((void (*)(id, SEL))clazz##_dealloc)(self, _cmd); \
    [clazz##_extraIVarsLock lock]; \
    NSMapRemove(clazz##_extraIVars, [NSValue valueWithNonretainedObject:originalSelf]); \
    [clazz##_extraIVarsLock unlock]; \
}

/*!
 * Convenience macro to get extra variable named 'name'.
 *
 * @param name  A string - never nil
 * @result An object, or nil.
 */
#define GPG_GET_EXTRA_IVAR(name)\
    [[self gpgExtraIVars] objectForKey:name]

/*!
 * Convenience macro to set extra variable value.
 *
 * @param value An object, or nil
 * @param name  A string - never nil
 */
#define GPG_SET_EXTRA_IVAR(value, name)\
    { id __value = (value); id  __name = (name); if(__value == nil) [[self gpgExtraIVars] removeObjectForKey:__name]; else [[self gpgExtraIVars] setObject:__value forKey:__name]; }

@interface NSObject(GPGMailExtraIVars)

/*!
 * Initializes static vars, and reimplements -dealloc.
 * +gpgInitExtraIvars must be called in +load.
 */
+ (void) gpgInitExtraIvars;

/*!
 * @result NSMutableDictionary
 */
- (NSMutableDictionary *) gpgExtraIVars;

/*!
 * Invoked automatically on -dealloc; removes all extra ivars.
 */
- (void) gpgDealloc;

@end
