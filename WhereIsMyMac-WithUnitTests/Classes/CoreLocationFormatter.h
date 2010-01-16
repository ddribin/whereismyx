#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CoreLocationFormatter;

@protocol CoreLocationFormatterDelegate <NSObject>

- (void)locationFormatter:(CoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString
            locationLabel:(NSString *)locationLabel
			accuracyLabel:(NSString *)accuracyLabel;

@end

@interface CoreLocationFormatter : NSObject <CLLocationManagerDelegate>
{
    id<CoreLocationFormatterDelegate> _delegate;
    NSString * _formatString;
}

@property (nonatomic, assign, readwrite) id<CoreLocationFormatterDelegate> delegate;
@property (nonatomic, copy, readonly) NSString * formatString;

- (id)initWithDelegate:(id<CoreLocationFormatterDelegate>)delegate
          formatString:(NSString *)htmlFormatString;

- (NSURL *)googleMapsUrlForLocation:(CLLocation *)currentLocation;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end
