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


@implementation WhereIsMyMacWindowController

- (void)windowDidLoad
{
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
}

- (NSString *)windowNibName
{
	return @"WhereIsMyMacWindow";
}

+ (double)latitudeRangeForLocation:(CLLocation *)aLocation
{
	const double M = 6367000.0; // approximate average meridional radius of curvature of earth
	const double metersToLatitude = 1.0 / ((M_PI / 180.0) * M);
	const double accuracyToWindowScale = 2.0;
	
	return aLocation.horizontalAccuracy * metersToLatitude * accuracyToWindowScale;
}

+ (double)longitudeRangeForLocation:(CLLocation *)aLocation
{
	double latitudeRange =
		[WhereIsMyMacWindowController latitudeRangeForLocation:aLocation];
	
	return latitudeRange * cos(aLocation.coordinate.latitude * M_PI / 180.0);
}

- (IBAction)openInDefaultBrowser:(id)sender
{
	CLLocation *currentLocation = locationManager.location;
	
	NSURL *externalBrowserURL = [NSURL URLWithString:[NSString stringWithFormat:
		@"http://maps.google.com/maps?ll=%f,%f&amp;spn=%f,%f",
		currentLocation.coordinate.latitude,
		currentLocation.coordinate.longitude,
		[WhereIsMyMacWindowController latitudeRangeForLocation:currentLocation],
		[WhereIsMyMacWindowController longitudeRangeForLocation:currentLocation]]];

	[[NSWorkspace sharedWorkspace] openURL:externalBrowserURL];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
	fromLocation:(CLLocation *)oldLocation
{
	// Ignore updates where nothing we care about changed
	if (newLocation.coordinate.longitude == oldLocation.coordinate.longitude &&
		newLocation.coordinate.latitude == oldLocation.coordinate.latitude &&
		newLocation.horizontalAccuracy == oldLocation.horizontalAccuracy)
	{
		return;
	}

	// Load the HTML for displaying the Google map from a file and replace the
	// format placeholders with our location data
	NSString *htmlString = [NSString stringWithFormat:
		[NSString 
			stringWithContentsOfFile:
				[[NSBundle bundleForClass:[self class]]
					pathForResource:@"HTMLFormatString" ofType:@"html"]
			encoding:NSUTF8StringEncoding
			error:NULL],
		newLocation.coordinate.latitude,
		newLocation.coordinate.longitude,
		[WhereIsMyMacWindowController latitudeRangeForLocation:newLocation],
		[WhereIsMyMacWindowController longitudeRangeForLocation:newLocation]];
	
	// Load the HTML in the WebView and set the labels
	[[webView mainFrame] loadHTMLString:htmlString baseURL:nil];
	[locationLabel setStringValue:[NSString stringWithFormat:@"%f, %f",
		newLocation.coordinate.latitude, newLocation.coordinate.longitude]];
	[accuracyLabel setStringValue:[NSString stringWithFormat:@"%f",
		newLocation.horizontalAccuracy]];
}

- (void)locationManager:(CLLocationManager *)manager
	didFailWithError:(NSError *)error
{
	[[webView mainFrame]
		loadHTMLString:
			[NSString stringWithFormat:
				NSLocalizedString(@"Location manager failed with error: %@", nil),
				[error localizedDescription]]
		baseURL:nil];
	[locationLabel setStringValue:@""];
	[accuracyLabel setStringValue:@""];
}

- (void)dealloc
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	[super dealloc];
}

@end
