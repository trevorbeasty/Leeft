//
//  TJBActiveRoutineExerciseItemVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineExerciseItemVC.h"

// table view cell

#import "TJBActiveRoutineGuidancePreviousEntryCell.h"
#import "TJBDetailTitleCell.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBActiveRoutineExerciseItemVC () <UITableViewDelegate, UITableViewDataSource>

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *titleExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRepsLabel;
@property (weak, nonatomic) IBOutlet UITableView *previousEntriesTableView;
@property (weak, nonatomic) IBOutlet UILabel *previousEntriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLabel1;
@property (weak, nonatomic) IBOutlet UILabel *thinLabel2;

// core

@property (nonatomic, strong) NSString *titleNumber;
@property (nonatomic, strong) NSString *targetExerciseName;
@property (nonatomic, strong) NSString *targetWeight;
@property (nonatomic, strong) NSString *targetReps;
@property (nonatomic, strong) NSArray<NSArray *> *previousEntries;


@end

@implementation TJBActiveRoutineExerciseItemVC

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSString *)titleNumber targetExerciseName:(NSString *)targetExerciseName targetWeight:(NSString *)targetWeight targetReps:(NSString *)targetReps previousEntries:(NSArray *)previousEntries{
    
    self = [super init];
    
    self.titleNumber = titleNumber;
    self.targetExerciseName = targetExerciseName;
    self.targetWeight = targetWeight;
    self.targetReps = targetReps;
    self.previousEntries = previousEntries;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewData];
    
    [self configureTableView];
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // title labels
    
    NSArray *titleLabels = @[self.titleExerciseLabel, self.targetWeightLabel, self.targetRepsLabel];
    for (UILabel *lab in titleLabels){
        
        lab.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        lab.textColor = [UIColor blackColor];
        lab.font = [UIFont systemFontOfSize: 20];
        
    }
    
    self.titleExerciseLabel.font = [UIFont boldSystemFontOfSize: 25];
    
    // table view
    
    CALayer *prTVLayer = self.previousEntriesTableView.layer;
    prTVLayer.borderColor = [UIColor blackColor].CGColor;
    prTVLayer.borderWidth = .5;
    prTVLayer.masksToBounds = YES;
    prTVLayer.cornerRadius = 4.0;
    
    // targets label
    
    self.previousEntriesLabel.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.previousEntriesLabel.font = [UIFont systemFontOfSize: 15];
    self.previousEntriesLabel.textColor = [UIColor blackColor];
    
    // thin label
    
    NSArray *thinLabels = @[self.thinLabel1, self.thinLabel2];
    for (UILabel *lab in thinLabels){
        
        lab.text = @"";
        lab.backgroundColor = [UIColor blackColor];
        
    }
    
}

- (void)configureViewData{
    
    // target labels and exercise title
    
    NSString *targetWeightText = [NSString stringWithFormat: @"%@ lbs", self.targetWeight];
    NSString *targetRepsText = [NSString stringWithFormat: @"%@ reps", self.targetReps];
    
    self.titleExerciseLabel.text = [NSString stringWithFormat: @"%@. %@",
                                    self.titleNumber,
                                    self.targetExerciseName];
                                     
    self.targetWeightLabel.text = targetWeightText;
    self.targetRepsLabel.text = targetRepsText;
    
}

static NSString * previousEntryCellID = @"previousEntryCell";

- (void)configureTableView{
    
    // functionality
    
    UINib *previousEntryCell = [UINib nibWithNibName: @"TJBActiveRoutineGuidancePreviousEntryCell"
                                              bundle: nil];
    
    [self.previousEntriesTableView registerNib: previousEntryCell
                        forCellReuseIdentifier: previousEntryCellID];
    
    UINib *titleCell = [UINib nibWithNibName: @"TJBDetailTitleCell"
                                      bundle: nil];
    
    [self.previousEntriesTableView registerNib: titleCell
                        forCellReuseIdentifier: @"TJBDetailTitleCell"];
    
    self.previousEntriesTableView.scrollEnabled = NO;
    
    // aesthetics
    
    self.previousEntriesTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        
        return 80;
        
    } else{
        
        return 30;
        
    }
    
    
}




#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.previousEntries.count > 0){
        
        return self.previousEntries.count + 1;
        
    } else{
        
        return 2;
        
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        
        TJBDetailTitleCell *cell = [self.previousEntriesTableView dequeueReusableCellWithIdentifier: @"TJBDetailTitleCell"];
        
        cell.titleLabel.text = @"Previous Entries";
        cell.detail1Label.text = @"date";
        cell.detail2Label.text = @"weight (lbs)";
        cell.detail3Label.text = @"reps";
        cell.subtitleLabel.text = @"";
        
        NSArray *labels = @[cell.detail1Label, cell.detail2Label, cell.detail3Label];
        for (UILabel *lab in labels){
            
            lab.font = [UIFont systemFontOfSize: 15];
            lab.textColor = [UIColor blackColor];
            lab.backgroundColor = [UIColor clearColor];
            
        }
        
        cell.titleLabel.font = [UIFont systemFontOfSize: 15];
        cell.titleLabel.textColor = [UIColor blackColor];
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
        
    } else{
        
        // in the array, the order of objects is as follows: weight, reps, date created
        
        TJBActiveRoutineGuidancePreviousEntryCell *cell = [self.previousEntriesTableView dequeueReusableCellWithIdentifier: previousEntryCellID];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // give the cell the correct data
        
        NSArray *data = self.previousEntries[indexPath.row - 1];
        
        [cell configureWithDate: data[2]
                         weight: data[0]
                           reps: data[1]];
        
        return cell;
        
    }
    
    

    
}


@end


















































