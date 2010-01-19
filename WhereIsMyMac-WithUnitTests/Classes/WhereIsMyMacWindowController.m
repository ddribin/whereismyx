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
#import "MyCoreLocationFormatter.h"


@implementation WhereIsMyMacWindowController

@synthesize webView;
@synthesize locationLabel;
@synthesize accuracyLabel;
@synthesize openInBrowserButton;

- (id)init
{
    CLLocationManager * locationManager = [[[CLLocationManager alloc] init] autorelease];

    NSString * formatString = [NSString 
                               stringWithContentsOfFile:
                               [[NSBundle bundleForClass:[self class]]
                                pathForResource:@"HTMLFormatString" ofType:@"html"]
                               encoding:NSUTF8StringEncoding
                               error:NULL];
    MyCoreLocationFormatter * locationFormatter =
		[[[MyCoreLocationFormatter alloc] initWithDelegate:self
											  formatString:formatString] autorelease];
    return [self initWithLocationManager:locationManager
                       locationFormatter:locationFormatter
                               workspace:[NSWorkspace sharedWorkspace]];
}

- (id)initWithLocationManager:(CLLocationManager *)locationManager
            locationFormatter:(MyCoreLocationFormatter *)locationFormatter
                    workspace:(NSWorkspace *)workspace;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _locationManager = [locationManager retain];
    _locationFormatter = [locationFormatter retain];
    _workspace = [workspace retain];
    
    return self;
}

- (void)dealloc
{
    [_locationManager release];
    [_locationFormatter release];
    [_workspace release];
    
    [super dealloc];
}

- (NSString *)windowNibName
{
    return @"WhereIsMyMacWindow";
}

- (void)windowDidLoad
{
    _locationManager.delegate = _locationFormatter;
    [_locationManager startUpdatingLocation];
}

- (void)close
{
    [_locationManager stopUpdatingLocation];
	[super close];
}

- (IBAction)openInDefaultBrowser:(id)sender
{
    CLLocation *currentLocation = _locationManager.location;
    NSURL *externalBrowserURL = [_locationFormatter googleMapsUrlForLocation:currentLocation];

    [_workspace openURL:externalBrowserURL];
}

- (void)locationFormatter:(MyCoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)aFormattedString
            locationLabel:(NSString *)aLocationLabel
			accuracyLabel:(NSString *)anAccuracyLabel;
{
    [[webView mainFrame] loadHTMLString:aFormattedString baseURL:nil];
    [locationLabel setStringValue:aLocationLabel];
    [accuracyLabel setStringValue:anAccuracyLabel];
}

@end
