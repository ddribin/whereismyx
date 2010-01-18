#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class MyCoreLocationFormatter;

@protocol MyCoreLocationFormatterDelegate <NSObject>

- (void)locationFormatter:(MyCoreLocationFormatter *)formatter
 didUpdateFormattedString:(NSString *)formattedString
            locationLabel:(NSString *)locationLabel
            accuracyLabel:(NSString *)accuracyLabel;

@end

@interface MyCoreLocationFormatter : NSObject <CLLocationManagerDelegate>
{
    id<MyCoreLocationFormatterDelegate> _delegate;
    NSString * _formatString;
}

@property (nonatomic, assign, readwrite) id<MyCoreLocationFormatterDelegate> delegate;
@property (nonatomic, copy, readonly) NSString * formatString;

- (id)initWithDelegate:(id<MyCoreLocationFormatterDelegate>)delegate
          formatString:(NSString *)htmlFormatString;

- (NSURL *)googleMapsUrlForLocation:(CLLocation *)currentLocation;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end
