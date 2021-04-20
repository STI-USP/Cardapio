//
//  MainViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 14/04/21.
//  Copyright © 2021 USP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *restaurante;
@property (weak, nonatomic) IBOutlet UILabel *data;
@property (weak, nonatomic) IBOutlet UILabel *tipoRefeicao;
@property (weak, nonatomic) IBOutlet UILabel *cardapioAtual;
@property (weak, nonatomic) IBOutlet UILabel *saldo;

- (IBAction)showInstitucional:(id)sender;
- (IBAction)showTransporte:(id)sender;
- (IBAction)showAvisos:(id)sender;
- (IBAction)showSaudeMental:(id)sender;
- (IBAction)showMoradia:(id)sender;
- (IBAction)showCreche:(id)sender;
- (IBAction)showServicoSocial:(id)sender;
- (IBAction)showAcolhe:(id)sender;
@end

NS_ASSUME_NONNULL_END
