//
//  TJBExerciseHistoryVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseHistoryVC.h"

// core data

#import "CoreDataController.h"

// table view cells

#import "TJBRealizedSetCell.h"
#import "TJBRealizedChainCell.h"
#import "TJBWorkoutLogTitleCell.h"
#import "TJBNoDataCell.h"
#import "TJBRealizedSetCollectionCell.h"
#import "TJBMasterCell.h"






@interface TJBExerciseHistoryVC () <UITableViewDelegate, UITableViewDataSource>



// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *titleBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// core

@property (strong) TJBExercise *exercise;
@property (strong) NSArray *sortedContent;

// optimization

@property (strong) NSCalendar *calendar;

@end



typedef NSArray<TJBRealizedSet *> *TJBRealizedSetGrouping;





@implementation TJBExerciseHistoryVC


#pragma mark - Instantiation




#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self viewAesthetics];
    
}




#pragma mark - View Helper Methods

- (void)configureTableView{
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *realizedSetNib = [UINib nibWithNibName: @"TJBRealizedSetCell"
                                           bundle: nil];
    
    [self.tableView registerNib: realizedSetNib
         forCellReuseIdentifier: @"TJBRealizedSetCell"];
    
    UINib *realizedChainNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                             bundle: nil];
    
    [self.tableView registerNib: realizedChainNib
         forCellReuseIdentifier: @"TJBRealizedChainCell"];
    
    UINib *titleCellNib = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                         bundle: nil];
    
    [self.tableView registerNib: titleCellNib
         forCellReuseIdentifier: @"TJBWorkoutLogTitleCell"];
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                       bundle: nil];
    
    [self.tableView registerNib: noDataCell
         forCellReuseIdentifier: @"TJBNoDataCell"];
    
    UINib *realizedSetCollectionCell = [UINib nibWithNibName: @"TJBRealizedSetCollectionCell"
                                                      bundle: nil];
    
    [self.tableView registerNib: realizedSetCollectionCell
         forCellReuseIdentifier: @"TJBRealizedSetCollectionCell"];
    
}


- (void)viewAesthetics{
    
    
    
}

#pragma mark - Content Derivation

- (void)deriveContentForActiveExercise{
    
    NSMutableArray *collector = [[NSMutableArray alloc] init];
    
    // collect all relevant TJBRealizedSets and TJBRealizedChains
    
    for (TJBRealizedSet *set in self.exercise.realizedSets){
        
        [collector addObject: set];
        
    }
    
    for (TJBChainTemplate *ct in self.exercise.chainTemplates){
        
        for (TJBRealizedChain *rc in ct.realizedChains){
            
            [collector addObject: rc];
            
        }
        
    }
    
    // sort all collected items by date in descending order
    
    [collector sortUsingComparator: ^(id obj1, id obj2){
        
        NSDate *date1 = [self dateForObject: obj1];
        NSDate *date2 = [self dateForObject: obj2];
        
        NSTimeInterval diff = [date1 timeIntervalSinceDate: date2];
        
        if (diff > 0){
            
            return NSOrderedAscending;
            
        } else{
            
            return NSOrderedDescending;
            
        }
        
    }];
    
    // group adjacent realized sets from the same day together
    
    NSMutableArray *collector2 = [[NSMutableArray alloc] init];
    
    NSInteger groupSize = 1;
    
    NSInteger limit = collector.count;
    for (NSInteger i = 0; i < limit - 1; i++){
        
        id obj1 = collector[i];
        id obj2 = collector[i + 1];
        
        BOOL objectsAreRealizedSetsOfSameDay = [self objectsAreRealizedSetsOfSameDay_obj1: obj1
                                                                                     obj2: obj2];
        
        if (i == limit - 2){
            
            // different logic must be applied for the last two objects, otherwise the last object will not be added
            
            if (objectsAreRealizedSetsOfSameDay){
                
                groupSize += 1;
                
                id object = [self objectForSourceArray: collector
                                     iterationPosition: i + 1
                                             groupSize: groupSize];
                
                [collector2 addObject: object];
                
                break;
                
            } else{
                
                id object1 = [self objectForSourceArray: collector
                                     iterationPosition: i
                                             groupSize: groupSize];
                
                id object2 = [self objectForSourceArray: collector
                                      iterationPosition: i + 1
                                              groupSize: 1];
                
                [collector2 addObject: object1];
                [collector2 addObject: object2];
                
                break;
                
            }
            
            
        } else{
            
            if (objectsAreRealizedSetsOfSameDay){
                
                groupSize += 1;
                continue;
                
            } else{
                
                id object = [self objectForSourceArray: collector
                                     iterationPosition: i
                                             groupSize: groupSize];
                
                [collector2 addObject: object];
                
                groupSize = 1;
                
                continue;
                
            }
        }
    }
    
    self.sortedContent = collector2;
    
}

- (id)objectForSourceArray:(NSArray *)array iterationPosition:(NSInteger)iterationPosition groupSize:(NSInteger)groupSize{
    
    if (groupSize > 1){
        
        NSMutableArray *collector = [[NSMutableArray alloc] init];
        
        for (NSInteger i = iterationPosition - (groupSize - 1); i <= iterationPosition; i++){
            
            [collector addObject: array[iterationPosition + i]];
            
        }
        
        TJBRealizedSetGrouping rsg = [NSArray arrayWithArray: collector];
        return rsg;
        
    } else{
        
        return array[iterationPosition];
        
    }
    
}

- (NSDate *)dateForObject:(id)object{
    
    if ([object isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = object;
        return rs.submissionTime;
        
    } else if ([object isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = object;
        return  rc.dateCreated;
        
    } else{
        
        return nil;
        
    }
    
}

- (BOOL)objectsAreRealizedSetsOfSameDay_obj1:(id)obj1 obj2:(id)obj2{
    
    BOOL obj1IsRealizedSet = [self objectIsRealizedSet: obj1];
    BOOL obj2IsRealizedSet = [self objectIsRealizedSet: obj2];
    
    if (obj1IsRealizedSet && obj2IsRealizedSet){
        
        if (!self.calendar){
            
            self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            
        }
        
        TJBRealizedSet *rs1 = obj1;
        TJBRealizedSet *rs2 = obj2;
        
        return [self.calendar isDate: rs1.submissionTime
                     inSameDayAsDate: rs2.submissionTime];
        
    } else{
        
        return NO;
        
    }
    
}

- (BOOL)objectIsRealizedSet:(id)obj{
    
    return [obj isKindOfClass: [TJBRealizedSet class]];
    
}



#pragma mark - TJBExerciseHistoryProtocol

- (void)activeExerciseDidUpdate:(TJBExercise *)exercise{
    
    self.exercise = exercise;
    
    [self deriveContentForActiveExercise];
    
    [self.tableView reloadData];
    
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.sortedContent.count == 0){
        
        return 2;
        
    } else{
        
        return self.sortedContent.count + 1;
        
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == 0){
        
        TJBWorkoutLogTitleCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBWorkoutLogTitleCell"];
        
        cell.referenceIndexPath = indexPath;
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        
        cell.secondaryLabel.text = @"";
        cell.primaryLabel.text = @"My Workout Log";
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    } else{
        
        if (self.sortedContent.count == 0){
            
            TJBNoDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Entries";
            cell.backgroundColor = [UIColor clearColor];
            cell.referenceIndexPath = indexPath;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        } else{
            
            NSNumber *number = [NSNumber numberWithInteger: indexPath.row];
            
            int rowIndex = (int)indexPath.row - 1;
            
            BOOL isRealizedSet = [self.sortedContent[rowIndex] isKindOfClass: [TJBRealizedSet class]];
            BOOL isRealizedChain = [self.sortedContent[rowIndex] isKindOfClass: [TJBRealizedChain class]];
            
            if (isRealizedSet){
                
                TJBRealizedSet *realizedSet = self.sortedContent[rowIndex];
                
                // dequeue the realizedSetCell
                
                TJBRealizedSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedSetCell"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateStyle = NSDateFormatterNoStyle;
                dateFormatter.timeStyle = NSDateFormatterShortStyle;
                NSString *date = [dateFormatter stringFromDate: realizedSet.submissionTime];
                
                [cell configureCellWithExercise: realizedSet.exercise.name
                                         weight: [NSNumber numberWithFloat: realizedSet.submittedWeight]
                                           reps: [NSNumber numberWithFloat: realizedSet.submittedReps]
                                           rest: nil
                                           date: date
                                         number: number
                             referenceIndexPath: indexPath];
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
                
            } else if (isRealizedChain){
                
                TJBRealizedChain *realizedChain = self.sortedContent[rowIndex];
                
                // dequeue the realizedSetCell
                
                TJBRealizedChainCell *cell = nil;
             
                cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
                
                [cell clearExistingEntries];
                
                [cell configureWithRealizedChain: realizedChain
                                          number: number
                                       finalRest: nil
                              referenceIndexPath: indexPath];
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
                
            } else{
                
                // if it is not a realized set or realized chain, then it is a TJBRealizedSetCollection
                
                TJBRealizedSetCollectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedSetCollectionCell"];
                
                [cell clearExistingEntries];
                
                cell.backgroundColor = [UIColor clearColor];
                
                [cell configureWithRealizedSetCollection: self.sortedContent[rowIndex]
                                                  number: number
                                               finalRest: nil
                                      referenceIndexPath: indexPath];
                
                return cell;
                
            }
        }
    }
    
}









#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat titleHeight = 60.0;
    
    if (indexPath.row == 0){
        
        return titleHeight;
        
    } else{
        
        if (self.sortedContent.count == 0){
            
            [self.view layoutIfNeeded];
            
            return self.tableView.frame.size.height - titleHeight;
            
        } else{
            
            NSInteger adjustedIndex = indexPath.row - 1;
            
            BOOL isRealizedSet = [self.sortedContent[adjustedIndex] isKindOfClass: [TJBRealizedSet class]];
            BOOL isRealizedChain = [self.sortedContent[adjustedIndex] isKindOfClass: [TJBRealizedChain class]];
            
            
            if (isRealizedSet){
                
                return 60;
                
            } else if (isRealizedChain) {
                
                TJBRealizedChain *realizedChain = self.sortedContent[adjustedIndex];
                
                return [TJBRealizedChainCell suggestedCellHeightForRealizedChain: realizedChain];
                
            } else{
                
                TJBRealizedSetGrouping rsc = self.sortedContent[adjustedIndex];
                
                return [TJBRealizedSetCollectionCell suggestedCellHeightForRealizedSetCollection: rsc];
                
            }
        }
    }
    
    
    
    
}





@end



























