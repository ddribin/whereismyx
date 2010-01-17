//
//	WhereIsMyPhoneViewController.h
//	WhereIsMyPhone
//
//	Created by Matt Gallagher on 2009/12/20.
//	Copyright Matt Gallagher 2009. All rights reserved.
//
//	Permission is given to use this source code file, free of charge, in any
//	project, commercial or otherwise, entirely at your risk, with the condition
//	that any redistribution (in part or whole) of source code must retain
//	this copyright and permission notice. Attribution in compiled projects is
//	appreciated but not required.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CoreLocationFormatter.h"

@interface WhereIsMyPhoneViewController : UIViewController <CoreLocationFormatterDelegate>
{
	UIWebView *webView;
	UILabel *locationLabel;
	UILabel *accuracyLabel;
	UIButton *openInBrowserButton;
	
	CLLocationManager * _locationManager;
	CoreLocationFormatter * _locationFormatter;
	UIApplication * _application;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *accuracyLabel;
@property (nonatomic, retain) IBOutlet UIButton *openInBrowserButton;

- (id)init;
- (id)initWithLocationManager:(CLLocationManager *)locationManager
			locationFormatter:(CoreLocationFormatter *)locationFormatter
				  application:(UIApplication *)application;

- (void)locationFormatter:(CoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString
			locationLabel:(NSString *)locationLabel
			accuracyLabel:(NSString *)accuracyLabel;

- (IBAction)openInDefaultBrowser:(id)sender;

@end

