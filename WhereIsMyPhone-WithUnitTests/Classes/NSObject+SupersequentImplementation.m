//
//  NSObjectSupersequentImplementation.m
//  SupersequentImplementation
//
//  Created by Matt Gallagher on 9/11/07.
//  Copyright 2007 OnceBuilt. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <Foundation/Foundation.h>
#import "NSObject+SupersequentImplementation.h"
#import <objc/runtime.h>

IMP impOfCallingMethod(id lookupObject, SEL selector)
{
	NSUInteger returnAddress = (NSUInteger)__builtin_return_address(0);
	NSUInteger closest = 0;
	
	//
	// Iterate over the class and all superclasses
	//
	Class currentClass = object_getClass(lookupObject);
	while (currentClass)
	{
		//
		// Iterate over all instance methods for this class
		//
		unsigned int methodCount;
		Method *methodList = class_copyMethodList(currentClass, &methodCount);
		unsigned int i;
		for (i = 0; i < methodCount; i++)
		{
			//
			// Ignore methods with different selectors
			//
			if (method_getName(methodList[i]) != selector)
			{
				continue;
			}
			
			//
			// If this address is closer, use it instead
			//
			NSUInteger address = (NSUInteger)method_getImplementation(methodList[i]);
			if (address < returnAddress && address > closest)
			{
				closest = address;
			}
		}
	
		free(methodList);
		currentClass = class_getSuperclass(currentClass);
	}
	
	return (IMP)closest;
}

@implementation NSObject (SupersequentImplementation)

//
// getInstanceImplementationOf:after:
//
// Looks up the next implementation of the given selector after the
// default one.
//
// Returns nil if no alternate implementation is found.
//
- (IMP)getImplementationOf:(SEL)lookup after:(IMP)skip
{
	BOOL found = NO;
	
	Class currentClass = object_getClass(self);
	while (currentClass)
	{
		//
		// Get the complete list of methods. Fortunately, this list is in priority
		// order (the IMP to avoid should be the first IMP matching the SEL and
		// the next one in the priority list will be next).
		//
		unsigned int methodCount;
		Method *methodList = class_copyMethodList(currentClass, &methodCount);
		
		//
		// Iterate over all methods
		//
		unsigned int i;
		for (i = 0; i < methodCount; i++)
		{
			//
			// Look for the selector
			//
			if (method_getName(methodList[i]) != lookup)
			{
				continue;
			}
			
			IMP implementation = method_getImplementation(methodList[i]);
			
			//
			// Check if this is the "skip" implementation
			//
			if (implementation == skip)
			{
				found = YES;
			}
			else if (found)
			{
				//
				// Return the match.
				//
				free(methodList);
				return implementation;
			}
		}
	
		//
		// No match found. Traverse up through super class' methods.
		//
		free(methodList);

		currentClass = class_getSuperclass(currentClass);
	}
	return nil;
}

@end
