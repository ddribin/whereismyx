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
#import "MyCoreLocationFormatter.h"

@interface WhereIsMyMacWindowController : NSWindowController <MyCoreLocationFormatterDelegate>
{
    WebView *webView;
    NSTextField *locationLabel;
    NSTextField *accuracyLabel;
    NSButton *openInBrowserButton;
    
    CLLocationManager * _locationManager;
    MyCoreLocationFormatter * _locationFormatter;
    NSWorkspace * _workspace;
}

@property (assign) IBOutlet WebView *webView;
@property (assign) IBOutlet NSTextField *locationLabel;
@property (assign) IBOutlet NSTextField *accuracyLabel;
@property (assign) IBOutlet NSButton *openInBrowserButton;

- (id)init;

// Designated Initializer
- (id)initWithLocationManager:(CLLocationManager *)locationManager
            locationFormatter:(MyCoreLocationFormatter *)locationFormatter
                    workspace:(NSWorkspace *)workspace;

- (IBAction)openInDefaultBrowser:(id)sender;

- (void)locationFormatter:(MyCoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString
            locationLabel:(NSString *)locationLabel
			accuracyLabel:(NSString *)accuracyLabel;

@end
