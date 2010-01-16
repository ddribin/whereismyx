//
//  WhereIsMyMacAppDelegate.m
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

#import "WhereIsMyMacAppDelegate.h"
#import "WhereIsMyMacWindowController.h"

@implementation WhereIsMyMacAppDelegate

@synthesize windowController = _windowController;

- (id)init
{
	self = [super init];
	if (self == nil)
		return nil;
	
	_windowController = [[WhereIsMyMacWindowController alloc] init];
	
	return self;
}

- (void)dealloc
{
	[_windowController release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[[self.windowController window] makeKeyAndOrderFront:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self.windowController close];
	self.windowController = nil;
}

@end
