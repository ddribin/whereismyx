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

@interface WhereIsMyMacWindowController : NSWindowController <CLLocationManagerDelegate>
{
	IBOutlet WebView *webView;
	CLLocationManager *locationManager;
	IBOutlet NSTextField *locationLabel;
	IBOutlet NSTextField *accuracyLabel;
	IBOutlet NSButton *openInBrowserButton;
}

- (IBAction)openInDefaultBrowser:(id)sender;

@end
