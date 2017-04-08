//
//  TJBCircuitTemplateContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateContainerVC.h"

#import "TJBCircuitTemplateVC.h"

#import "TJBCircuitTemplateVCProtocol.h"

#import "TJBChainTemplate+CoreDataProperties.h"

// presented VC's

#import "TJBWorkoutNavigationHub.h"
#import "TJBActiveRoutineGuidanceVC.h"
#import "TJBCircuitReferenceContainerVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// core data

#import "CoreDataController.h"

@interface TJBCircuitTemplateContainerVC ()

{
    
    float _previousExercisesStepperValue;
    float _previousRoundsStepperValue;
    
}

// IBOutlet


@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightTitleButton;

@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *leftControlsContainer;
//@property (weak, nonatomic) IBOutlet UIView *rightControlsContainer;
//@property (weak, nonatomic) IBOutlet UIView *routineNameContainer;

@property (weak, nonatomic) IBOutlet UILabel *numberExercisesTitle;
@property (weak, nonatomic) IBOutlet UILabel *numberExercisesValue;
@property (weak, nonatomic) IBOutlet UILabel *numberRoundsTitle;
@property (weak, nonatomic) IBOutlet UILabel *numberRoundsValue;
@property (weak, nonatomic) IBOutlet UIStepper *numberExercisesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *numberRoundsStepper;
//@property (weak, nonatomic) IBOutlet UITextField *textFieldRoutineName;
//@property (weak, nonatomic) IBOutlet UILabel *titleRoutineName;


// IBAction

- (IBAction)didPressBack:(id)sender;
- (IBAction)didPressAdd:(id)sender;

// core

@property (nonatomic, strong) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *circuitTemplateVC;
@property (copy) TJBVoidCallback callback;

// pertinent chainTemplate

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@end



#pragma mark - Constants

static int const _startingNumberExercises = 4;
static int const _startingNumberRounds = 4;

static NSString * const placeholderName = @"placeholderName";





@implementation TJBCircuitTemplateContainerVC

#pragma mark - Instantiation

- (id)initWithCallback:(TJBVoidCallback)callback{
    
    self = [super init];
    
    [self createPlaceholderChainTemplate];
    
    self.callback = callback;
    
    return self;
    
}


#pragma mark - Init Helper Methods

- (void)createPlaceholderChainTemplate{
    
    TJBChainTemplate *chainTemplate = [[CoreDataController singleton] createAndSaveSkeletonChainTemplateWithNumberOfExercises: @(_startingNumberExercises)
                                                                                                               numberOfRounds: @(_startingNumberRounds)
                                                                                                                         name: placeholderName
                                                                                                            isTargetingWeight: YES
                                                                                                              isTargetingReps: YES
                                                                                                      isTargetingTrailingRest: YES];
    
    self.chainTemplate = chainTemplate;
    
}



#pragma mark - View Life Cycle

- (void)viewDidLoad{

    [self configureViewAesthetics];
    
    [self configureStartingContent];
    
    [self configureSteppers];

}

- (void)viewDidAppear:(BOOL)animated{
    

    
}

#pragma mark - View Helper Methods

- (void)configureSteppers{
    
    [self.numberExercisesStepper addTarget: self
                                    action: @selector(didChangeExerciseStepperValue)
                          forControlEvents: UIControlEventValueChanged];
    
    [self.numberRoundsStepper addTarget: self
                                 action: @selector(didChangeRoundStepperValue)
                       forControlEvents: UIControlEventValueChanged];
    
    NSArray *steppers = @[self.numberExercisesStepper, self.numberRoundsStepper];
    for (UIStepper *step in steppers){
        
        step.minimumValue = 1;
        step.maximumValue = 10;
        step.autorepeat = NO;
        step.stepValue = 1.0;
        step.continuous = YES;
        step.wraps = NO;
        
    }
    
    self.numberExercisesStepper.value = (float)_startingNumberExercises;
    self.numberRoundsStepper.value = (float)_startingNumberRounds;
    
}


- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // title container
    
    self.titleBarContainer.backgroundColor = [UIColor darkGrayColor];
    
    // title bar items
    
    NSArray *titleButtons = @[self.backButton, self.rightTitleButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor clearColor];
        
    }
    
    self.mainTitleLabel.backgroundColor = [UIColor clearColor];
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    self.mainTitleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    // content container
    
    self.containerView.backgroundColor = [UIColor clearColor];
    
    // controls containers
    
//    NSArray *controlsContainers = @[self.leftControlsContainer, self.rightControlsContainer, self.routineNameContainer];
//    for (UIView *contView in controlsContainers){
//        
//        contView.backgroundColor = [UIColor clearColor];
//        CALayer *layer = contView.layer;
//        layer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
//        layer.borderWidth = 2.0;
//    }
    
//    self.routineNameContainer.hidden = YES;
    
    self.leftControlsContainer.backgroundColor = [UIColor blackColor];
    CALayer *ccLayer = self.leftControlsContainer.layer;
//    ccLayer.masksToBounds = NO;
//    ccLayer.shadowOffset = CGSizeMake(0, -3);
//    ccLayer.shadowColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
//    ccLayer.shadowOpacity = .8;
    ccLayer.borderWidth = 2.0;
    ccLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    ccLayer.masksToBounds = YES;
    ccLayer.cornerRadius = 16;
    // control labels and steppers
    
    NSArray *controlTitleLabels = @[self.numberExercisesTitle, self.numberRoundsTitle];
    for (UILabel *lab in controlTitleLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize: 20];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    NSArray *controlValueLabels = @[self.numberExercisesValue, self.numberRoundsValue];
    for (UILabel *lab in controlValueLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont boldSystemFontOfSize: 25];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    NSArray *steppers = @[self.numberExercisesStepper, self.numberRoundsStepper];
    for (UIStepper *step in steppers){
        
        step.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        
    }
    
    // name container subviews
    
//    self.titleRoutineName.textColor = [UIColor whiteColor];
//    self.titleRoutineName.font = [UIFont systemFontOfSize: 20];
//    self.titleRoutineName.backgroundColor = [UIColor clearColor];
//    
//    self.textFieldRoutineName.backgroundColor = [UIColor clearColor];
//    self.textFieldRoutineName.font = [UIFont systemFontOfSize: 20];
//    self.textFieldRoutineName.textColor = [[TJBAestheticsController singleton] paleLightBlueColor];
//    CALayer *nameTFLayer = self.textFieldRoutineName.layer;
//    nameTFLayer.masksToBounds = YES;
//    nameTFLayer.cornerRadius = 20;
//    nameTFLayer.borderWidth = 1.0;
//    nameTFLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
}

- (void)configureStartingContent{
    
    // initial exercise and round values defined here
    
    NSNumber *startingNumberExercises = @(_startingNumberExercises);
    NSNumber *startingNumberRounds = @(_startingNumberRounds);
    
    self.numberExercisesValue.text = [startingNumberExercises stringValue];
    self.numberRoundsValue.text = [startingNumberRounds stringValue];
    
    _previousExercisesStepperValue = [startingNumberExercises floatValue];
    _previousRoundsStepperValue = [startingNumberRounds floatValue];
    
    // create the TJBCircuitTemplateVC
    
    TJBCircuitTemplateVC *ctVC = [[TJBCircuitTemplateVC alloc] initWithSkeletonChainTemplate: self.chainTemplate
                                                                   startingNumberOfExercises: startingNumberExercises
                                                                      startingNumberOfRounds: startingNumberRounds];
    
    self.circuitTemplateVC = ctVC;
    
    ctVC.view.frame = self.containerView.bounds;
    
    [self addChildViewController: ctVC];
    
    [self.containerView addSubview: ctVC.view];
    
    [ctVC didMoveToParentViewController: self];
    
}

#pragma mark - Stepper Actions

- (void)didChangeExerciseStepperValue{
    
    // local label
    
    NSNumber *stepValue = @(self.numberExercisesStepper.value);
    self.numberExercisesValue.text = [stepValue stringValue];
    
    // TJBCircuitTemplateVCProtocol
    
    if ([stepValue floatValue] > _previousExercisesStepperValue){
        
        [[CoreDataController singleton] appendExerciseToChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfExercisesInUpDirection: YES];
        
    } else{
        
        [[CoreDataController singleton] deleteLastExercisefromChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfExercisesInUpDirection: NO];
        
    }
    
    [self.view updateConstraintsIfNeeded]; // needs to be called to update views when existing constraints have been changed
    [self.view layoutIfNeeded];
    
    _previousExercisesStepperValue = [stepValue floatValue];
    
}

- (void)didChangeRoundStepperValue{
    
    // local label
    
    NSNumber *stepValue = @(self.numberRoundsStepper.value);
    self.numberRoundsValue.text = [stepValue stringValue];
    
    // TJBCircuitTemplateVCProtocol
    
    if ([stepValue floatValue] > _previousRoundsStepperValue){
        
        [[CoreDataController singleton] appendRoundToChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfRoundsInUpDirection: YES];
        
    } else{
        
        [[CoreDataController singleton] deleteLastRoundInChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfRoundsInUpDirection: NO];
        
    }
    
    [self.view updateConstraintsIfNeeded]; // needs to be called to update views when existing constraints have been changed
    [self.view layoutIfNeeded];
    
    _previousRoundsStepperValue = [stepValue floatValue];
    
}

#pragma mark - Button Actions

- (void)alertUserInputIncomplete{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Required Selections Incomplete"
                                                                   message: @"Please make all available selections"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                     style: UIAlertActionStyleDefault
                                                   handler: nil];
    [alert addAction: action];
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressLaunchCircuit:(id)sender{
//    
//    // this VC and the circuit template VC share the same chain template.  Only the circuit template VC has the user-selected exercises, thus, it must be asked if all user input has been collected.  If it has all been collected, the circuit template VC will add the user-selected exercises to the chain template.
//    
//    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
//    
//    if (requisiteUserInputCollected){
//        
//        // it has been determined that the chain template is complete, so update its corresponding property and save the context
//        
////        self.chainTemplate.isIncomplete = NO;
//        [[CoreDataController singleton] saveContext];
//        
//        // alert
//        
//        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
//                             self.chainTemplate.name];
//        
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Saved"
//                                                                       message: message
//                                                                preferredStyle: UIAlertControllerStyleAlert];
//        
//        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
//            
//            TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.chainTemplate];
//            vc1.tabBarItem.title = @"Active";
//            
//            TJBWorkoutNavigationHub *vc3 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO];
//            vc3.tabBarItem.title = @"Workout Log";
//            
//            TJBCircuitReferenceContainerVC *vc2 = [[TJBCircuitReferenceContainerVC alloc] initWithRealizedChain: vc1.realizedChain];
//            vc2.tabBarItem.title = @"Progress";
//            
//            // tab bar
//            
//            UITabBarController *tbc = [[UITabBarController alloc] init];
//            [tbc setViewControllers: @[vc1, vc2, vc3]];
//            tbc.tabBar.translucent = NO;
//            
//            
//            [self presentViewController: tbc
//                               animated: NO
//                             completion: nil];
//            
//
//            
//        };
//        
//        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
//                                                         style: UIAlertActionStyleDefault
//                                                       handler: alertBlock];
//        [alert addAction: action];
//        
//        [self presentViewController: alert
//                           animated: YES
//                         completion: nil];
//    } else{
//        
//    [self alertUserInputIncomplete];
//        
//    }
    
}

- (IBAction)didPressBack:(id)sender{
    
    [[CoreDataController singleton] deleteChainTemplate: self.chainTemplate];
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
}



- (IBAction)didPressAdd:(id)sender{
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];

    if (requisiteUserInputCollected){
        
        [[CoreDataController singleton] saveContext];
        
        // alert
        
        NSString *message = [NSString stringWithFormat: @"New routine added to My Routines"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Routine Successfully Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        __weak TJBCircuitTemplateContainerVC *weakSelf = self;
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            weakSelf.callback();
            
        };
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: alertBlock];
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else{
        
        [self alertUserInputIncomplete];
        
    }
}

#pragma mark - <UIViewControllerRestoration>





@end




















































