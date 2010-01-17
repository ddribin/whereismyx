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
#import <CoreLocation/CoreLocation.h>

#import "WhereIsMyPhoneAppDelegate.h"
#import "WhereIsMyPhoneViewController.h"


@interface WhereIsMyPhoneViewControllerTests : SenTestCase 
{
    id _mockLocationManager;
    id _mockLocationFormatter;
    id _mockApplication;
	WhereIsMyPhoneViewController * _viewController;
}

@end

@implementation WhereIsMyPhoneViewControllerTests

- (void)setUp
{
    // Setup
    _mockLocationManager = [OCMockObject mockForClass:[CLLocationManager class]];
    _mockLocationFormatter = [OCMockObject mockForClass:[CoreLocationFormatter class]];
    _mockApplication = [OCMockObject mockForClass:[UIApplication class]];
	_viewController = [[WhereIsMyPhoneViewController alloc]
					   initWithLocationManager:_mockLocationManager
					   locationFormatter:_mockLocationFormatter
					   application:_mockApplication];
}

- (void)tearDown
{
	// Verify
	[_mockLocationManager verify];
	[_mockLocationFormatter verify];
	[_mockApplication verify];
	
	// Teardown
	[_viewController release];
}

#if APPLICATION_TESTS

- (void)testLoadView
{
	[_viewController loadView];

	STAssertTrue([_viewController isViewLoaded], nil);
	STAssertNotNil(_viewController.webView, nil);
	STAssertNotNil(_viewController.locationLabel, nil);
	STAssertNotNil(_viewController.accuracyLabel, nil);
	STAssertNotNil(_viewController.openInBrowserButton, nil);
	
	NSArray *actions = [_viewController.openInBrowserButton
		actionsForTarget:_viewController
		forControlEvent:UIControlEventTouchUpInside];
	
	STAssertEqualObjects([actions objectAtIndex:0], @"openInDefaultBrowsers:",
		nil);
}

#endif

- (void)testViewDidLoadStartsLocationManager
{
	// Setup
    [[_mockLocationManager expect] setDelegate:_mockLocationFormatter];
    [[_mockLocationManager expect] startUpdatingLocation];
	
    // Execute
    [_viewController viewDidLoad];
}

- (void)testViewDidUnloadStopsLocationManager
{
    // Setup
    [[_mockLocationManager expect] stopUpdatingLocation];
	
    // Execute
    [_viewController viewDidUnload];
}

- (void)testOpenInDefaultBrowserActionOpensGoogleMapsUrlInWorkspace
{
    // Setup
    [[[_mockLocationManager stub] andReturn:nil] location];
    NSURL * dummyUrl = [NSURL URLWithString:@"http://example.com/"];
    [[[_mockLocationFormatter stub] andReturn:dummyUrl] googleMapsUrlForLocation:nil];
    [[_mockApplication expect] openURL:dummyUrl];
    
    // Execute
    [_viewController openInDefaultBrowser:nil];
}

- (void)testLocationFormatterDelegateUpdatesUI
{
    // Setup
    id mockWebView = [OCMockObject mockForClass:[UIWebView class]];
    id mockLocationLabel = [OCMockObject mockForClass:[UILabel class]];
    id mockAccuracyLabel = [OCMockObject mockForClass:[UILabel class]];
    
    _viewController.webView = mockWebView;
    _viewController.locationLabel = mockLocationLabel;
    _viewController.accuracyLabel = mockAccuracyLabel;
    
    [[mockWebView expect] loadHTMLString:@"html string" baseURL:nil];
    [[mockLocationLabel expect] setText:@"location"];
    [[mockAccuracyLabel expect] setText:@"accuracy"];
    
    // Execute
    [_viewController locationFormatter:_mockLocationFormatter
			  didUpdateFormattedString:@"html string"
						 locationLabel:@"location"
						 accuracyLabel:@"accuracy"];
    
    // Verify
    [mockWebView verify];
    [mockLocationLabel verify];
    [mockAccuracyLabel verify];
}

@end
