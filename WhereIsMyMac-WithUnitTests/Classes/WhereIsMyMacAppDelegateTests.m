//
//  WhereIsMyMacAppDelegateTests.m
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
#import "WhereIsMyMacAppDelegate.h"
#import "WhereIsMyMacWindowController.h"
#import <objc/runtime.h>
#import "NSObject+SupersequentImplementation.h"

id mockWindowController = nil;

@implementation WhereIsMyMacWindowController (WhereIsMyMacAppDelegateTests)

- (id)init
{
	if (mockWindowController)
	{
		[self release];
		return mockWindowController;
	}
	
	return invokeSupersequent();
}

@end

@interface WhereIsMyMacAppDelegateTests : SenTestCase 
{
}

@end

@implementation WhereIsMyMacAppDelegateTests

- (void)testAppDelegate
{
	id appDelegate = [[NSApplication sharedApplication] delegate];
	STAssertTrue([appDelegate isKindOfClass:[WhereIsMyMacAppDelegate class]],
		@"Cannot find the application delegate.");
}

- (void)testApplicationDidFinishLaunching
{
	WhereIsMyMacAppDelegate *appDelegate =
		[[[WhereIsMyMacAppDelegate alloc] init] autorelease];

	id mockWindow = [OCMockObject mockForClass:[NSWindow class]];
	[[mockWindow expect] makeKeyAndOrderFront:appDelegate];

	mockWindowController = [OCMockObject mockForClass:[WhereIsMyMacWindowController class]];
	[[[mockWindowController expect] andReturn:mockWindow] window];
	NSUInteger preRetainCount = [mockWindowController retainCount];

	[appDelegate applicationDidFinishLaunching:nil];
	
	[mockWindowController verify];
	[mockWindow verify];
	
	NSUInteger postRetainCount = [mockWindowController retainCount];
	STAssertEquals(postRetainCount, preRetainCount + 1, @"Window controller not retained");

	id windowController;
	object_getInstanceVariable(appDelegate, "windowController", (void **)&windowController);
	STAssertEqualObjects(windowController, mockWindowController,
		@"windowController not set on appDelegate");

	object_setInstanceVariable(appDelegate, "windowController", nil);
	mockWindowController = nil;
}

- (void)testApplicationWillTerminate
{
	WhereIsMyMacAppDelegate *appDelegate =
		[[[WhereIsMyMacAppDelegate alloc] init] autorelease];
	
	id mockWindowController = [OCMockObject mockForClass:[WhereIsMyMacWindowController class]];
	[mockWindowController retain];
	object_setInstanceVariable(appDelegate, "windowController", mockWindowController);
	
	NSUInteger preRetainCount = [mockWindowController retainCount];
	[[mockWindowController expect] close];

	[appDelegate applicationWillTerminate:nil];
	
	[mockWindowController verify];

	NSUInteger postRetainCount = [mockWindowController retainCount];
	STAssertEquals(postRetainCount, preRetainCount - 1, @"Window controller not released");

	id windowController;
	object_getInstanceVariable(appDelegate, "windowController", (void **)&windowController);
	STAssertNil(windowController, @"Window controller property not set to nil");
}

@end
