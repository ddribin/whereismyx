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


@interface WhereIsMyPhoneAppDelegateTests : SenTestCase 
{
    id _mockViewController;
    WhereIsMyPhoneAppDelegate * _appDelegate;
}

@end

@implementation WhereIsMyPhoneAppDelegateTests

- (void)setUp
{
    _mockViewController = [OCMockObject mockForClass:[WhereIsMyPhoneViewController class]];
    _appDelegate = [[[WhereIsMyPhoneAppDelegate alloc] init] autorelease];
    _appDelegate.viewController = _mockViewController;
}

- (void)tearDown
{
    [_mockViewController verify];
}

#ifdef APPLICATION_TESTS

- (void)testAppDelegate
{
    // Execute
    id appDelegate = [[UIApplication sharedApplication] delegate];
    
    // Verify
    STAssertNotNil(appDelegate, nil);
}

#endif

- (void)testApplicationDidFinishLaunchingShowsWindow
{
    // Setup
    id mockView = [OCMockObject mockForClass:[UIView class]];
    [[[_mockViewController stub] andReturn:mockView] view];
    id mockWindow = [OCMockObject mockForClass:[UIWindow class]];
    _appDelegate.window = mockWindow;

    [[mockView expect] setFrame:CGRectMake(0, 20, 320, 460)];
    [[mockWindow expect] addSubview:mockView];
    [[mockWindow expect] makeKeyAndVisible];
    
    // Execute
    [_appDelegate applicationDidFinishLaunching:nil];

    // Verify
    [mockView verify];
    [mockWindow verify];
}

- (void)testApplicationWillTerminateNilsOutOutlets
{
    // Setup
    id mockWindow = [OCMockObject mockForClass:[UIWindow class]];
    _appDelegate.window = mockWindow;
    
    // Execute
    [_appDelegate applicationWillTerminate:nil];
    
    // Verify
    STAssertNil(_appDelegate.viewController, nil);
    STAssertNil(_appDelegate.window, nil);
}

@end
