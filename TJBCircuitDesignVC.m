//
//  TJBCircuitDesignVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitDesignVC.h"

#import "TJBCircuitTemplateGeneratorVC.h"

#import "TJBAestheticsController.h"

@interface TJBCircuitDesignVC ()

{
    double _numberOfExercises;
    double _numberOfRounds;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingWeightSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingRepsSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingRestSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetsVaryByRoundSC;

@property (weak, nonatomic) IBOutlet UIStepper *numberOfExercisesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *numberOfRoundsStepper;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navItem;

- (IBAction)didPressLaunchTemplate:(id)sender;

// labels
@property (weak, nonatomic) IBOutlet UIButton *launchTemplateButton;
@property (weak, nonatomic) IBOutlet UILabel *circuitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfExercisesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRoundsLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetingWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetingRepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetingRestLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetsVaryByRoundLabel;

@end

@implementation TJBCircuitDesignVC

#pragma mark - Instantiation

- (void)viewDidLoad{
    [self configureView];
    [self configureNavigationBar];
    [self viewAesthetics];
}

- (void)configureView{
    _numberOfExercises = 1.0;
    _numberOfRounds = 1.0;
    
    self.numberOfExercisesLabel.text = [[NSNumber numberWithDouble: _numberOfExercises] stringValue];
    self.numberOfRoundsLabel.text = [[NSNumber numberWithDouble: _numberOfRounds] stringValue];
    
    [self.numberOfExercisesStepper addTarget: self
                                      action: @selector(didChangeExerciseStepperValue)
                            forControlEvents: UIControlEventValueChanged];
    [self.numberOfRoundsStepper addTarget: self
                                   action: @selector(didChangeRoundsStepperValue)
                         forControlEvents: UIControlEventValueChanged];
}

- (void)configureNavigationBar{
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Circuit Template Configuration"];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                   target: self
                                                                                   action: @selector(didPressCancel)];
    [navItem setLeftBarButtonItem: barButtonItem];
    [self.navBar setItems: @[navItem]];
}

- (void)viewAesthetics{
    CALayer *layer = self.nameTextField.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    NSArray *views = @[self.circuitNameLabel,
                       self.numberOfExercisesLabel,
                       self.numberOfRoundsLabel,
                       self.targetingWeightLabel,
                       self.targetingRepsLabel,
                       self.targetingRestLabel,
                       self.targetsVaryByRoundLabel];
    [TJBAestheticsController configureViewsWithType1Format: views
                                               withOpacity: .85];
}

#pragma mark - Stepper Methods

- (void)didChangeExerciseStepperValue{
    double number = self.numberOfExercisesStepper.value;
    
    _numberOfExercises = number;
    self.numberOfExercisesLabel.text = [[NSNumber numberWithDouble: number] stringValue];
}

- (void)didChangeRoundsStepperValue{
    double number = self.numberOfRoundsStepper.value;
    
    _numberOfRounds = number;
    self.numberOfRoundsLabel.text = [[NSNumber numberWithDouble: number] stringValue];
}

#pragma mark - Button Actions

- (IBAction)didPressLaunchTemplate:(id)sender{
    TJBCircuitTemplateGeneratorVC *vc = [[TJBCircuitTemplateGeneratorVC alloc] initWithTargetingWeight: [NSNumber numberWithLong: self.targetingWeightSC.selectedSegmentIndex]
                                                                                         targetingReps: [NSNumber numberWithLong: self.targetingRepsSC.selectedSegmentIndex]
                                                                                         targetingRest: [NSNumber numberWithLong: self.targetingRestSC.selectedSegmentIndex]
                                                                                    targetsVaryByRound: [NSNumber numberWithLong: self.targetsVaryByRoundSC.selectedSegmentIndex]
                                                                                     numberOfExercises: [NSNumber numberWithDouble: _numberOfExercises]
                                                                                        numberOfRounds: [NSNumber numberWithDouble: _numberOfRounds]
                                                                                                  name: self.nameTextField.text
                                                                                     supportsUserInput: YES];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

- (void)didPressCancel{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

@end



































