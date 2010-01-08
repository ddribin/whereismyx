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
id mockWorkspace = nil;

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

@implementation NSWorkspace (WhereIsMyMacWindowControllerTests)

+ (id)sharedWorkspace
{
	if (mockWorkspace)
	{
		return mockWorkspace;
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

	WebView *webView;
	object_getInstanceVariable(windowController, "webView", (void **)&webView);
	CLLocationManager *locationManager;
	object_getInstanceVariable(windowController, "locationManager", (void **)&locationManager);
	NSTextField *locationLabel;
	object_getInstanceVariable(windowController, "locationLabel", (void **)&locationLabel);
	NSTextField *accuracyLabel;
	object_getInstanceVariable(windowController, "accuracyLabel", (void **)&accuracyLabel);
	NSButton *openInBrowserButton;
	object_getInstanceVariable(windowController, "openInBrowserButton", (void **)&openInBrowserButton);
	
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
	mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	[[mockLocationManager expect] setDelegate:windowController];
	[[mockLocationManager expect] startUpdatingLocation];

	[windowController windowDidLoad];

	[mockLocationManager verify];
	
	object_setInstanceVariable(windowController, "locationManager", nil);
	mockLocationManager = nil;
}

- (void)testUpdateToLocation
{
	NSString *htmlString =
		[NSString 
			stringWithContentsOfFile:
				[[NSBundle bundleForClass:[self class]]
					pathForResource:@"WebPageTestContent" ofType:@"html"]
			encoding:NSUTF8StringEncoding
			error:NULL];
	id mockWebView = [OCMockObject mockForClass:[WebView class]];
	id mockWebFrame = [OCMockObject mockForClass:[WebFrame class]];
	[[[mockWebView stub] andReturn:mockWebFrame] mainFrame];
	[[mockWebFrame expect]
		loadHTMLString:htmlString
		baseURL:nil];
	object_setInstanceVariable(windowController, "webView", mockWebView);

	NSTextField *locationLabel = [[[NSTextField alloc] init] autorelease];
	NSTextField *accuracyLabel = [[[NSTextField alloc] init] autorelease];
	object_setInstanceVariable(windowController, "locationLabel", locationLabel);
	object_setInstanceVariable(windowController, "accuracyLabel", accuracyLabel);

	CLLocationCoordinate2D coord;
	coord.longitude = 144.96326388;
	coord.latitude = -37.80996889;
	CLLocation *location =
		[[[CLLocation alloc]
			initWithCoordinate:coord
			altitude:0
			horizontalAccuracy:kCLLocationAccuracyBest
			verticalAccuracy:kCLLocationAccuracyHundredMeters
			timestamp:[NSDate date]]
		autorelease];
	
	[windowController
		locationManager:nil
		didUpdateToLocation:location
		fromLocation:nil];
	[windowController
		locationManager:nil
		didUpdateToLocation:location
		fromLocation:location];
	
	[mockWebFrame verify];
	
	STAssertEqualObjects(
		([locationLabel stringValue]),
		([NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude]),
		@"Location label not set.");
	STAssertEqualObjects(
		([accuracyLabel stringValue]),
		([NSString stringWithFormat:@"%f", kCLLocationAccuracyBest]),
		@"Location label not set.");
}

- (void)testUpdateFailed
{
	NSString *localizedErrorDescription = @"Some error description";
	NSError *someError =
		[NSError
			errorWithDomain:@"TestDomain"
			code:1234
			userInfo:
				[NSDictionary
					dictionaryWithObject:localizedErrorDescription
					forKey:NSLocalizedDescriptionKey]];
	id mockWebView = [OCMockObject mockForClass:[WebView class]];
	id mockWebFrame = [OCMockObject mockForClass:[WebFrame class]];
	[[[mockWebView stub] andReturn:mockWebFrame] mainFrame];
	[[mockWebFrame expect]
		loadHTMLString:
			[NSString stringWithFormat:
				NSLocalizedString(@"Location manager failed with error: %@", nil),
				localizedErrorDescription]
		baseURL:nil];
	object_setInstanceVariable(windowController, "webView", mockWebView);

	NSTextField *locationLabel = [[[NSTextField alloc] init] autorelease];
	NSTextField *accuracyLabel = [[[NSTextField alloc] init] autorelease];
	object_setInstanceVariable(windowController, "locationLabel", locationLabel);
	object_setInstanceVariable(windowController, "accuracyLabel", accuracyLabel);
	[locationLabel setStringValue:@"initial"];
	[accuracyLabel setStringValue:@"initial"];
	
	[windowController locationManager:nil didFailWithError:someError];
	
	[mockWebFrame verify];

	STAssertEqualObjects(
		([locationLabel stringValue]),
		@"",
		@"Location label not set.");
	STAssertEqualObjects(
		([accuracyLabel stringValue]),
		@"",
		@"Location label not set.");
}

- (void)testOpenInDefaultBrowser
{
	CLLocationCoordinate2D coord;
	coord.longitude = 144.96326388;
	coord.latitude = -37.80996889;
	CLLocation *location =
		[[[CLLocation alloc]
			initWithCoordinate:coord
			altitude:0
			horizontalAccuracy:kCLLocationAccuracyBest
			verticalAccuracy:kCLLocationAccuracyHundredMeters
			timestamp:[NSDate date]]
		autorelease];

	id mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	[[[mockLocationManager stub] andReturn:location] location];
	object_setInstanceVariable(windowController, "locationManager", mockLocationManager);
	
	mockWorkspace = [OCMockObject mockForClass:[NSWorkspace class]];
	[[mockWorkspace expect] openURL:[NSURL URLWithString:
		@"http://maps.google.com/maps?ll=-37.809969,144.963264&amp;spn=-0.000018,-0.000014"]];
	
	[windowController openInDefaultBrowser:nil];
	
	[mockWorkspace verify];
	mockWorkspace = nil;
	object_setInstanceVariable(windowController, "locationManager", nil);
}

- (void)testDealloc
{
	id mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	NSUInteger preRetainCount = [mockLocationManager retainCount];
	[mockLocationManager retain];
	object_setInstanceVariable(windowController, "locationManager", mockLocationManager);
	
	[[mockLocationManager expect] stopUpdatingLocation];

	[windowController dealloc];
	
	[mockLocationManager verify];

	NSUInteger postRetainCount = [mockLocationManager retainCount];
	STAssertEquals(postRetainCount, preRetainCount, @"Location manager not released");
	
	windowController = nil;
}

@end
