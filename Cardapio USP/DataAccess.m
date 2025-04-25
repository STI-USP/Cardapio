//
//  DataAccess.m
//  Cardapio USP
//
//  Refatorado em 16/04/25 por Vagner Machado
//

#import "DataAccess.h"
#import "SVProgressHUD.h"
#import "OAuthUSP.h"
#import "Constants.h"

@import FirebasePerformance;

static NSString * const kHash  = @"rcuectairldq2017";
static NSString * const kPathConsultarSaldo  = @"consultarSaldo";
static NSString * const kPathPixGerar        = @"pixgerar";
static NSString * const kPathPixListar       = @"pixlistar";
static NSString * const kPathPixVerificar    = @"pixverificar";
static NSString * const kPathBoletosEmAberto = @"boletosEmAberto";

typedef NS_ENUM(NSUInteger, DAContentType) { DAContentTypeJSON, DAContentTypeForm };
typedef void (^DAJSONCompletion)(NSDictionary *json, NSError *error);

@interface DataAccess () {
  OAuthUSP *oauth;
}
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation DataAccess
#pragma mark - Singleton & Init
+ (instancetype)sharedInstance {
  static DataAccess *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
  return instance;
}

- (instancetype)init {
  if ((self = [super init])) {
    oauth = [OAuthUSP sharedInstance];
  }
  return self;
}

#pragma mark - API Públicas
- (void)consultarSaldo {
  NSString *token = oauth.userData[@"wsuserid"];
  if (!token) { [self showAuthError]; return; }
  
  [self POST:kPathConsultarSaldo parameters:@{@"token":token} contentType:DAContentTypeJSON completion:^(NSDictionary *json, NSError *error) {
    if (error) {
      [self handleNetworkError:error
                  fallbackText:@"Não foi possível obter o saldo. Tente novamente mais tarde."
                   creditValue:@"--,--"];
      return;
    }
    
    if ([json[@"erro"] boolValue]) {
      [self handleServerError:json
                  creditValue:@"--,--"
              loginErrorNotif:@"DidReceiveLoginError"];
    } else {
      self->_dataModel.ruCardCredit = json[@"saldo"];
      [SVProgressHUD dismiss];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveCredits" object:self];
    }
  }];
}

- (void)createPix {
  NSString *token = oauth.userData[@"wsuserid"];
  NSString *valor = [_boletoDataModel.valorRecarga stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
  if (!token || !valor) { [self showGenericInternalError]; return; }
  
  NSDictionary *params = @{@"hash":kHash, @"token":token, @"valor":valor, @"tipoapp":@"APP"};
  [self POST:kPathPixGerar parameters:params contentType:DAContentTypeForm completion:^(NSDictionary *json, NSError *error) {
    if (error) {
      [self handleNetworkError:error fallbackText:nil creditValue:nil]; return;
    }
    
    NSString *msgErro = json[@"msgErro"];
    if (msgErro.length) {
      [SVProgressHUD showErrorWithStatus:msgErro];
    } else {
      self->_boletoDataModel.pix = [json mutableCopy];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreatePix" object:self];
    }
  }];
}

- (void)getLastPix {
  NSString *token = oauth.userData[@"wsuserid"];
  if (!token) { [self showAuthError]; return; }
  
  NSDictionary *params = @{ @"hash": kHash, @"token": token };
  
  [self POST:kPathPixListar parameters:params contentType:DAContentTypeForm completion:^(id jsonObj, NSError *error) {
    
    if (error) { [self handleNetworkError:error fallbackText:nil creditValue:nil]; return; }
    
    /* ▸ o serviço já devolve UM único Pix; se vier array, pega o primeiro */
    NSDictionary *pix = nil;
    if ([jsonObj isKindOfClass:[NSArray class]]) {
      pix = ((NSArray *)jsonObj).firstObject;
    } else if ([jsonObj isKindOfClass:[NSDictionary class]]) {
      pix = (NSDictionary *)jsonObj;
    }
    if (!pix) { [SVProgressHUD dismiss]; return; }
    
    [self->_boletoDataModel setPix:[pix mutableCopy]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveLastPix" object:self];
  }];
}

- (void)checkPix:(NSString *)pixId {
  NSDictionary *params = @{@"hash":kHash, @"idfpix":pixId ?: @""};
  [self POST:kPathPixVerificar parameters:params contentType:DAContentTypeForm completion:^(NSDictionary *json, NSError *error) {
    if (error) { [self handleNetworkError:error fallbackText:nil creditValue:nil]; return; }
    
    NSString *situacao = json[@"situacao"];
    if ([situacao isEqualToString:@"CONCLUIDA"]) {
      [SVProgressHUD showSuccessWithStatus:@"Recebemos o pagamento!"];
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPaidPix" object:self];
    } else {
      [SVProgressHUD dismiss];
    }
  }];
}

- (void)getBoletos {
  NSString *token = oauth.userData[@"wsuserid"];
  if (!token) { [self showAuthError]; return; }
  
  [self POST:kPathBoletosEmAberto parameters:@{@"token":token} contentType:DAContentTypeJSON completion:^(NSDictionary *json, NSError *error) {
    if (error) { [self handleNetworkError:error fallbackText:@"Não foi possível obter o boleto. Tente novamente mais tarde." creditValue:nil]; return; }
    
    if ([json[@"erro"] boolValue]) {
      [SVProgressHUD showErrorWithStatus:json[@"mensagemErro"]];
    } else {
      NSMutableArray *boletos = [json[@"boletos"] mutableCopy] ?: @[].mutableCopy;
      self->_boletoDataModel.boletosPendentes = boletos;
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveBills" object:self];
    }
  }];
}

#pragma mark - Helpers de Rede
- (void)POST:(NSString *)path parameters:(NSDictionary *)parameters contentType:(DAContentType)type completion:(DAJSONCompletion)completion {
  
  FIRTrace *trace = [FIRPerformance startTraceWithName:@"post_request_trace"];
  [trace setValue:path forAttribute:@"path"];
  
  NSURL *url = [NSURL URLWithString:[kBaseSTIURL stringByAppendingString:path]];
  NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
  req.HTTPMethod = @"POST";
  
  if (type == DAContentTypeJSON) {
    req.allHTTPHeaderFields = @{@"Content-Type":@"application/json"};
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
  } else {
    req.allHTTPHeaderFields = @{@"Content-Type":@"application/x-www-form-urlencoded"};
    req.HTTPBody = [[self urlEncodedStringFromDictionary:parameters] dataUsingEncoding:NSUTF8StringEncoding];
  }
  
  
  NSURLSessionDataTask *task =
  [self.session dataTaskWithRequest:req completionHandler:^(NSData *data,
                                                            NSURLResponse *resp,
                                                            NSError *error) {
    
    [trace stop];
    
    if (error) {
      [trace setValue:@"error" forAttribute:@"status"];
      completion(nil, error);
      return;
    }
    
    NSHTTPURLResponse *http = (NSHTTPURLResponse *)resp;
    NSLog(@"🛰️  %@ %@ — status: %ld", req.HTTPMethod, url.absoluteString, (long)http.statusCode);
    NSLog(@"➡️  Enviado: %@", [[NSString alloc] initWithData:req.HTTPBody encoding:NSUTF8StringEncoding]);
    NSLog(@"⬅️  Headers: %@", http.allHeaderFields);
    NSLog(@"⬅️  Corpo: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    if (http.statusCode != 200 || !data.length) {
      
      [trace setValue:@"failure" forAttribute:@"status"];

      NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:http.statusCode userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP %ld", (long)http.statusCode]}];
      completion(nil, e);

      return;
    }
    
    [trace setValue:@"success" forAttribute:@"status"];

    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
    completion(json, jsonError);
  }];
  [task resume];
}

#pragma mark - Tratamento de Erro e Utilidades
- (void)handleNetworkError:(NSError *)error fallbackText:(NSString *)text creditValue:(NSString *)credit {
  dispatch_async(dispatch_get_main_queue(), ^{
    [SVProgressHUD showErrorWithStatus:(error.localizedDescription ?: text)];
    if (credit) self->_dataModel.ruCardCredit = credit;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveCredits" object:self];
  });
}

- (void)handleServerError:(NSDictionary *)json creditValue:(NSString *)credit loginErrorNotif:(NSString *)notifName {
  dispatch_async(dispatch_get_main_queue(), ^{
    self->_dataModel.ruCardCredit = credit;
    [SVProgressHUD showErrorWithStatus:json[@"mensagemErro"]];
    if ([json[@"mensagemErro"] isEqualToString:@"Usuário não está logado!"]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:notifName object:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveCredits" object:self];
  });
}

- (void)showAuthError { [SVProgressHUD showErrorWithStatus:@"Não foi possível verificar o usuário. Faça login novamente."]; }
- (void)showGenericInternalError { [SVProgressHUD showErrorWithStatus:@"Erro interno. Tente novamente mais tarde."]; }

- (NSURLSession *)session {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSURLSessionConfiguration *config = NSURLSessionConfiguration.defaultSessionConfiguration;
    _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:NSOperationQueue.mainQueue];
  });
  return _session;
}

#pragma mark - URL Encoding
- (NSString *)urlEncodedStringFromDictionary:(NSDictionary *)dict {
  NSMutableArray *pairs = [NSMutableArray array];
  [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
    NSString *k = [self urlEncode:key];
    NSString *v = [self urlEncode:[obj description]];
    [pairs addObject:[NSString stringWithFormat:@"%@=%@", k, v]];
  }];
  return [pairs componentsJoinedByString:@"&"];
}

- (NSString *)urlEncode:(NSString *)string {
  return [string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet] ?: @"";
}
@end
