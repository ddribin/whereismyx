//
//  WhereIsMyPhoneViewControllerTests.m
//  WhereIsMyPhone
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
#import <CoreLocation/CoreLocation.h>
#import "NSObject+SupersequentImplementation.h"

id mockLocationManager = nil;
id mockApplication = nil;

@implementation CLLocationManager (WhereIsMyPhoneViewControllerTests)

- (id)init
{
	if (mockLocationManager)
	{
		[self release];
		return mockLocationManager;
	}
	
	return invokeSupersequentNoArgs();
}

@end

@implementation UIApplication (WhereIsMyPhoneViewControllerTests)

+ (id)sharedApplication
{
	if (mockApplication)
	{
		return mockApplication;
	}
	
	return invokeSupersequentNoArgs();
}

@end

@interface WhereIsMyPhoneViewControllerTests : SenTestCase 
{
	WhereIsMyPhoneViewController *viewController;
}

@end

@implementation WhereIsMyPhoneViewControllerTests

- (void)setUp
{
	viewController = [[WhereIsMyPhoneViewController alloc] init];
}

- (void)tearDown
{
	[viewController release];
}

#ifdef APPLICATION_TESTS

- (void)testLoadView
{
	[viewController loadView];

	UIWebView *webView;
	object_getInstanceVariable(viewController, "webView", (void **)&webView);
	CLLocationManager *locationManager;
	object_getInstanceVariable(viewController, "locationManager", (void **)&locationManager);
	UILabel *locationLabel;
	object_getInstanceVariable(viewController, "locationLabel", (void **)&locationLabel);
	UILabel *accuracyLabel;
	object_getInstanceVariable(viewController, "accuracyLabel", (void **)&accuracyLabel);
	UIButton *openInBrowserButton;
	object_getInstanceVariable(viewController, "openInBrowserButton", (void **)&openInBrowserButton);
	
	STAssertTrue([viewController isViewLoaded], @"View failed to load");
	STAssertNotNil(webView, @"webView ivar not set on load");
	STAssertNotNil(locationLabel, @"locationLabel ivar not set on load");
	STAssertNotNil(accuracyLabel, @"accuracyLabel ivar not set on load");
	STAssertNotNil(openInBrowserButton, @"openInBrowserButton ivar not set on load");
	
	NSArray *actions = [openInBrowserButton
		actionsForTarget:viewController
		forControlEvent:UIControlEventTouchUpInside];
	
	STAssertEqualObjects([actions objectAtIndex:0], @"openInDefaultBrowser:",
		@"openInBrowserButton button doesn't invoke openInDefaultBrowser:");
}

#endif

- (void)testViewDidLoad
{
	mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	[[mockLocationManager expect] setDelegate:viewController];
	[[mockLocationManager expect] startUpdatingLocation];

	[viewController viewDidLoad];

	[mockLocationManager verify];
	
	mockLocationManager = nil;
	object_setInstanceVariable(viewController, "locationManager", nil);
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
	id mockWebView = [OCMockObject mockForClass:[UIWebView class]];
	[[mockWebView expect]
		loadHTMLString:htmlString
		baseURL:nil];
	object_setInstanceVariable(viewController, "webView", mockWebView);

#ifdef APPLICATION_TESTS

	UILabel *locationLabel = [[[UILabel alloc] init] autorelease];
	UILabel *accuracyLabel = [[[UILabel alloc] init] autorelease];
	object_setInstanceVariable(viewController, "locationLabel", locationLabel);
	object_setInstanceVariable(viewController, "accuracyLabel", accuracyLabel);

#endif

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
	
	[viewController
		locationManager:nil
		didUpdateToLocation:location
		fromLocation:nil];
	[viewController
		locationManager:nil
		didUpdateToLocation:location
		fromLocation:location];
	
	[mockWebView verify];
	
#ifdef APPLICATION_TESTS

	STAssertEqualObjects(
		([locationLabel text]),
		([NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude]),
		@"Location label not set.");
	STAssertEqualObjects(
		([accuracyLabel text]),
		([NSString stringWithFormat:@"%f", kCLLocationAccuracyBest]),
		@"Location label not set.");

#endif
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
	id mockWebView = [OCMockObject mockForClass:[UIWebView class]];
	[[mockWebView expect]
		loadHTMLString:
			[NSString stringWithFormat:
				NSLocalizedString(@"Location manager failed with error: %@", nil),
				localizedErrorDescription]
		baseURL:nil];
	object_setInstanceVariable(viewController, "webView", mockWebView);

#ifdef APPLICATION_TESTS

	UILabel *locationLabel = [[[UILabel alloc] init] autorelease];
	UILabel *accuracyLabel = [[[UILabel alloc] init] autorelease];
	object_setInstanceVariable(viewController, "locationLabel", locationLabel);
	object_setInstanceVariable(viewController, "accuracyLabel", accuracyLabel);
	[locationLabel setText:@"initial"];
	[accuracyLabel setText:@"initial"];
	
#endif

	[viewController locationManager:nil didFailWithError:someError];
	
	[mockWebView verify];

#ifdef APPLICATION_TESTS

	STAssertEqualObjects(
		([locationLabel text]),
		@"",
		@"Location label not set.");
	STAssertEqualObjects(
		([accuracyLabel text]),
		@"",
		@"Location label not set.");

#endif
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
	object_setInstanceVariable(viewController, "locationManager", mockLocationManager);
	
	mockApplication = [OCMockObject mockForClass:[UIApplication class]];
	[[mockApplication expect] openURL:[NSURL URLWithString:
		@"http://maps.google.com/maps?ll=-37.809969,144.963264&amp;spn=-0.000018,-0.000014"]];
	
	[viewController retain];
	[viewController openInDefaultBrowser:nil];
	[viewController release];
	
	[mockApplication verify];
	mockApplication = nil;
	object_setInstanceVariable(viewController, "locationManager", nil);
}

- (void)testDealloc
{
	id mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
	NSUInteger preRetainCount = [mockLocationManager retainCount];
	[mockLocationManager retain];
	object_setInstanceVariable(viewController, "locationManager", mockLocationManager);
	
	[[mockLocationManager expect] stopUpdatingLocation];

	[viewController dealloc];
	
	[mockLocationManager verify];

	NSUInteger postRetainCount = [mockLocationManager retainCount];
	STAssertEquals(postRetainCount, preRetainCount, @"Location manager not released");
	
	viewController = nil;
}

@end
