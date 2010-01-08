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

@class WhereIsMyMacLocationFormatter;

@interface WhereIsMyMacWindowController : NSWindowController <CLLocationManagerDelegate>
{
	WebView *webView;
	CLLocationManager *locationManager;
	NSTextField *locationLabel;
	NSTextField *accuracyLabel;
	NSButton *openInBrowserButton;
	WhereIsMyMacLocationFormatter *locationFormatter;
}

@property (assign) IBOutlet WebView *webView;
@property (retain) CLLocationManager *locationManager;
@property (assign) IBOutlet NSTextField *locationLabel;
@property (assign) IBOutlet NSTextField *accuracyLabel;
@property (assign) IBOutlet NSButton *openInBrowserButton;

- (IBAction)openInDefaultBrowser:(id)sender;

@end
