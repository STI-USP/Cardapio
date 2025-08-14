//
//  MenuViewModel.h
//  Cardapio USP
//
//  Created by Vagner Machado on 14/08/25.
//  Copyright © 2025 USP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModel;
@class Menu;

NS_ASSUME_NONNULL_BEGIN

@protocol MenuViewModelDelegate;

@interface MenuViewModel : NSObject

@property (nonatomic, weak) id<MenuViewModelDelegate> delegate;

/// Semana sempre com 7 elementos (SEG–DOM), já mesclada com o servidor.
@property (nonatomic, strong, readonly) NSArray<Menu *> *week;

/// Índice do dia selecionado (0=SEG ... 6=DOM).
@property (nonatomic, assign) NSInteger selectedIndex;

/// Títulos das tabs no formato “SEG\n14”, “TER\n15”, ...
@property (nonatomic, strong, readonly) NSArray<NSString *> *tabTitles;

/// Texto do cabeçalho do dia, ex.: “Quarta-feira, 14 de Agosto de 2025”
@property (nonatomic, copy, readonly) NSString *dayHeaderTitle;

/// Observação opcional vinda do DataModel (aparece como terceira seção).
@property (nonatomic, copy, readonly, nullable) NSString *observation;

- (instancetype)initWithDataModel:(DataModel *)dataModel;

/// Pede ao DataModel para buscar o menu (o resultado chega via notificação e o VM repassa por delegate).
- (void)reloadMenus;

/// Quantas sections da tabela (0=Almoço, 1=Jantar, 2=Observação se existir).
- (NSInteger)numberOfSections;

/// Texto para a célula em uma section (usa o dia selecionado).
- (NSString *)textForSection:(NSInteger)section;

/// Rodapé para a section (kcal), string vazia se não existir.
- (NSString *)footerForSection:(NSInteger)section;

/// Verdadeiro se almoço e jantar estiverem “Fechado”/vazio.
- (BOOL)isClosed;

@end

@protocol MenuViewModelDelegate <NSObject>
- (void)menuViewModelDidUpdateWeek:(MenuViewModel *)viewModel;   // quando a semana/títulos mudam
- (void)menuViewModelDidUpdateDay:(MenuViewModel *)viewModel;    // quando selectedIndex/dia mudam
- (void)menuViewModelNoServerMenu:(MenuViewModel *)viewModel;    // quando veio vazio do servidor
@end

NS_ASSUME_NONNULL_END
