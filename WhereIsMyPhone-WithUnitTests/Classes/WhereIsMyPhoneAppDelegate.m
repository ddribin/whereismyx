//
//  WhereIsMyPhoneAppDelegate.m
//  WhereIsMyPhone
//
//  Created by Matt Gallagher on 2009/12/20.
//  Copyright Matt Gallagher 2009. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "WhereIsMyPhoneAppDelegate.h"
#import "WhereIsMyPhoneViewController.h"

@implementation WhereIsMyPhoneAppDelegate

@synthesize window;
@synthesize viewController;

- (id)init
{
	self = [super init];
	if (self == nil)
		return nil;
	
	viewController = [[WhereIsMyPhoneViewController alloc] init];
	
	return self;
}

- (void)dealloc
{
    [window release];
    [viewController release];
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    viewController.view.frame = CGRectMake(0, 20, 320, 460);

    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    self.viewController = nil;
    self.window = nil;
}


@end
