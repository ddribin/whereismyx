#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface CoreLocationFormatter : NSObject
{
	NSString * _formatString;
	NSString * _formattedString;
	NSString * _locationLabel;
	NSString * _accuracyLabel;
}

@property (nonatomic, copy, readonly) NSString * formattedString;
@property (nonatomic, copy, readonly) NSString * locationLabel;
@property (nonatomic, copy, readonly) NSString * accuracyLabel;

- (id)initWithFormatString:(NSString *)htmlFormatString;

- (BOOL)updateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)updateFailedWithError:(NSError *)error;

- (NSURL *)googleMapsUrlForLocation:(CLLocation *)currentLocation;

@end
