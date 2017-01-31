//
//  TJBStructureTableViewCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/25/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBStructureTableViewCell.h"

// core data

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

@interface TJBStructureTableViewCell ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *chainNameLabel;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

// core data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBStructureTableViewCell

- (void)clearExistingEntries{
    
    ////  clear the stack view entries
    
    NSArray *views = self.stackView.arrangedSubviews;
    
    for (UIView *view in views){
        
        [self.stackView removeArrangedSubview: view];
        [view removeFromSuperview];
        
    }
    
    
}

- (void)configureWithChainTemplate:(TJBChainTemplate *)chainTemplate date:(NSDate *)date number:(NSNumber *)number{
    
    //// this cell will be dynamically sized, showing the chain name in the main label and stacking another label for every exercise in the chain
    
    self.chainTemplate = chainTemplate;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureViewAesthetics];
    
    // configure the chain name label
    
    NSString *title = [NSString stringWithFormat: @"%@ (%d entries)",
                       chainTemplate.name,
                       (int)chainTemplate.realizedChains.count];
    
    self.chainNameLabel.text = title;

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM d";
    self.dateLabel.text = [df stringFromDate: date];
    
    //// configure the stack view.  For every exercise, create a UILabel and configure it before adding it to the stack view
    
    int numExercises = chainTemplate.numberOfExercises;
    
    for (int i = 0; i < numExercises; i++){
        
        UIView *iterativeView = [self stackViewForExerciseIndex: i];
        
        [self.stackView addArrangedSubview: iterativeView];
        
    }
    
    return;
    
    
    
}

- (void)configureViewAesthetics{
    
    //// configure view aesthetics
    
    NSArray *views = @[self.chainNameLabel,
                       self.dateLabel,
                       self.stackView,
                       self.contentView,
                       self.numberLabel];
    
    for (UIView *view in views){
        
        view.backgroundColor = [UIColor clearColor];
        
    }
    
    self.numberLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    
}

- (UIStackView *)stackViewForExerciseIndex:(int)exerciseIndex{
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    
    int roundLimit = self.chainTemplate.numberOfRounds;
    
    // exercise label
    
    UILabel *exerciseLabel = [[UILabel alloc] init];
    exerciseLabel.text = self.chainTemplate.exercises[exerciseIndex].name;
    exerciseLabel.font = [UIFont systemFontOfSize: 15.0];
    exerciseLabel.textColor = [UIColor blackColor];
    exerciseLabel.textAlignment = NSTextAlignmentLeft;
    
    [stackView addArrangedSubview: exerciseLabel];
    
    for (int i = 0; i < roundLimit; i++){
        
        UIView *iterativeView = [self roundSubviewForExerciseIndex: exerciseIndex
                                                        roundIndex: i];
        
        [stackView addArrangedSubview: iterativeView];
        
    }
    
    return stackView;
    
}

- (UIView *)roundSubviewForExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    //// create the exercise name subview, which will have two labels - one for a number and one for a name
    
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *weightLabel = [[UILabel alloc] init];
    UILabel *repsLabel = [[UILabel alloc] init];
    UILabel *restLabel = [[UILabel alloc] init];
    
    TJBChainTemplate *chain = self.chainTemplate;
    
    BOOL targetingWeight = chain.targetingWeight;
    BOOL targetingReps = chain.targetingReps;
    BOOL targetingRest = chain.targetingRestTime;
    
    NSString *weightString;
    NSString *repsString;
    NSString *restString;
    
    if (targetingWeight) {
        
        float weight = self.chainTemplate.weightArrays[exerciseIndex].numbers[roundIndex].value;
        weightString = [NSString stringWithFormat: @"%.01f lbs", weight];
        
    } else{
        
        weightString = @"no target";
        
    }
    
    if (targetingReps) {
        
        int reps = (int)self.chainTemplate.repsArrays[exerciseIndex].numbers[roundIndex].value;
        repsString = [NSString stringWithFormat: @"%d reps", reps];
        
    } else{
        
        repsString = @"";
        
    }
    
    if (targetingRest) {
        
        int rest = self.chainTemplate.targetRestTimeArrays[exerciseIndex].numbers[roundIndex].value;
        restString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: rest];
        
    } else{
        
        restString = @"";
        
    }
        
    weightLabel.text = weightString;
    repsLabel.text = repsString;
    restLabel.text = restString;
    
    NSArray *labels = @[weightLabel,
                        repsLabel,
                        restLabel];
    
    for (UILabel *label in labels){
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [view addSubview: label];
        
        [label setTextColor: [UIColor blackColor]];
        [label setFont: [UIFont systemFontOfSize: 15.0]];
        label.textAlignment = NSTextAlignmentLeft;
        label.backgroundColor = [UIColor clearColor];
        
    }
    
    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[weightLabel, repsLabel, restLabel]
                                                                  forKeys: @[@"weightLabel", @"repsLabel", @"restLabel"]];
    
    NSString *horizontal1 = @"H:|-32-[weightLabel]-0-[repsLabel(==weightLabel)]-0-[restLabel(==weightLabel)]-0-|";
    
    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: constraintMapping];
    
    NSString *vertical1 = @"V:|-0-[restLabel]-0-|";
    NSString *vertical2 = @"V:|-0-[weightLabel]-0-|";
    NSString *vertical3 = @"V:|-0-[repsLabel]-0-|";
    
    
    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: vertical1
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    NSArray *verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat: vertical2
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    NSArray *verticalConstraints3 = [NSLayoutConstraint constraintsWithVisualFormat: vertical3
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    [view addConstraints: horizontalConstraints1];
    [view addConstraints: verticalConstraints1];
    [view addConstraints: verticalConstraints2];
    [view addConstraints: verticalConstraints3];
    
    return view;
}

+ (float)suggestedCellHeightForChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    //// must manually configure the inputs as the xib is altered
    
    float numberOfExercises = (float)chainTemplate.numberOfExercises;
    float numberOfRounds = (float)chainTemplate.numberOfRounds;
    float titleHeight = 20.0;
    float spacing = 8.0;
    float error = 16.0;
    
    return (numberOfExercises * (numberOfRounds + 1.0) + 1.0) * titleHeight + spacing + error;
    
}

//- (UIView *)exerciseNameSubviewWithNumber:(NSNumber *)number name:(NSString *)name{
//    
//    //// create the exercise name subview, which will have two labels - one for a number and one for a name
//    
//    UIView *view = [[UIView alloc] init];
//    
//    UILabel *numberLabel = [[UILabel alloc] init];
//    UILabel *nameLabel = [[UILabel alloc] init];
//    
//    numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    numberLabel.text = [number stringValue];
//    nameLabel.text = name;
//    
//    [view addSubview: numberLabel];
//    [view addSubview: nameLabel];
//    
//    NSArray *labels = @[numberLabel, nameLabel];
//    for (UILabel *label in labels){
//        
//        label.backgroundColor = [UIColor clearColor];
//        label.font = [UIFont systemFontOfSize: 15.0];
//        label.textColor = [UIColor blackColor];
//        
//    }
//    
//    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[numberLabel, nameLabel]
//                                                                  forKeys: @[@"numberLabel", @"nameLabel"]];
//    
//    NSString *horizontal1 = @"H:|-0-[numberLabel(==20)]-4-[nameLabel]-0-|";
//    
//    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
//                                                                              options: 0
//                                                                              metrics: nil
//                                                                                views: constraintMapping];
//    
//    NSString *vertical1 = @"V:|-0-[numberLabel]-0-|";
//    NSString *vertical2 = @"V:|-0-[nameLabel]-0-|";
//    
//    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: vertical1
//                                                                            options: 0
//                                                                            metrics: nil
//                                                                              views: constraintMapping];
//    
//    NSArray *verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat: vertical2
//                                                                            options: 0
//                                                                            metrics: nil
//                                                                              views: constraintMapping];
//    
//    [view addConstraints: horizontalConstraints1];
//    [view addConstraints: verticalConstraints1];
//    [view addConstraints: verticalConstraints2];
//    
//    return view;
//    
//}


@end

























