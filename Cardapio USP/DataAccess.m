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

#define kBaseSTIURL @"https://dev.uspdigital.usp.br/mobile/servicos/cardapio/" //dev
//#define kBaseSTIURL @"https://uspdigital.usp.br/mobile/servicos/cardapio/" //prod

#define kToken @"596df9effde6f877717b4e81fdb2ca9f"


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

- (void)getBoleto {

  //configura parametros
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              [oauth.userData valueForKey:@"wsuserid"] , @"token",
                              nil];
  
  NSString *path = @"visualizarUltimoBoleto";
  NSData* params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
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
          [_boletoDataModel setBoleto:[NSMutableDictionary dictionaryWithDictionary:json]];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveBill" object:self];
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


- (void)getBoletos {
  [SVProgressHUD show];

  //configura parametros
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              [oauth.userData valueForKey:@"wsuserid"] , @"token",
                              nil];
  
  NSString *path = @"boletosEmAberto";
  NSData* params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
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
          [_boletoDataModel setBoletosPendentes:boletos];
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

- (void)createBill {
  [SVProgressHUD show];
  
  //configura parametros
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              [oauth.userData valueForKey:@"wsuserid"] , @"token",
                              [[[[_boletoDataModel valorRecarga] stringByReplacingOccurrencesOfString:@"R" withString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@","], @"valor",
                              nil];
  
  NSString *path = @"gerarBoleto";
  NSData* params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
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
          [_boletoDataModel setBoleto:[NSMutableDictionary dictionaryWithDictionary:json]];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"DidCreateBill" object:self];
        }
      } else {
        [SVProgressHUD showErrorWithStatus:@"Não foi possível gerar o boleto. Tente novamente mais tarde."];
      }
    } else if (error) {
      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }
    
    // Notifica atualizações
    //[SVProgressHUD dismiss];
    
  }];
  
  [dataTask resume];
}

- (void)deleteBill {
  [SVProgressHUD show];
  
  //configura parametros
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              [oauth.userData valueForKey:@"wsuserid"] , @"token",
                              [_boletoDataModel.boleto valueForKey:@"id"], @"id",
                              nil];
  
  NSString *path = @"cancelarBoleto";
  NSData* params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
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
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if ([[json valueForKey:@"erro"] boolValue]) {
          [SVProgressHUD showErrorWithStatus:[json valueForKey:@"mensagemErro"]];
        }
      } else {
        [SVProgressHUD showErrorWithStatus:@"Não foi possível apagar o boleto. Tente novamente mais tarde."];
      }
    } else if (error) {
      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidDeleteBill" object:self];

  }];
  
  [dataTask resume];
}


- (void)consultarSaldo {
  //configura parametros
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                              [oauth.userData valueForKey:@"wsuserid"] , @"token",
                              nil];
  
  NSString *path = @"consultarSaldo";
  NSData* params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
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
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if ([[json valueForKey:@"erro"] boolValue]) {
          [_dataModel setRuCardCredit:@"--,--"];
          [SVProgressHUD showErrorWithStatus:[json valueForKey:@"mensagemErro"]];

          if ([[json valueForKey:@"mensagemErro"] isEqualToString:@"Usuário não está logado!"])
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveLoginError" object:self];

        } else {
          [_dataModel setRuCardCredit:[json valueForKey:@"saldo"]];
          [SVProgressHUD dismiss];
        }
      } else {
        [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o saldo. Tente novamente mais tarde."];
        [_dataModel setRuCardCredit:@"--,--"];
      }
    } else if (error) {
      [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
      [_dataModel setRuCardCredit:@"--,--"];
    }

    // Notifica atualizações
    //[SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveCredits" object:self];
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

@end
