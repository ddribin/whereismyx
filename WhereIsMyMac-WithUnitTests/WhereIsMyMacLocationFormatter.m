#import "WhereIsMyMacLocationFormatter.h"


@interface WhereIsMyMacLocationFormatter ()
@property (nonatomic, copy, readwrite) NSURL * googleMapsUrl;
@property (nonatomic, copy, readwrite) NSString * htmlString;
@property (nonatomic, copy, readwrite) NSString * locationLabel;
@property (nonatomic, copy, readwrite) NSString * accuracyLabel;
@end

@implementation WhereIsMyMacLocationFormatter

@synthesize googleMapsUrl = _googleMapsUrl;
@synthesize htmlString = _htmlString;
@synthesize locationLabel = _locationLabel;
@synthesize accuracyLabel = _accuracyLabel;


+ (double)latitudeRangeForLocation:(CLLocation *)aLocation
{
	const double M = 6367000.0; // approximate average meridional radius of curvature of earth
	const double metersToLatitude = 1.0 / ((M_PI / 180.0) * M);
	const double accuracyToWindowScale = 2.0;
	
	return aLocation.horizontalAccuracy * metersToLatitude * accuracyToWindowScale;
}

+ (double)longitudeRangeForLocation:(CLLocation *)aLocation
{
	double latitudeRange =
	[self latitudeRangeForLocation:aLocation];
	
	return latitudeRange * cos(aLocation.coordinate.latitude * M_PI / 180.0);
}

- (id)initWithHtmlFormatString:(NSString *)htmlFormatString;
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	_htmlFormatString = [htmlFormatString copy];
	
	return self;
}

- (void)dealloc
{
	[_htmlFormatString release];
	[_googleMapsUrl release];
	[_htmlString release];
	[_locationLabel release];
	[_accuracyLabel release];
	[super dealloc];
}

- (BOOL)uppdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
{
	// Ignore updates where nothing we care about changed
	if (newLocation.coordinate.longitude == oldLocation.coordinate.longitude &&
		newLocation.coordinate.latitude == oldLocation.coordinate.latitude &&
		newLocation.horizontalAccuracy == oldLocation.horizontalAccuracy)
	{
		return NO;
	}
	
	NSString *htmlString = [NSString stringWithFormat:_htmlFormatString,
							newLocation.coordinate.latitude,
							newLocation.coordinate.longitude,
							[[self class] latitudeRangeForLocation:newLocation],
							[[self class] longitudeRangeForLocation:newLocation]];
	
	self.htmlString = htmlString;
	self.locationLabel = [NSString stringWithFormat:@"%f, %f",
						  newLocation.coordinate.latitude, newLocation.coordinate.longitude];
	self.accuracyLabel = [NSString stringWithFormat:@"%f",
						  newLocation.horizontalAccuracy];
	return YES;
}

- (void)updateFailedWithError:(NSError *)error;
{
	self.htmlString = [NSString stringWithFormat:
					   NSLocalizedString(@"Location manager failed with error: %@", nil),
					   [error localizedDescription]];
	self.locationLabel = @"";
	self.accuracyLabel = @"";
}

- (NSURL *)googleMapsUrlForLocation:(CLLocation *)location;
{
	NSURL * googleMapsUrl = [NSURL URLWithString:[NSString stringWithFormat:
												  @"http://maps.google.com/maps?ll=%f,%f&amp;spn=%f,%f",
												  location.coordinate.latitude,
												  location.coordinate.longitude,
												  [[self class] latitudeRangeForLocation:location],
												  [[self class] longitudeRangeForLocation:location]]];
	return googleMapsUrl;
}

@end
