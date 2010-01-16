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
@synthesize locationLabel;
@synthesize accuracyLabel;
@synthesize openInBrowserButton;

@synthesize locationManager = _locationManager;
@synthesize locationFormatter = _locationFormatter;

- (id)init
{
	CLLocationManager * locationManager = [[[CLLocationManager alloc] init] autorelease];

	NSString * formatString = [NSString 
							   stringWithContentsOfFile:
							   [[NSBundle bundleForClass:[self class]]
								pathForResource:@"HTMLFormatString" ofType:@"html"]
							   encoding:NSUTF8StringEncoding
							   error:NULL];
	CoreLocationFormatter * locationFormatter =
		[[[CoreLocationFormatter alloc] initWithDelegate:self
											formatString:formatString] autorelease];
	return [self initWithLocationManager:locationManager locationFormatter:locationFormatter];
}

- (id)initWithLocationManager:(CLLocationManager *)locationManager
			locationFormatter:(CoreLocationFormatter *)locationFormatter
{
	self = [super init];
	if (self == nil)
		return nil;
	
	_locationManager = [locationManager retain];
	_locationFormatter = [locationFormatter retain];
	
	return self;
}

- (void)dealloc
{
	[_locationManager stopUpdatingLocation];
	[_locationManager release];
	[_locationFormatter release];
	
	[super dealloc];
}

- (void)windowDidLoad
{
	_locationManager.delegate = _locationFormatter;
	[_locationManager startUpdatingLocation];
}

- (NSString *)windowNibName
{
	return @"WhereIsMyMacWindow";
}

- (IBAction)openInDefaultBrowser:(id)sender
{
	CLLocation *currentLocation = _locationManager.location;
	NSURL *externalBrowserURL = [_locationFormatter googleMapsUrlForLocation:currentLocation];

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

@end
