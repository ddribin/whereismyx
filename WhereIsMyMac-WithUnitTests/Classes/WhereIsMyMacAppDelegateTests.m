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


@interface WhereIsMyMacAppDelegateTests : SenTestCase 
{
	id _mockWindowController;
	WhereIsMyMacAppDelegate * _appDelegate;
}

@end

@implementation WhereIsMyMacAppDelegateTests

#pragma mark -
#pragma mark Fixture

- (void)setUp
{
	// Setup
	_mockWindowController = [OCMockObject mockForClass:[WhereIsMyMacWindowController class]];
	_appDelegate = [[[WhereIsMyMacAppDelegate alloc] init] autorelease];
	_appDelegate.windowController = _mockWindowController;
}

- (void)tearDown
{
	// Verify
	[_mockWindowController verify];
}

#pragma mark -
#pragma mark Tests

- (void)testAppDelegateIsCorrectClass
{
	// Execute
	id appDelegate = [[NSApplication sharedApplication] delegate];
	
	// Verify
	STAssertTrue([appDelegate isKindOfClass:[WhereIsMyMacAppDelegate class]], nil);
}

- (void)testApplicationDidFinishLaunchingMakesWindowKey
{
	// Setup
	id mockWindow = [OCMockObject mockForClass:[NSWindow class]];
	[[[_mockWindowController stub] andReturn:mockWindow] window];
	[[mockWindow expect] makeKeyAndOrderFront:_appDelegate];
	
	// Execute
	[_appDelegate applicationDidFinishLaunching:nil];
	
	// Verify
	[mockWindow verify];
}

- (void)testApplicationWillTerminateClosesWindow
{
	// Setup
	[[_mockWindowController expect] close];
	
	// Execute
	[_appDelegate applicationWillTerminate:nil];
}

@end
