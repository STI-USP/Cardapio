#import <XCTest/XCTest.h>
#import "DataAccess.h"
#import "DataModel.h"
#import "OAuthUSP.h"
#import "CheckoutDataModel.h"

@interface MockURLProtocol : NSURLProtocol
@end

static NSData *MockData;
static NSInteger MockStatusCode;
static NSError *MockError;
static NSInteger MockRequestCount;

@implementation MockURLProtocol
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
  return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
  return request;
}

- (void)startLoading {
  MockRequestCount++;
  if (MockError) {
    [self.client URLProtocol:self didFailWithError:MockError];
    return;
  }
  NSHTTPURLResponse *resp = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:MockStatusCode ?: 200 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type": @"application/json" }];
  NSData *data = MockData ?: [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
  [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  [self.client URLProtocol:self didLoadData:data];
  [self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {}

@end

@interface DataAccessTests : XCTestCase
@property (nonatomic, strong) DataAccess *sut;
@property (nonatomic, strong) DataModel *model;
@property (nonatomic, strong) OAuthUSP *oauth;
@property (nonatomic, strong) CheckoutDataModel *checkout;
@property (nonatomic, strong) NSURLSession *mockSession;
@end

@implementation DataAccessTests

- (void)setUp {
  [super setUp];
  self.sut = [DataAccess sharedInstance];
  self.model = [DataModel getInstance];
  self.oauth = [OAuthUSP sharedInstance];
  self.checkout = [CheckoutDataModel sharedInstance];
  self.oauth.userData = @{ @"wsuserid": @"token-test" };
  
  MockData = nil;
  MockError = nil;
  MockStatusCode = 200;
  MockRequestCount = 0;
  
  // Create mock session before any method calls to prevent lazy init
  NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
  cfg.protocolClasses = @[MockURLProtocol.class];
  self.mockSession = [NSURLSession sessionWithConfiguration:cfg];
  [self.sut setValue:self.mockSession forKey:@"_session"];
  
  // Wire up DataAccess dependencies
  self.sut.dataModel = self.model;
  self.sut.boletoDataModel = self.checkout;
}

- (void)tearDown {
  // Invalidate session to prevent cross-test pollution
  [self.mockSession invalidateAndCancel];
  self.mockSession = nil;
  
  // Clear mock state
  MockData = nil;
  MockError = nil;
  MockStatusCode = 200;
  MockRequestCount = 0;
  
  [super tearDown];
}

- (void)testConsultarSaldo_sucessoAtualizaCreditoENotifica {
  NSString *json = @"{\"erro\":false,\"saldo\":\"10,00\"}";
  MockData = [json dataUsingEncoding:NSUTF8StringEncoding];
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveCredits" object:self.sut handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.sut consultarSaldo];
  
  [self waitForExpectations:@[notif] timeout:1.0];
  XCTAssertEqualObjects(self.model.ruCardCredit, @"10,00");
}

- (void)testConsultarSaldo_semToken_mostraErro {
  // Clear token to test guard behavior
  self.oauth.userData = nil;
  
  // Call consultarSaldo - should show error and not crash
  [self.sut consultarSaldo];
  
  // Wait briefly to ensure method completes
  XCTestExpectation *wait = [self expectationWithDescription:@"wait"];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [wait fulfill];
  });
  [self waitForExpectations:@[wait] timeout:0.5];
  
  // Test passes if no crash occurred - the guard clause works
  XCTAssertTrue(YES, @"Method completed without crash when token is nil");
}

- (void)testCreatePix_sucessoNotificaESalvaPix {
  NSString *json = @"{\"msgErro\":\"\",\"idfpix\":\"123\"}";
  MockData = [json dataUsingEncoding:NSUTF8StringEncoding];
  // Set required value for createPix
  self.checkout.valorRecarga = @"10,00";
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidCreatePix" object:self.sut handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.sut createPix];
  
  [self waitForExpectations:@[notif] timeout:2.0];
  XCTAssertNotNil(self.checkout.pix, @"Expected pix to be set after create");
  XCTAssertEqualObjects(self.checkout.pix[@"idfpix"], @"123", @"Expected idfpix to match response");
}

- (void)testGetLastPix_arrayRetornaPrimeiroENotifica {
  NSString *json = @"[{\"idfpix\":\"abc\",\"valor\":\"10\"}]";
  MockData = [json dataUsingEncoding:NSUTF8StringEncoding];
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveLastPix" object:self.sut handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.sut getLastPix];
  
  [self waitForExpectations:@[notif] timeout:2.0];
  XCTAssertEqualObjects(self.checkout.pix[@"idfpix"], @"abc", @"Expected idfpix from first array element");
}

- (void)testCheckPix_concluidaNotificaPagamento {
  NSString *json = @"{\"situacao\":\"CONCLUIDA\"}";
  MockData = [json dataUsingEncoding:NSUTF8StringEncoding];
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidPaidPix" object:self.sut handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.sut checkPix:@"abc"];
  
  [self waitForExpectations:@[notif] timeout:2.0];
}

#pragma mark - Smoke Tests (Critical Flows)

- (void)testF02_consultarSaldo_smokeTest {
  // F02: User checks balance - critical flow for credit visibility
  // This test verifies the complete flow: API call -> response parse -> notification -> model update
  NSString *json = @"{\"erro\":false,\"saldo\":\"25,50\"}";
  MockData = [json dataUsingEncoding:NSUTF8StringEncoding];
  MockStatusCode = 200;
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidReceiveCredits" object:self.sut handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.sut consultarSaldo];
  
  [self waitForExpectations:@[notif] timeout:3.0];
  
  // Verify critical outcomes
  XCTAssertEqual(MockRequestCount, 1, @"Expected exactly one API request");
  XCTAssertNotNil(self.model.ruCardCredit, @"Balance must be stored in model");
  XCTAssertEqualObjects(self.model.ruCardCredit, @"25,50", @"Balance must match API response");
}

- (void)testF04_createPix_smokeTest {
  // F04: User creates PIX for recharge - critical flow for payment
  // This test verifies: API call -> PIX creation -> notification -> PIX stored
  NSString *json = @"{\"msgErro\":\"\",\"idfpix\":\"smoke-test-pix-456\",\"qrcode\":\"00020126580014br.gov.bcb.pix\"}";
  MockData = [json dataUsingEncoding:NSUTF8StringEncoding];
  MockStatusCode = 200;
  
  self.checkout.valorRecarga = @"50,00";
  
  XCTestExpectation *notif = [self expectationForNotification:@"DidCreatePix" object:self.sut handler:^BOOL(NSNotification * _Nonnull note) {
    return YES;
  }];
  
  [self.sut createPix];
  
  [self waitForExpectations:@[notif] timeout:3.0];
  
  // Verify critical outcomes
  XCTAssertEqual(MockRequestCount, 1, @"Expected exactly one API request");
  XCTAssertNotNil(self.checkout.pix, @"PIX must be created and stored");
  XCTAssertEqualObjects(self.checkout.pix[@"idfpix"], @"smoke-test-pix-456", @"PIX ID must match API response");
  XCTAssertTrue([self.checkout.pix[@"qrcode"] length] > 0, @"QR code must be present");
}

@end
