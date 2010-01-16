#import "CoreLocationFormatter.h"

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>


@interface CoreLocationFormatterTest : SenTestCase
{
	id<CoreLocationFormatterDelegate> _mockDelegate;
	CoreLocationFormatter * _formatter;
}
@end

@implementation CoreLocationFormatterTest

- (CoreLocationFormatter *)makeFormatterWithFormatString:(NSString *)formatString
{
	CoreLocationFormatter * formatter = [[CoreLocationFormatter alloc] initWithFormatString:formatString];
	return [formatter autorelease];
}

- (CLLocation *)makeLocationWithLatitude:(CLLocationDegrees)latitude
							   longitude:(CLLocationDegrees)longitutde
{
	CLLocationCoordinate2D coord = {.latitude = latitude, .longitude = longitutde};
	CLLocation *location = [[CLLocation alloc]
							initWithCoordinate:coord
							altitude:0
							horizontalAccuracy:kCLLocationAccuracyBest
							verticalAccuracy:kCLLocationAccuracyHundredMeters
							timestamp:[NSDate date]];
	
	return [location autorelease];
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

- (void)setUp
{
	// Setup
	_mockDelegate = [OCMockObject mockForProtocol:@protocol(CoreLocationFormatterDelegate)];
	_formatter = [[CoreLocationFormatter alloc] initWithDelegate:_mockDelegate
													formatString:@"ll=%f,%f spn=%f,%f"];
}

- (void)tearDown
{
	// Verify
	[(id)_mockDelegate verify];
	
	// Teardown
	[_formatter release]; _formatter = nil;
}

#pragma mark -
#pragma mark Tests

- (void)testNewLocationSendsUpdateToDelegate
{
	// Setup
	CLLocation * location = [self makeLocationWithLatitude:-37.80996889 longitude:144.96326388];
	[[(id)_mockDelegate expect] locationFormatter:_formatter
						 didUpdateFormattedString:@"ll=-37.809969,144.963264 spn=-0.000018,-0.000014"
									locationLabel:@"-37.809969, 144.963264"
								   accuractyLabel:[NSString stringWithFormat:@"%f", kCLLocationAccuracyBest]];
	
	// Execute
	[_formatter locationManager:nil didUpdateToLocation:location fromLocation:nil];
}

- (void)testSameLocationDoesNotSendUpdateToDelegate
{
	// Setup
	CLLocation * location = [self makeLocationWithLatitude:-37.80996889 longitude:144.96326388];
	
	// Execute
	[_formatter locationManager:nil didUpdateToLocation:location fromLocation:location];
}

- (void)testFailedUpdateSendsUpdateToDelegate
{
	// Setup
	NSError * error = [self makeFakeErrorWithDescription:@"Some error description"];
	[[(id)_mockDelegate expect] locationFormatter:_formatter
						 didUpdateFormattedString:@"Location manager failed with error: Some error description"
									locationLabel:@""
								   accuractyLabel:@""];
	

	// Execute
	[_formatter locationManager:nil didFailWithError:error];
}

- (void)testUpdateToLocation
{
	CoreLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	
	BOOL updated = [formatter updateToLocation:location fromLocation:nil];
	
	STAssertTrue(updated, nil);
	STAssertEqualObjects(formatter.formattedString,
						 @"ll=-37.809969,144.963264 spn=-0.000018,-0.000014", nil);
	STAssertEqualObjects(formatter.locationLabel,
						 @"-37.809969, 144.963264", nil);
	STAssertEqualObjects(formatter.accuracyLabel,
						 ([NSString stringWithFormat:@"%f", kCLLocationAccuracyBest]),
						 nil);
}

- (void)testUpdatedIgnoredWithSameCoordinates
{
	CoreLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	
	BOOL updated = [formatter updateToLocation:location fromLocation:location];
	
	STAssertFalse(updated, nil);
}

- (void)testUpdateFailed
{
	CoreLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	[formatter updateToLocation:location fromLocation:nil];
	
	[formatter updateFailedWithError:[self makeFakeErrorWithDescription:@"Some error description"]];
	
	STAssertEqualObjects(formatter.formattedString,
						 @"Location manager failed with error: Some error description", nil);
	STAssertEqualObjects(formatter.locationLabel, @"", nil);
	STAssertEqualObjects(formatter.accuracyLabel, @"", nil);
}

- (void)testOpenInDefaultBrowser
{
	CoreLocationFormatter * formatter = [self makeFormatterWithFormatString:@"ll=%f,%f spn=%f,%f"];
	CLLocationCoordinate2D coord = {.latitude = -37.80996889, .longitude = 144.96326388};
	CLLocation * location = [self makeLocationWithCoordinate:coord];
	
	NSURL * expectedUrl = [NSURL URLWithString:
						   @"http://maps.google.com/maps?ll=-37.809969,144.963264&amp;spn=-0.000018,-0.000014"];
	STAssertEqualObjects([formatter googleMapsUrlForLocation:location],
						 expectedUrl, nil);
}

@end
