//
//  MainViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 14/04/21.
//  Copyright © 2021 USP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController <SWRevealViewControllerDelegate>

//MenuView
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *restaurante;
@property (weak, nonatomic) IBOutlet UILabel *data;
@property (weak, nonatomic) IBOutlet UILabel *tipoRefeicao;
@property (weak, nonatomic) IBOutlet UILabel *cardapioAtual;
@property (weak, nonatomic) IBOutlet UILabel *saldo;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

//ExpandedMenuView
@property (weak, nonatomic) IBOutlet UIView *expandMenuView;
@property (weak, nonatomic) IBOutlet UILabel *restauranteExp;
@property (weak, nonatomic) IBOutlet UILabel *dataExp;
@property (weak, nonatomic) IBOutlet UILabel *tipoRefeicaoExp;
@property (weak, nonatomic) IBOutlet UILabel *cardapioAtualExp;
@property (weak, nonatomic) IBOutlet UILabel *saldoExp;
@property (weak, nonatomic) IBOutlet UIButton *menuButtonExp;


//botoes
@property (weak, nonatomic) IBOutlet UIButton *rucardButton;
@property (weak, nonatomic) IBOutlet UIButton *apoioButton;
@property (weak, nonatomic) IBOutlet UIButton *transporteButton;
@property (weak, nonatomic) IBOutlet UIButton *avisosButton;
@property (weak, nonatomic) IBOutlet UIButton *saudeMentalButton;
@property (weak, nonatomic) IBOutlet UIButton *moradiaButton;
@property (weak, nonatomic) IBOutlet UIButton *crecheButton;
@property (weak, nonatomic) IBOutlet UIButton *servicoSocialButton;
@property (weak, nonatomic) IBOutlet UIButton *acolheButton;


//label
@property (weak, nonatomic) IBOutlet UILabel *rucardLabel;
@property (weak, nonatomic) IBOutlet UILabel *apoioLabel;
@property (weak, nonatomic) IBOutlet UILabel *transporteLabel;
@property (weak, nonatomic) IBOutlet UILabel *avisosLabel;
@property (weak, nonatomic) IBOutlet UILabel *saudeMentalLabel;
@property (weak, nonatomic) IBOutlet UILabel *moradiaLabel;
@property (weak, nonatomic) IBOutlet UILabel *crecheLabel;
@property (weak, nonatomic) IBOutlet UILabel *servicoSocialLabel;
@property (weak, nonatomic) IBOutlet UILabel *acolheLabel;



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
