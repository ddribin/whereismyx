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
	NSString * formatString = [NSString 
							   stringWithContentsOfFile:
							   [[NSBundle bundleForClass:[self class]]
								pathForResource:@"HTMLFormatString" ofType:@"html"]
							   encoding:NSUTF8StringEncoding
							   error:NULL];
	locationFormatter = [[CoreLocationFormatter alloc] initWithDelegate:self formatString:formatString];

	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = locationFormatter;
	[locationManager startUpdatingLocation];
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

- (void)locationFormatter:(CoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString_
			locationLabel:(NSString *)locationLabel_
		   accuractyLabel:(NSString *)accuracyLabel_;
{
	// Load the HTML in the WebView and set the labels
	[webView loadHTMLString:formattedString_ baseURL:nil];
	[locationLabel setText:locationLabel_];
	[accuracyLabel setText:accuracyLabel_];
}

- (void)dealloc
{
	[locationManager stopUpdatingLocation];
	[locationManager release];
	
	[super dealloc];
}

@end
