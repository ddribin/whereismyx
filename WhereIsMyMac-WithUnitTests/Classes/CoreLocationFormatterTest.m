#import "CoreLocationFormatter.h"

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>


@interface CoreLocationFormatterTest : SenTestCase
{
    id _mockDelegate;
    CoreLocationFormatter * _formatter;
}
@end

@implementation CoreLocationFormatterTest

#pragma mark -
#pragma mark Helpers

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
#pragma mark Fixture

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
    [_mockDelegate verify];
    
    // Teardown
    [_formatter release]; _formatter = nil;
}

#pragma mark -
#pragma mark Tests

- (void)testUpdateToNewLocationSendsUpdateToDelegate
{
    // Setup
    CLLocation * location = [self makeLocationWithLatitude:-37.80996889 longitude:144.96326388];
    [[_mockDelegate expect] locationFormatter:_formatter
                     didUpdateFormattedString:@"ll=-37.809969,144.963264 spn=-0.000018,-0.000014"
                                locationLabel:@"-37.809969, 144.963264"
                                accuracyLabel:[NSString stringWithFormat:@"%f", kCLLocationAccuracyBest]];
    
    // Execute
    [_formatter locationManager:nil didUpdateToLocation:location fromLocation:nil];
}

- (void)testUpdateToSameLocationDoesNotSendUpdateToDelegate
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
    [[_mockDelegate expect] locationFormatter:_formatter
                     didUpdateFormattedString:@"Location manager failed with error: Some error description"
                                locationLabel:@""
                                accuracyLabel:@""];
    

    // Execute
    [_formatter locationManager:nil didFailWithError:error];
}

- (void)testGoogleMapsUrl
{
    // Setup
    CLLocation * location = [self makeLocationWithLatitude:-37.80996889 longitude:144.96326388];
    
    // Execute
    NSURL * url = [_formatter googleMapsUrlForLocation:location];
    
    // Verify
    NSURL * expectedUrl = [NSURL URLWithString:
                           @"http://maps.google.com/maps?ll=-37.809969,144.963264&amp;spn=-0.000018,-0.000014"];
    STAssertEqualObjects(url, expectedUrl, nil);
}

@end
