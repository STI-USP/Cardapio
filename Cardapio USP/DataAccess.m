//
//  DataAccess.m
//  Cardapio USP
//
//  Created by Vagner Machado on 5/21/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import "DataAccess.h"
#import "SVProgressHUD.h"
#import "OAuthUSP.h"
#import "AFNetworking.h"
#import "MyMutableURLRequest.h"
#import "Constants.h"


#define kToken @"596df9effde6f877717b4e81fdb2ca9f"
#define kHash @"rcuectairldq2017"

@interface DataAccess () {
  OAuthUSP *oauth;
}

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation DataAccess

// Thread safe singleton - Grand Central Dispatch (GCD) solution (best!)
+ (DataAccess *)sharedInstance {
  // Aloca e inicializa objeto singleton.
  // Utiliza Grand Central Dispatch (GCD) para ser thread safe.
  static DataAccess *dataAccess = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ dataAccess = [[DataAccess alloc] init]; });
  return dataAccess;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    oauth = [OAuthUSP sharedInstance];
  }
  return self;
}

- (void)consultarSaldo {
    // Verifica se oauth e userData não são nil
    if (oauth == nil || oauth.userData == nil) {
        NSLog(@"Erro: oauth ou oauth.userData é nil.");
        [SVProgressHUD showErrorWithStatus:@"Erro de autenticação. Por favor, faça login novamente."];
        return;
    }

    // Recupera wsuserid
    NSString *wsuserid = [oauth.userData valueForKey:@"wsuserid"];
    if (wsuserid == nil) {
        NSLog(@"Erro: wsuserid é nil.");
        [SVProgressHUD showErrorWithStatus:@"Erro ao recuperar o identificador do usuário."];
        return;
    }

    // Configura parâmetros
    NSDictionary *parameters = @{
        @"token": wsuserid
    };
    
    NSError *error;
    NSData *params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    
    if (error) {
        NSLog(@"Erro ao serializar parâmetros: %@", error.localizedDescription);
        [SVProgressHUD showErrorWithStatus:@"Erro ao preparar os dados de solicitação."];
        return;
    }
    
    NSString *path = @"consultarSaldo";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseSTIURL, path]];
    
    // Cria a requisição
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPBody:params];
    
    // O restante do código permanece o mesmo...
}

- (void)createPix {
  // Obtém os valores necessários
  NSString *token = [oauth.userData valueForKey:@"wsuserid"];
  NSString *valorRecarga = [[_boletoDataModel valorRecarga] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString *hash = kHash;
  
  // Verifica se algum dos valores essenciais é nulo
  if (token == nil || valorRecarga == nil || hash == nil) {
    NSLog(@"Erro: Um ou mais valores obrigatórios estão nulos.");
    dispatch_async(dispatch_get_main_queue(), ^{
      [SVProgressHUD showErrorWithStatus:@"Erro interno. Tente novamente mais tarde."];
    });
    return;
  }
  
  // Configura parâmetros
  NSDictionary *parameters = @{
    @"hash": hash,
    @"token": token,
    @"valor": valorRecarga,
    @"tipoapp": @"APP"
  };
  
  // Serializa os parâmetros para o formato "application/x-www-form-urlencoded"
  NSString *bodyString = [self urlEncodedStringFromDictionary:parameters];
  NSData *params = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
  
  NSString *path = @"pixgerar";
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseSTIURL, path]];
  
  // Cria a requisição
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [urlRequest setHTTPBody:params];
  
  NSLog(@"URL: %@", url.absoluteString);
  NSLog(@"Body: %@", bodyString);
  
  // Cria a sessão e executa a requisição
  NSURLSessionDataTask *dataTask = [[self session] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      NSLog(@"Erro na requisição: %@", error.localizedDescription);
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
      });
      return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"Status Code: %ld", (long)httpResponse.statusCode);
    
    if (httpResponse.statusCode == 200 && data.length > 0) {
      NSError *jsonError;
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
      
      if (jsonError) {
        NSLog(@"Erro ao parsear JSON: %@", jsonError.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD showErrorWithStatus:@"Erro ao processar a resposta do servidor."];
        });
        return;
      }
      
      NSString *msgErro = json[@"msgErro"];
      if (msgErro && ![msgErro isEqualToString:@""]) {
        NSLog(@"Erro recebido: %@", msgErro);
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD showErrorWithStatus:msgErro];
        });
      } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          [self->_boletoDataModel setPix:[NSMutableDictionary dictionaryWithDictionary:json]];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreatePix" object:self];
        });
      }
    } else {
      NSLog(@"Resposta não esperada: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"Não foi possível gerar o código. Tente novamente mais tarde."];
      });
    }
  }];
  
  // Inicia a tarefa
  [dataTask resume];
}

- (void)checkPix:(NSString *)pixId {
  // Configura parâmetros
  NSDictionary *parameters = @{
    @"hash": kHash,
    @"idfpix": pixId
  };
  
  NSString *path = @"pixverificar";
  NSString *webServicePath = [NSString stringWithFormat:@"%@%@", kBaseSTIURL, path];
  
  // Configura a requisição
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webServicePath]];
  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  
  // Serializa os parâmetros para o formato de "application/x-www-form-urlencoded"
  NSString *bodyString = [self urlEncodedStringFromDictionary:parameters];
  [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
  
  // Cria uma sessão e faz a requisição
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (error) {
      NSLog(@"%@", error);
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
      });
      return;
    }
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode == 200) {
      NSError *jsonError;
      NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
      
      if (jsonError) {
        NSLog(@"Error deserializing JSON: %@", jsonError.localizedDescription);
        return;
      }
      
      NSString *status = json[@"situacao"];
      if (status && ![status isEqual:[NSNull null]]) {
        if ([status isEqualToString:@"CONCLUIDA"]) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Recebemos o pagamento!"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPaidPix" object:self];
          });
        } else {
          dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
          });
        }
      } else {
        dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD dismiss];
        });
      }
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:@"Não foi possível verificar o status do Pix. Tente novamente mais tarde."];
      });
    }
  }];
  
  [dataTask resume];
}

- (void)getBoletos {
  //configura parametros
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              [oauth.userData valueForKey:@"wsuserid"] , @"token",
                              nil];
  
  NSString *path = @"boletosEmAberto";
  NSData *params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kBaseSTIURL, path]];
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [urlRequest setHTTPBody:params];
  
  //Executa requisição
  NSURLSessionDataTask *dataTask = [[self session] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([data length] > 0 && error == nil) {
      if ([httpResponse statusCode] == 200) {
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if ([[json valueForKey:@"erro"] boolValue]) {
          [SVProgressHUD showErrorWithStatus:[json valueForKey:@"mensagemErro"]];
        } else {
          
          NSMutableArray *boletos = [[NSMutableArray alloc] init];
          for (NSMutableDictionary *boleto in [json objectForKey:@"boletos"]) {
            [boletos addObject:boleto];
          }
          [self->_boletoDataModel setBoletosPendentes:boletos];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveBills" object:self];
        }
      } else {
        [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o boleto. Tente novamente mais tarde."];
      }
    } else if (error) {
      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }
    
    // Notifica atualizações
    //[SVProgressHUD dismiss];
    
  }];
  
  [dataTask resume];
  
}


- (NSURLSession *)session {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Session Configuration
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Initialize Session
    _session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
  });
  return _session;
}

- (NSString *)urlEncodedStringFromDictionary:(NSDictionary *)dict {
  NSMutableArray *parts = [NSMutableArray array];
  for (NSString *key in dict) {
    NSString *encodedKey = [self urlEncode:key];
    NSString *encodedValue = [self urlEncode:[dict objectForKey:key]];
    NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
    [parts addObject:part];
  }
  return [parts componentsJoinedByString:@"&"];
}

- (NSString *)urlEncode:(NSString *)string {
    if ([string isKindOfClass:[NSString class]] && string.length > 0) {
        return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else {
        return @"";
    }
}


@end
