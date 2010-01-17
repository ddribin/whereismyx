#import "CoreLocationFormatter.h"


@interface CoreLocationFormatter ()
+ (double)latitudeRangeForLocation:(CLLocation *)aLocation;
+ (double)longitudeRangeForLocation:(CLLocation *)aLocation;
@end

@implementation CoreLocationFormatter

@synthesize delegate = _delegate;
@synthesize formatString = _formatString;


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

- (id)initWithDelegate:(id<CoreLocationFormatterDelegate>)delegate
          formatString:(NSString *)htmlFormatString;
{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    
    _delegate = delegate;
    _formatString = [htmlFormatString copy];
    
    return self;
}

- (void)dealloc
{
    [_formatString release];
    [super dealloc];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;
{
    // Ignore updates where nothing we care about changed
    if (newLocation.coordinate.longitude == oldLocation.coordinate.longitude &&
        newLocation.coordinate.latitude == oldLocation.coordinate.latitude &&
        newLocation.horizontalAccuracy == oldLocation.horizontalAccuracy)
    {
        return;
    }
    
    NSString * formattedString = [NSString stringWithFormat:_formatString,
                                  newLocation.coordinate.latitude,
                                  newLocation.coordinate.longitude,
                                  [[self class] latitudeRangeForLocation:newLocation],
                                  [[self class] longitudeRangeForLocation:newLocation]];
    
    NSString * locationLabel = [NSString stringWithFormat:@"%f, %f",
                                newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    NSString * accuracyLabel = [NSString stringWithFormat:@"%f",
                                newLocation.horizontalAccuracy];

    [_delegate locationFormatter:self
        didUpdateFormattedString:formattedString
                   locationLabel:locationLabel
				   accuracyLabel:accuracyLabel];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;
{
    NSString * formattedString = [NSString stringWithFormat:
                                  NSLocalizedString(@"Location manager failed with error: %@", nil),
                                  [error localizedDescription]];
    [_delegate locationFormatter:self
        didUpdateFormattedString:formattedString
                   locationLabel:@""
				   accuracyLabel:@""];
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
