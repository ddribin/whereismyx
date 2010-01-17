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
    CoreLocationFormatter * locationFormatter =
    [[[CoreLocationFormatter alloc] initWithDelegate:self
                                        formatString:formatString] autorelease];
    return [self initWithLocationManager:locationManager
                       locationFormatter:locationFormatter
                             application:[UIApplication sharedApplication]];
}

- (id)initWithLocationManager:(CLLocationManager *)locationManager
            locationFormatter:(CoreLocationFormatter *)locationFormatter
                  application:(UIApplication *)application;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    _locationManager = [locationManager retain];
    _locationFormatter = [locationFormatter retain];
    _application = [application retain];
    
    return self;
}

- (void)dealloc
{
    [webView release];
    [locationLabel release];
    [accuracyLabel release];
    [openInBrowserButton release];
    
    [_locationManager release];
    [_locationFormatter release];
    [_application release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    _locationManager.delegate = _locationFormatter;
    [_locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [_locationManager stopUpdatingLocation];
}

- (NSString *)nibName
{
    return @"WhereIsMyPhoneViewController";
}

- (IBAction)openInDefaultBrowser:(id)sender
{
    CLLocation *currentLocation = _locationManager.location;
    NSURL *externalBrowserURL = [_locationFormatter googleMapsUrlForLocation:currentLocation];
    [_application openURL:externalBrowserURL];
}

- (void)locationFormatter:(CoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString_
            locationLabel:(NSString *)locationLabel_
            accuracyLabel:(NSString *)accuracyLabel_;
{
    // Load the HTML in the WebView and set the labels
    [webView loadHTMLString:formattedString_ baseURL:nil];
    [locationLabel setText:locationLabel_];
    [accuracyLabel setText:accuracyLabel_];
}

@end
