//
//  WhereIsMyMacWindowController.h
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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoreLocationFormatter.h"

@interface WhereIsMyMacWindowController : NSWindowController <CoreLocationFormatterDelegate>
{
	WebView *webView;
	NSTextField *locationLabel;
	NSTextField *accuracyLabel;
	NSButton *openInBrowserButton;
	
	CLLocationManager * _locationManager;
	CoreLocationFormatter * _locationFormatter;
}

@property (assign) IBOutlet WebView *webView;
@property (assign) IBOutlet NSTextField *locationLabel;
@property (assign) IBOutlet NSTextField *accuracyLabel;
@property (assign) IBOutlet NSButton *openInBrowserButton;

@property (nonatomic, retain) CLLocationManager * locationManager;
@property (nonatomic, retain) CoreLocationFormatter * locationFormatter;

- (id)init;
- (id)initWithLocationManager:(CLLocationManager *)locationManager
			locationFormatter:(CoreLocationFormatter *)locationFormatter;

- (IBAction)openInDefaultBrowser:(id)sender;

- (void)locationFormatter:(CoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString
			locationLabel:(NSString *)locationLabel
		   accuractyLabel:(NSString *)accuracyLabel;

@end
