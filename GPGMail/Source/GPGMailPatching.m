//
//  GPGMailPatching.m
//  GPGMail
//
//  Created by Dave Lopper on Sat Sep 20 2004.
//

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

#import "GPGMailPatching.h"


IMP GPGMail_ReplaceImpOfClassSelectorOfClassWithImpOfClassSelectorOfClass(SEL aSelector, Class aClass, SEL newSelector, Class newClass){
	Method aMethod, newMethod;
	IMP anIMP, newIMP;

	aMethod = class_getClassMethod(aClass, aSelector);
	if (aMethod == NULL) {
		return NULL;
	}
	anIMP = method_getImplementation(aMethod);

	newMethod = class_getClassMethod(newClass, newSelector);
	if (newMethod == NULL) {
		return NULL;
	}
	newIMP = method_getImplementation(newMethod);

	method_setImplementation(aMethod, newIMP);
	NSCAssert(method_getImplementation(aMethod) == newIMP, @"Replacement failed!");

	return anIMP;
}

IMP GPGMail_ReplaceImpOfInstanceSelectorOfClassWithImpOfInstanceSelectorOfClass(SEL aSelector, Class aClass, SEL newSelector, Class newClass){
	Method aMethod, newMethod;
	IMP anIMP, newIMP;

	aMethod = class_getInstanceMethod(aClass, aSelector);
	if (aMethod == NULL) {
		return NULL;
	}
	anIMP = method_getImplementation(aMethod);

	newMethod = class_getInstanceMethod(newClass, newSelector);
	if (newMethod == NULL) {
		return NULL;
	}
	newIMP = method_getImplementation(newMethod);

	method_setImplementation(aMethod, newIMP);
	NSCAssert(method_getImplementation(aMethod) == newIMP, @"Replacement failed!");

	return anIMP;
}

#define NUM_OF_METHODS 2

@implementation GPGMailSwizzler

+ (NSMutableDictionary *)originalMethodsMap {
	if (originalMethodsMap == NULL) {
		originalMethodsMap = [NSMutableDictionary dictionaryWithCapacity:20];
	}
	return [originalMethodsMap retain];
}

+ (IMP)originalMethodForName:(NSString *)aName {
	int idx = [(NSNumber *)[[self originalMethodsMap] objectForKey:aName] intValue];

	return (IMP)originalMethods[idx];
}

+ (void)addMethod:(SEL)aSelector fromClass:(Class)aClass toClass:(Class)bClass {
	IMP anIMP;
	Method aMethod;

	aMethod = class_getInstanceMethod(aClass, aSelector);
	if (aMethod == NULL) {
		return;
	}
	anIMP = method_getImplementation(aMethod);

	if (GPGMailLoggingLevel) {
		NSLog(@"Adding %@ from %@ to %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass), NSStringFromClass(bClass));
	}

	class_addMethod(bClass, aSelector, anIMP, method_getTypeEncoding(aMethod));
}

+ (void)swizzleMethod:(SEL)aSelector fromClass:(Class)aClass withMethod:(SEL)bSelector ofClass:(Class)bClass {
	Method origMethod, newMethod;
	IMP origIMP, newIMP;

	origMethod = class_getInstanceMethod(aClass, aSelector);
	if (origMethod == NULL) {
		return;
	}
	origIMP = method_getImplementation(origMethod);

	newMethod = class_getInstanceMethod(bClass, bSelector);
	if (newMethod == NULL) {
		return;
	}
	newIMP = method_getImplementation(newMethod);

	if (GPGMailLoggingLevel) {
		NSLog(@"Replace %@ from %@ with %@ from %@", NSStringFromSelector(aSelector),
			  NSStringFromClass(aClass),
			  NSStringFromSelector(bSelector),
			  NSStringFromClass(bClass));
	}

	method_setImplementation(origMethod, newIMP);
	if (methodsAllocatedCount == 0) {
		originalMethods = (IMP *)realloc(originalMethods, (methodsAllocatedCount + NUM_OF_METHODS) * sizeof(IMP));
		methodsAllocatedCount = methodsAllocatedCount + NUM_OF_METHODS;
		if (originalMethods == NULL) {
			NSLog(@"Failed to allocate!!!");
		}
	}
	if (originalMethodsIndex + 1 > methodsAllocatedCount) {
		methodsAllocatedCount += methodsAllocatedCount + NUM_OF_METHODS;
		originalMethods = (IMP *)realloc(originalMethods, methodsAllocatedCount * sizeof(IMP));
	}
	NSString *aKey = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), NSStringFromSelector(aSelector)];
	[[self originalMethodsMap] setObject:[NSNumber numberWithInt:originalMethodsIndex] forKey:aKey];
	originalMethods[originalMethodsIndex++] = origIMP;

	NSCAssert(method_getImplementation(origMethod) == newIMP, @"Replacement failed!");
}

+ (void)swizzleClassMethod:(SEL)aSelector fromClass:(Class)aClass withMethod:(SEL)bSelector ofClass:(Class)bClass {
	Method origMethod, newMethod;
	IMP origIMP, newIMP;

	origMethod = class_getClassMethod(aClass, aSelector);
	if (origMethod == NULL) {
		return;
	}
	origIMP = method_getImplementation(origMethod);

	newMethod = class_getClassMethod(bClass, bSelector);
	if (newMethod == NULL) {
		return;
	}
	newIMP = method_getImplementation(newMethod);

	if (GPGMailLoggingLevel) {
		NSLog(@"Replace %@ from %@ with %@ from %@", NSStringFromSelector(aSelector),
			  NSStringFromClass(aClass),
			  NSStringFromSelector(bSelector),
			  NSStringFromClass(bClass));
	}

	method_setImplementation(origMethod, newIMP);
	if (methodsAllocatedCount == 0) {
		originalMethods = (IMP *)realloc(originalMethods, (methodsAllocatedCount + NUM_OF_METHODS) * sizeof(IMP));
		methodsAllocatedCount = methodsAllocatedCount + NUM_OF_METHODS;
		if (originalMethods == NULL) {
			NSLog(@"Failed to allocate!!!");
		}
	}
	if (originalMethodsIndex + 1 > methodsAllocatedCount) {
		methodsAllocatedCount += methodsAllocatedCount + NUM_OF_METHODS;
		originalMethods = (IMP *)realloc(originalMethods, methodsAllocatedCount * sizeof(IMP));
	}
	NSString *aKey = [NSString stringWithFormat:@"%@.%@", NSStringFromClass(aClass), NSStringFromSelector(aSelector)];
	[[self originalMethodsMap] setObject:[NSNumber numberWithInt:originalMethodsIndex] forKey:aKey];
	originalMethods[originalMethodsIndex++] = origIMP;

	NSCAssert(method_getImplementation(origMethod) == newIMP, @"Replacement failed!");
}


+ (void)addMethodsFromClass:(Class)aClass toClass:(Class)bClass {
	unsigned int methodCount;
	unsigned int i;

	if (GPGMailLoggingLevel) {
		NSLog(@"Original method: %@", NSStringFromClass(aClass));
	}
	if (aClass == NULL) {
		if (GPGMailLoggingLevel) {
			NSLog(@"Class can't be null!");
		}
		return;
	}
	Method *classMethods = class_copyMethodList(aClass, &methodCount);

	if (GPGMailLoggingLevel) {
		NSLog(@"Found %d methods", methodCount);
	}
	for (i = 0; i < methodCount; i++) {
		SEL selector = method_getName((Method)classMethods[i]);
		if (GPGMailLoggingLevel) {
			NSLog(@"Adding method %@ to %@", NSStringFromSelector(selector), NSStringFromClass(bClass));
		}
		[GPGMailSwizzler addMethod:selector fromClass:aClass toClass:bClass];
	}
	free(classMethods);
}

+ (void)addIVarsFromClass:(Class)aClass toClass:(Class)bClass {
	unsigned int iVarCount;
	unsigned int i;

	if (aClass == NULL || bClass == NULL) {
		NSLog(@"Class can't be null!");
		return;
	}
	Ivar *classIVars = class_copyIvarList(aClass, &iVarCount);

	NSLog(@"Found %d ivars", iVarCount);
	for (i = 0; i < iVarCount; i++) {
		Ivar current = classIVars[i];
		NSLog(@"Adding iVar %s", ivar_getName(current));
		NSUInteger sizep = 0, alignp = 0;
		NSGetSizeAndAlignment(ivar_getTypeEncoding(current), &sizep, &alignp);
		class_addIvar(bClass, ivar_getName(current), sizep, alignp, ivar_getTypeEncoding(current));
	}

	free(classIVars);

	NSLog(@"Added methods!");

}

+ (void)extendClass:(Class)aClass withClass:(Class)bClass {
	if (GPGMailLoggingLevel) {
		NSLog(@"Extend class %@ with members and methods of class %@", NSStringFromClass(aClass), NSStringFromClass(bClass));
	}

	[self addMethodsFromClass:bClass toClass:aClass];
	[self addIVarsFromClass:bClass toClass:aClass];
}

@end


@implementation NSObject (GPGMailPatching)

- (void)gpgSetClass:(Class)class {
	isa = class;
}

@end

