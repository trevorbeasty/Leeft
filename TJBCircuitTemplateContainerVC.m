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

// IBOutlet


@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightTitleButton;

@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *controlsContainer;

// IBAction

- (IBAction)didPressBack:(id)sender;
- (IBAction)didPressAdd:(id)sender;

// core

@property (nonatomic, strong) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *circuitTemplateVC;

// pertinent chainTemplate

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBCircuitTemplateContainerVC

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    
    return self;
    
}

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name{
    
    self = [super init];
    
    // chain template
    
    TJBChainTemplate *skeletonChainTemplate = [[CoreDataController singleton] createAndSaveSkeletonChainTemplateWithNumberOfExercises: numberOfExercises
                                                                                                                       numberOfRounds: numberOfRounds
                                                                                                                                 name: name
                                                                                                                    isTargetingWeight: [targetingWeight boolValue]
                                                                                                                      isTargetingReps: [targetingReps boolValue]
                                                                                                              isTargetingTrailingRest: [targetingReps boolValue]];
    
    self.chainTemplate = skeletonChainTemplate;

    return self;
    
}

- (void)setRestorationProperties{
    
    //// set the properties necessary for state restoration
    
    self.restorationClass = [TJBCircuitTemplateContainerVC class];
    self.restorationIdentifier = @"TJBCircuitTemplateContainerVC";
    
}



#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
//    [self setRestorationProperties];
//    
//    [self configureViewAesthetics];

}

- (void)viewDidAppear:(BOOL)animated{
    
//    if (!self.circuitTemplateVC){
//        
//        [self configureContainerView];
//        
//    }
    
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
    
    // controls container
    
    self.controlsContainer.backgroundColor = [UIColor clearColor];
    
}

- (void)configureContainerView{
    
    //// create the TJBCircuitTemplateVC
    
    TJBCircuitTemplateVC *vc = [[TJBCircuitTemplateVC alloc] initWithSkeletonChainTemplate: self.chainTemplate
                                                                                  viewSize: self.containerView.frame.size];
    
    self.circuitTemplateVC = vc;
    
    // get rects for animation
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect endingFrame = vc.view.frame;
    CGRect startingFrame = CGRectMake(endingFrame.origin.x, endingFrame.origin.y + screenSize.height, endingFrame.size.width, endingFrame.size.height);
    vc.view.frame = startingFrame;
    
    [self addChildViewController: vc];
    
    [self.containerView addSubview: vc.view];
//    [self.view insertSubview: self.launchCircuitButton
//                aboveSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
    // animation
    
    [UIView animateWithDuration: .4
                     animations: ^{
                         
                         vc.view.frame = endingFrame;
                         
                     }];
    
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
    
    // this VC and the circuit template VC share the same chain template.  Only the circuit template VC has the user-selected exercises, thus, it must be asked if all user input has been collected.  If it has all been collected, the circuit template VC will add the user-selected exercises to the chain template.
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
    
    if (requisiteUserInputCollected){
        
        // it has been determined that the chain template is complete, so update its corresponding property and save the context
        
//        self.chainTemplate.isIncomplete = NO;
        [[CoreDataController singleton] saveContext];
        
        // alert
        
        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                             self.chainTemplate.name];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.chainTemplate];
            vc1.tabBarItem.title = @"Active";
            
            TJBWorkoutNavigationHub *vc3 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO];
            vc3.tabBarItem.title = @"Workout Log";
            
            TJBCircuitReferenceContainerVC *vc2 = [[TJBCircuitReferenceContainerVC alloc] initWithRealizedChain: vc1.realizedChain];
            vc2.tabBarItem.title = @"Progress";
            
            // tab bar
            
            UITabBarController *tbc = [[UITabBarController alloc] init];
            [tbc setViewControllers: @[vc1, vc2, vc3]];
            tbc.tabBar.translucent = NO;
            
            
            [self presentViewController: tbc
                               animated: NO
                             completion: nil];
            

            
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

- (IBAction)didPressBack:(id)sender{
    
    // delete the chain template from the persistent store if it is incomplete
    
    // must check for completeness of chain template.  If all user selections have been been made but the 'launch circuit' or '+' buttons have not been pressed, its 'isIncomplete' property will not be updated
    
    BOOL isComplete = [[CoreDataController singleton] chainTemplateHasCollectedAllRequisiteUserInput: self.chainTemplate];
//    self.chainTemplate.isIncomplete = !isComplete;
    
    if (!isComplete){
        
        [[CoreDataController singleton] deleteChainTemplate: self.chainTemplate];
        
    }
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}



- (IBAction)didPressAdd:(id)sender{
    
    //// this VC and the circuit template VC share the same chain template.  Only the circuit template VC has the user-selected exercises, thus, it must be asked if all user input has been collected.  If it has all been collected, the circuit template VC will add the user-selected exercises to the chain template.
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
    
    if (requisiteUserInputCollected){
        
        // it has been determined that the chain template is complete, so update its corresponding property and save the context
        
//        self.chainTemplate.isIncomplete = NO;
        [[CoreDataController singleton] saveContext];
        
        // alert
        
        NSString *message = [NSString stringWithFormat: @"New routine added to My Routines"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Routine Successfully Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            UIViewController *homeVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            
            [homeVC dismissViewControllerAnimated: YES
                                       completion: nil];
            
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

//+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
//    
//    //// the only thing that needs to be done here is to restore the chain template that was being used and call the normal init method.  The decoder will be responsible for kicking off the process that updates all the views to their previous state
//    
//    NSString *chainTemplateUniqueID = [coder decodeObjectForKey: @"chainTemplateUniqueID"];
//    
//    // have CoreDataController retrieve the appropriate chain template
//    
//    TJBChainTemplate *chainTemplate = [[CoreDataController singleton] chainTemplateWithUniqueID: chainTemplateUniqueID];
//    
//    // create the TJBCircuitTemplateContainerVC and return it
//    
//    TJBCircuitTemplateContainerVC *vc = [[TJBCircuitTemplateContainerVC alloc] initWithChainTemplate: chainTemplate];
//    
//    return vc;
//    
//}
//
//- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
//    
//    [super decodeRestorableStateWithCoder: coder];
//    
//    // tell the child VC to populate its views with all user selected input
//    
//    [self.circuitTemplateVC populateChildVCViewsWithUserSelectedValues];
//    
//}
//
//- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
//    
//    //// all that needs to be done here is to record the unique ID of the chain template so that the CoreDataConroller can reload the correct chain template
//    
//    [super encodeRestorableStateWithCoder: coder];
//    
//    NSString *chainTemplateUniqueID = self.chainTemplate.uniqueID;
//    
//    [coder encodeObject: chainTemplateUniqueID
//                 forKey: @"chainTemplateUniqueID"];
//    
//}



@end




















































