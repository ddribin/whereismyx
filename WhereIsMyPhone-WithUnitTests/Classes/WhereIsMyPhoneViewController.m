//
//  WhereIsMyPhoneViewController.m
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

#import "WhereIsMyPhoneViewController.h"
#import "CoreLocationFormatter.h"

@implementation WhereIsMyPhoneViewController

- (void)viewDidLoad
{
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
	NSString * formatString = [NSString 
							   stringWithContentsOfFile:
							   [[NSBundle bundleForClass:[self class]]
								pathForResource:@"HTMLFormatString" ofType:@"html"]
							   encoding:NSUTF8StringEncoding
							   error:NULL];
	locationFormatter = [[CoreLocationFormatter alloc] initWithFormatString:formatString];
}

- (NSString *)nibName
{
	return @"WhereIsMyPhoneViewController";
}

- (IBAction)openInDefaultBrowser:(id)sender
{
	CLLocation *currentLocation = locationManager.location;
	NSURL *externalBrowserURL = [locationFormatter googleMapsUrlForLocation:currentLocation];
	[[UIApplication sharedApplication] openURL:externalBrowserURL];
}

- (void)updateUI
{
	// Load the HTML in the WebView and set the labels
	NSString *htmlString = locationFormatter.formattedString;
	[webView loadHTMLString:htmlString baseURL:nil];
	[locationLabel setText:locationFormatter.locationLabel];
	[accuracyLabel setText:locationFormatter.accuracyLabel];
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
	fromLocation:(CLLocation *)oldLocation
{
	// Ignore updates where nothing we care about changed
	if (![locationFormatter updateToLocation:newLocation fromLocation:oldLocation])
	{
		return;
	}
	[self updateUI];
}

- (void)locationManager:(CLLocationManager *)manager
	didFailWithError:(NSError *)error
{
	[locationFormatter updateFailedWithError:error];
	[self updateUI];
}

- (void)dealloc
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	[super dealloc];
}

@end
