#import <XCTest/XCTest.h>
#import "DataModel.h"
#import "Menu.h"

@interface DMURLProtocol : NSURLProtocol
@end

static NSData *DMData;
static NSInteger DMStatus;
static NSError *DMError;
static NSInteger DMRequestCount;

@implementation DMURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
  return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
  return request;
}

- (void)startLoading {
  DMRequestCount++;
  if (DMError) {
    [self.client URLProtocol:self didFailWithError:DMError];
    return;
  }
  NSHTTPURLResponse *resp = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:DMStatus ?: 200 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type": @"application/json" }];
  
  NSData *data = DMData ?: [@"[]" dataUsingEncoding:NSUTF8StringEncoding];
  [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  [self.client URLProtocol:self didLoadData:data];
  [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {}

@end


@interface DataModelTests : XCTestCase

@property (nonatomic, strong) DataModel *model;

@end


@implementation DataModelTests

- (void)setUp {
  [super setUp];
  self.model = [DataModel getInstance];
  self.model.currentRestaurant = [@{ @"id": @"6" } mutableCopy];
  self.model.restaurants = nil;
  self.model.menuArray = nil;
  [NSUserDefaults.standardUserDefaults removeObjectForKey:@"Restaurants"];
  
  DMData = nil;
  DMError = nil;
  DMStatus = 200;
  DMRequestCount = 0;
  
  [NSURLProtocol registerClass:DMURLProtocol.class];
}

- (void)tearDown {
  [NSURLProtocol unregisterClass:DMURLProtocol.class];
  DMData = nil;
  DMError = nil;
  DMStatus = 200;
  DMRequestCount = 0;
  [super tearDown];
}

- (void)testGetRestaurantList_successNotifiesAndSetsCurrent {
  NSString *json = @"[{\"restaurants\": [{\"id\": 6, \"name\": \"Central\"}]}]";
  DMData = [json dataUsingEncoding:NSUTF8StringEncoding];
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveRestaurants" object:self.model handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.model getRestaurantList];
  
  [self waitForExpectations:@[notif] timeout:2.0];
  XCTAssertEqual(DMRequestCount, 1);
  XCTAssertNotNil(self.model.restaurants);
  XCTAssertEqualObjects([self.model.currentRestaurant valueForKey:@"id"], @6);
}

- (void)testGetRestaurantList_failureFallsBackToCache {
  NSArray *cached = @[ @{ @"restaurants": @[ @{ @"id": @42, @"name": @"Cache" } ] } ];
  [NSUserDefaults.standardUserDefaults setObject:cached forKey:@"Restaurants"];
  
  DMStatus = 500;
  DMData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveRestaurants" object:self.model handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.model getRestaurantList];
  
  [self waitForExpectations:@[notif] timeout:2.0];
  XCTAssertEqual(DMRequestCount, 1);
  XCTAssertEqualObjects(self.model.restaurants, cached);
}

- (void)testGetMenu_successParsesMealsAndObservation {
  self.model.currentRestaurant = [@{ @"id": @"6" } mutableCopy];
  NSString *json = @"{\"message\":{\"error\":false},\"meals\":[{\"date\":\"2025-01-01\",\"lunch\":{\"menu\":\"Arroz\",\"calories\":\"100\"}}],\"observation\":{\"observation\":\"obs\"}}";
  DMData = [json dataUsingEncoding:NSUTF8StringEncoding];
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveMenu" object:self.model handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.model getMenu];
  
  [self waitForExpectations:@[notif] timeout:2.0];
  XCTAssertEqual(self.model.menuArray.count, 1);
  XCTAssertTrue([[self.model.menuArray firstObject] isKindOfClass:[Menu class]]);
  XCTAssertEqualObjects(self.model.observation, @"obs");
}

- (void)testGetMenu_statusErrorStillNotifies {
  self.model.currentRestaurant = [@{ @"id": @"6" } mutableCopy];
  DMStatus = 500;
  DMData = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveMenu" object:self.model handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.model getMenu];
  
  [self waitForExpectations:@[notif] timeout:2.0];
  XCTAssertEqual(self.model.menuArray.count, 0);
}

#pragma mark - Smoke Tests (Critical Flows)

- (void)testF09_getRestaurantList_smokeTest {
  // F09: User loads restaurant list - critical flow for app initialization
  // This test verifies: API call -> JSON parse -> notification -> restaurants stored -> current restaurant set
  NSString *json = @"[{\"restaurants\": [{\"id\": 6, \"name\": \"Central\", \"address\": \"Rua do Lago\", \"phones\": \"3091-3536\", \"lat\": -23.56, \"lon\": -46.73, \"photourl\": \"https://uspdigital.usp.br/rucard/servlets/cardapio.central.jpg\"}]}]";
  DMData = [json dataUsingEncoding:NSUTF8StringEncoding];
  DMStatus = 200;
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveRestaurants" object:self.model handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.model getRestaurantList];
  
  [self waitForExpectations:@[notif] timeout:3.0];
  
  // Verify critical outcomes
  XCTAssertEqual(DMRequestCount, 1, @"Expected exactly one API request");
  XCTAssertNotNil(self.model.restaurants, @"Restaurants list must be populated");
  XCTAssertGreaterThan(self.model.restaurants.count, 0, @"At least one restaurant must be loaded");
  
  // Verify current restaurant is set (critical for subsequent menu operations)
  XCTAssertNotNil(self.model.currentRestaurant, @"Current restaurant must be set");
  XCTAssertEqualObjects([self.model.currentRestaurant valueForKey:@"id"], @6, @"Current restaurant ID must match first restaurant");
  
  // Verify restaurant data structure integrity (critical for map/detail views)
  NSDictionary *restaurant = [[self.model.restaurants firstObject] valueForKey:@"restaurants"][0];
  XCTAssertNotNil(restaurant[@"name"], @"Restaurant must have name");
  XCTAssertNotNil(restaurant[@"address"], @"Restaurant must have address");
  XCTAssertNotNil(restaurant[@"lat"], @"Restaurant must have latitude for maps");
  XCTAssertNotNil(restaurant[@"lon"], @"Restaurant must have longitude for maps");
}

@end
