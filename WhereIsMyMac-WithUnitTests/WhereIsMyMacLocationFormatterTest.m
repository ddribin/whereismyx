#import "WhereIsMyMacLocationFormatterTest.h"
#import "WhereIsMyMacLocationFormatter.h"


@implementation WhereIsMyMacLocationFormatterTest

- (WhereIsMyMacLocationFormatter *)makeFormatterWithFormatString:(NSString *)formatString
{
	WhereIsMyMacLocationFormatter * formatter = [[WhereIsMyMacLocationFormatter alloc] initWithHtmlFormatString:formatString];
	return [formatter autorelease];
}

- (CLLocation *)makeLocationWithCoordinate:(CLLocationCoordinate2D)coord
{
	CLLocation *location = [[CLLocation alloc]
							initWithCoordinate:coord
							altitude:0
							horizontalAccuracy:kCLLocationAccuracyBest
							verticalAccuracy:kCLLocationAccuracyHundredMeters
							timestamp:[NSDate date]];
	
	return [location autorelease];
}

- (NSError *)makeFakeErrorWithDescription:(NSString *)localizedErrorDescription
{
	NSError * error = [NSError
					   errorWithDomain:@"TestDomain"
					   code:1234
					   userInfo:
					   [NSDictionary
						dictionaryWithObject:localizedErrorDescription
						forKey:NSLocalizedDescriptionKey]];
	return error;
}

#pragma mark -
#pragma mark Tests

- (void)testUpdateToLocation
{
	WhereIsMyMacLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	
	BOOL updated = [formatter uppdateToLocation:location fromLocation:nil];
	
	STAssertTrue(updated, nil);
	STAssertEqualObjects(formatter.htmlString,
						 @"ll=-37.809969,144.963264 spn=-0.000018,-0.000014", nil);
	STAssertEqualObjects(formatter.locationLabel,
						 @"-37.809969, 144.963264", nil);
	STAssertEqualObjects(formatter.accuracyLabel,
						 ([NSString stringWithFormat:@"%f", kCLLocationAccuracyBest]),
						 nil);
}

- (void)testUpdatedIgnoredWithSameCoordinates
{
	WhereIsMyMacLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	
	BOOL updated = [formatter uppdateToLocation:location fromLocation:location];
	
	STAssertFalse(updated, nil);
}

- (void)testUpdateFailed
{
	WhereIsMyMacLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	[formatter uppdateToLocation:location fromLocation:nil];
	
	[formatter updateFailedWithError:[self makeFakeErrorWithDescription:@"Some error description"]];
	
	STAssertEqualObjects(formatter.htmlString,
						 @"Location manager failed with error: Some error description", nil);
	STAssertEqualObjects(formatter.locationLabel, @"", nil);
	STAssertEqualObjects(formatter.accuracyLabel, @"", nil);
}

- (void)testOpenInDefaultBrowser
{
	WhereIsMyMacLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	
	NSURL * expectedUrl = [NSURL URLWithString:
						   @"http://maps.google.com/maps?ll=-37.809969,144.963264&amp;spn=-0.000018,-0.000014"];
	STAssertEqualObjects([formatter googleMapsUrlForLocation:location],
						 expectedUrl, nil);
}

@end
