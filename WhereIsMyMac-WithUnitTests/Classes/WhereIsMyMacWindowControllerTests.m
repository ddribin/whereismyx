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
#import "WhereIsMyMacAppDelegate.h"
#import "WhereIsMyMacWindowController.h"
#import <objc/runtime.h>
#import <CoreLocation/CoreLocation.h>
#import "NSObject+SupersequentImplementation.h"


@interface WhereIsMyMacWindowControllerTests : SenTestCase 
{
	id _mockLocationManager;
	id _mockLocationFormatter;
	WhereIsMyMacWindowController * _windowController;
}

@end

@implementation WhereIsMyMacWindowControllerTests

- (void)setUp
{
	// Setup
	_mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	_mockLocationFormatter = [OCMockObject mockForClass:[CoreLocationFormatter class]];
	_windowController = [[WhereIsMyMacWindowController alloc]
						 initWithLocationManager:_mockLocationManager
						 locationFormatter:_mockLocationFormatter];
}

- (void)tearDown
{
	// Verify
	[_mockLocationManager verify];
	[_mockLocationFormatter verify];
	
	// Teardown
	[_windowController close];
	[_windowController release];
}

- (void)testLoadWindow
{
	// Setup
	[[_mockLocationManager stub] stopUpdatingLocation];

	// Execute
	[_windowController loadWindow];

	WebView *webView = _windowController.webView;
	NSTextField *locationLabel = _windowController.locationLabel;
	NSTextField *accuracyLabel = _windowController.accuracyLabel;
	NSButton *openInBrowserButton = _windowController.openInBrowserButton;
	
	STAssertTrue([_windowController isWindowLoaded], @"Window failed to load");
	STAssertNotNil(webView, @"webView ivar not set on load");
	STAssertNotNil(locationLabel, @"locationLabel ivar not set on load");
	STAssertNotNil(accuracyLabel, @"accuracyLabel ivar not set on load");
	STAssertNotNil(openInBrowserButton, @"openInBrowserButton ivar not set on load");
	STAssertEqualObjects(_windowController, [openInBrowserButton target],
		@"openInBrowserButton button doesn't target window controller");
	STAssertTrue([openInBrowserButton action] == @selector(openInDefaultBrowser:),
		@"openInBrowserButton button doesn't invoke openInDefaultBrowser:");
}

- (void)testWindowDidLoad
{
	// Setup
	[[_mockLocationManager expect] setDelegate:_mockLocationFormatter];
	[[_mockLocationManager expect] startUpdatingLocation];
	[[_mockLocationManager stub] stopUpdatingLocation];

	// Execute
	[_windowController windowDidLoad];
}

- (void)testDealloc
{
	// Setup
	NSUInteger preRetainCount = [_mockLocationManager retainCount];
	[[_mockLocationManager expect] stopUpdatingLocation];

	// Execute
	[_windowController release];
	_windowController = nil;

	// Verify
	NSUInteger postRetainCount = [_mockLocationManager retainCount];
	STAssertEquals(postRetainCount, preRetainCount - 1, nil);
}

@end
