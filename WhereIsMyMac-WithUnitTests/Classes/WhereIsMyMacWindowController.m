//
//  WhereIsMyMacWindowController.m
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

#import "WhereIsMyMacWindowController.h"
#import "CoreLocationFormatter.h"


@implementation WhereIsMyMacWindowController

@synthesize webView;
@synthesize locationManager;
@synthesize locationLabel;
@synthesize accuracyLabel;
@synthesize openInBrowserButton;

- (void)windowDidLoad
{
	locationManager = [[CLLocationManager alloc] init];
	[locationManager startUpdatingLocation];
	NSString * formatString = [NSString 
							   stringWithContentsOfFile:
							   [[NSBundle bundleForClass:[self class]]
								pathForResource:@"HTMLFormatString" ofType:@"html"]
							   encoding:NSUTF8StringEncoding
							   error:NULL];
	locationFormatter = [[CoreLocationFormatter alloc] initWithDelegate:self
														   formatString:formatString];
	
	locationManager.delegate = locationFormatter;
}

- (NSString *)windowNibName
{
	return @"WhereIsMyMacWindow";
}

- (IBAction)openInDefaultBrowser:(id)sender
{
	CLLocation *currentLocation = locationManager.location;
	NSURL *externalBrowserURL = [locationFormatter googleMapsUrlForLocation:currentLocation];

	[[NSWorkspace sharedWorkspace] openURL:externalBrowserURL];
}

- (void)locationFormatter:(CoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString_
			locationLabel:(NSString *)locationLabel_
		   accuractyLabel:(NSString *)accuracyLabel_;
{
	[[webView mainFrame] loadHTMLString:formattedString_ baseURL:nil];
	[locationLabel setStringValue:locationLabel_];
	[accuracyLabel setStringValue:accuracyLabel_];
}

- (void)dealloc
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
	[locationFormatter release];
	
	[super dealloc];
}

@end
