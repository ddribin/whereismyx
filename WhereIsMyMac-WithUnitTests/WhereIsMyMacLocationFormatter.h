#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>


@interface WhereIsMyMacLocationFormatter : NSObject
{
	NSString * _htmlFormatString;
	NSURL * _googleMapsUrl;
	NSString * _htmlString;
	NSString * _locationLabel;
	NSString * _accuracyLabel;
}

@property (nonatomic, copy, readonly) NSString * htmlString;
@property (nonatomic, copy, readonly) NSString * locationLabel;
@property (nonatomic, copy, readonly) NSString * accuracyLabel;

- (id)initWithHtmlFormatString:(NSString *)htmlFormatString;

- (void)uppdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
- (void)updateFailedWithError:(NSError *)error;

- (NSURL *)googleMapsUrlForLocation:(CLLocation *)currentLocation;

@end
