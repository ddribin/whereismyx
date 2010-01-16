#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CoreLocationFormatter;

@protocol CoreLocationFormatterDelegate <NSObject>

- (void)locationFormatter:(CoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString
			locationLabel:(NSString *)locationLabel
		   accuractyLabel:(NSString *)accuracyLabel;

@end

@interface CoreLocationFormatter : NSObject <CLLocationManagerDelegate>
{
	id<CoreLocationFormatterDelegate> _delegate;
	NSString * _formatString;
	NSString * _formattedString;
	NSString * _locationLabel;
	NSString * _accuracyLabel;
}

@property (nonatomic, copy, readonly) NSString * formattedString;
@property (nonatomic, copy, readonly) NSString * locationLabel;
@property (nonatomic, copy, readonly) NSString * accuracyLabel;

- (id)initWithDelegate:(id<CoreLocationFormatterDelegate>)delegate
		  formatString:(NSString *)htmlFormatString;

- (id)initWithFormatString:(NSString *)htmlFormatString;

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

- (BOOL)updateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)updateFailedWithError:(NSError *)error;

- (NSURL *)googleMapsUrlForLocation:(CLLocation *)currentLocation;

@end
