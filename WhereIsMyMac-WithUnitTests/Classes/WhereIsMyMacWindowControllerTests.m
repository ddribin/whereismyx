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

id mockLocationManager = nil;

@implementation CLLocationManager (WhereIsMyMacWindowControllerTests)

- (id)init
{
	if (mockLocationManager)
	{
		[self release];
		return mockLocationManager;
	}
	
	return invokeSupersequent();
}

@end

@interface WhereIsMyMacWindowControllerTests : SenTestCase 
{
	WhereIsMyMacWindowController *windowController;
}

@end

@implementation WhereIsMyMacWindowControllerTests

- (void)setUp
{
	windowController = [[WhereIsMyMacWindowController alloc] init];
}

- (void)tearDown
{
	[windowController close];
	[windowController release];
}

- (void)testLoadWindow
{
	[windowController loadWindow];

	WebView *webView = windowController.webView;
	NSTextField *locationLabel = windowController.locationLabel;
	NSTextField *accuracyLabel = windowController.accuracyLabel;
	NSButton *openInBrowserButton = windowController.openInBrowserButton;
	
	STAssertTrue([windowController isWindowLoaded], @"Window failed to load");
	STAssertNotNil(webView, @"webView ivar not set on load");
	STAssertNotNil(locationLabel, @"locationLabel ivar not set on load");
	STAssertNotNil(accuracyLabel, @"accuracyLabel ivar not set on load");
	STAssertNotNil(openInBrowserButton, @"openInBrowserButton ivar not set on load");
	STAssertEqualObjects(windowController, [openInBrowserButton target],
		@"openInBrowserButton button doesn't target window controller");
	STAssertTrue([openInBrowserButton action] == @selector(openInDefaultBrowser:),
		@"openInBrowserButton button doesn't invoke openInDefaultBrowser:");
}

- (void)testWindowDidLoad
{
	mockLocationManager = [[OCMockObject mockForClass:[CLLocationManager class]] retain];
	[[mockLocationManager expect] setDelegate:windowController];
	[[mockLocationManager expect] startUpdatingLocation];
	[[mockLocationManager stub] stopUpdatingLocation];

	[windowController windowDidLoad];

	[mockLocationManager verify];
	
	windowController.locationManager = nil;
	mockLocationManager = nil;
}

- (void)testDealloc
{
	id mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	[mockLocationManager retain];
	NSUInteger preRetainCount = [mockLocationManager retainCount];
	windowController.locationManager = mockLocationManager;
	
	[[mockLocationManager expect] stopUpdatingLocation];

	[windowController dealloc];
	
	[mockLocationManager verify];

	NSUInteger postRetainCount = [mockLocationManager retainCount];
	STAssertEquals(postRetainCount, preRetainCount, @"Location manager not released");
	
	windowController = nil;
	[mockLocationManager release];
}

@end
