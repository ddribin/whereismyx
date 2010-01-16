//
//  WhereIsMyMacWindowControllerTests.m
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
#import <CoreLocation/CoreLocation.h>

#import "WhereIsMyMacAppDelegate.h"
#import "WhereIsMyMacWindowController.h"


@interface WhereIsMyMacWindowControllerTests : SenTestCase 
{
	id _mockLocationManager;
	id _mockLocationFormatter;
	id _mockWorkspace;
	WhereIsMyMacWindowController * _windowController;
}

@end

@implementation WhereIsMyMacWindowControllerTests

#pragma mark -
#pragma mark Fixture

- (void)setUp
{
	// Setup
	_mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	_mockLocationFormatter = [OCMockObject mockForClass:[CoreLocationFormatter class]];
	_mockWorkspace = [OCMockObject mockForClass:[NSWorkspace class]];
	_windowController = [[WhereIsMyMacWindowController alloc]
						 initWithLocationManager:_mockLocationManager
						 locationFormatter:_mockLocationFormatter
						 workspace:_mockWorkspace];
}

- (void)tearDown
{
	// Verify
	[_mockLocationManager verify];
	[_mockLocationFormatter verify];
	[_mockWorkspace verify];
	
	// Teardown
	[_windowController release]; _windowController = nil;
}

#pragma mark -
#pragma mark Tests

- (void)testOutletConnectionsAfterLoadWindow
{
	// Execute
	[_windowController loadWindow];

	// Verify
	STAssertTrue([_windowController isWindowLoaded], nil);
	STAssertNotNil(_windowController.webView, nil);
	STAssertNotNil(_windowController.locationLabel, nil);
	STAssertNotNil(_windowController.accuracyLabel, nil);
	
	NSButton *openInBrowserButton = _windowController.openInBrowserButton;
	STAssertNotNil(openInBrowserButton, nil);
	STAssertEqualObjects(_windowController, [openInBrowserButton target], nil);
	STAssertEquals([openInBrowserButton action],@selector(openInDefaultBrowser:), nil);
}

- (void)testWindowDidLoadStartsLocationManager
{
	// Setup
	[[_mockLocationManager expect] setDelegate:_mockLocationFormatter];
	[[_mockLocationManager expect] startUpdatingLocation];

	// Execute
	[_windowController windowDidLoad];
}

- (void)testOpenInDefaultBrowserActionOpensGoogleMapsUrlInWorkspace
{
	// Setup
	[[[_mockLocationManager stub] andReturn:nil] location];
	NSURL * dummyUrl = [NSURL URLWithString:@"http://example.com/"];
	[[[_mockLocationFormatter stub] andReturn:dummyUrl] googleMapsUrlForLocation:nil];
	[[_mockWorkspace expect] openURL:dummyUrl];
	
	// Execute
	[_windowController openInDefaultBrowser:nil];
}

- (void)testCloseStopsLocationManager
{
	// Setup
	[[_mockLocationManager expect] stopUpdatingLocation];

	// Execute
	[_windowController close];
}

@end
