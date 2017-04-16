//
//  TJBRealizedChainCell.h
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBMasterCell.h"

// core data

#import "CoreDataController.h"


typedef enum{
    RealizedSetCollectionCell,
    ChainTemplateAdvCell,
    RealizedChainCell
}TJBAdvancedCellType;

typedef enum{
    TJBDayInYear,
    TJBTimeOfDay,
    TJBMaxDetailDate
}TJBDateTimeType;

@interface TJBRealizedChainCell : TJBMasterCell



- (void)configureWithContentObject:(id)contentObject cellType:(TJBAdvancedCellType)cellType dateTimeType:(TJBDateTimeType)dateTimeType titleNumber:(NSNumber *)titleNumber;

#pragma mark - API

+ (float)suggestedCellHeightForRealizedChain:(TJBRealizedChain *)realizedChain;
+ (float)suggestedCellHeightForChainTemplate:(TJBChainTemplate *)chainTemplate;
+ (float)suggestedHeightForRealizedSet;
+ (float)suggestedHeightForRealizedSetGrouping:(TJBRealizedSetGrouping)rsg;

- (void)clearExistingEntries;


- (void)updateTitleNumber:(NSNumber *)number;

@end














