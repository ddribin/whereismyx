//
//  WhereIsMyPhoneAppDelegateTests.m
//  WhereIsMyMac
//
//  Created by Matt Gallagher on 2009/12/19.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "WhereIsMyPhoneAppDelegate.h"
#import "WhereIsMyPhoneViewController.h"
#import <objc/runtime.h>
#import "NSObject+SupersequentImplementation.h"

id mockViewController = nil;

@implementation WhereIsMyPhoneViewController (WhereIsMyPhoneAppDelegateTests)

- (id)init
{
	if (mockViewController)
	{
		[self release];
		return mockViewController;
	}
	
	return invokeSupersequentNoArgs();
}

@end

@interface WhereIsMyPhoneAppDelegateTests : SenTestCase 
{
}

@end

@implementation WhereIsMyPhoneAppDelegateTests

#ifdef APPLICATION_TESTS

- (void)testAppDelegate
{
   id appDelegate = [[UIApplication sharedApplication] delegate];
   STAssertNotNil(appDelegate, @"Cannot find the application delegate.");
}

#endif

- (void)testApplicationDidFinishLaunching
{
	WhereIsMyPhoneAppDelegate *appDelegate =
		[[[WhereIsMyPhoneAppDelegate alloc] init] autorelease];

	id mockView = [OCMockObject mockForClass:[UIView class]];
	[[mockView expect] setFrame:CGRectMake(0, 20, 320, 460)];

	mockViewController = [OCMockObject mockForClass:[WhereIsMyPhoneViewController class]];
	[[[mockViewController stub] andReturn:mockView] view];

	id mockWindow = [OCMockObject mockForClass:[UIWindow class]];
	[[mockWindow expect] addSubview:mockView];
	[[mockWindow expect] makeKeyAndVisible];
	object_setInstanceVariable(appDelegate, "window", mockWindow);
	
	[appDelegate applicationDidFinishLaunching:nil];
	
	[mockViewController verify];
	[mockView verify];
	
	id viewController;
	object_getInstanceVariable(appDelegate, "viewController", (void **)&viewController);
	STAssertEqualObjects(viewController, mockViewController,
		@"viewController not set on appDelegate");

	mockViewController = nil;	
}

- (void)testApplicationWillTerminate
{
	WhereIsMyPhoneAppDelegate *appDelegate =
		[[[WhereIsMyPhoneAppDelegate alloc] init] autorelease];
	
	id mockViewController = [OCMockObject mockForClass:[WhereIsMyPhoneAppDelegate class]];
	NSUInteger preRetainCount = [mockViewController retainCount];
	[mockViewController retain];
	object_setInstanceVariable(appDelegate, "viewController", mockViewController);
	
	[appDelegate applicationWillTerminate:nil];

	NSUInteger postRetainCount = [mockViewController retainCount];
	STAssertEquals(postRetainCount, preRetainCount, @"Window controller not released");

	id viewController;
	object_getInstanceVariable(appDelegate, "viewController", (void **)&viewController);
	STAssertNil(viewController, @"Window controller property not set to nil");
}

@end
