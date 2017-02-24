//
//  TJBLiftOptionsVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/28/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBLiftOptionsVC.h"

// presented VC's

#import "TJBWorkoutNavigationHub.h"
#import "TJBRealizedSetActiveEntryVC.h"
#import "NewOrExistinigCircuitVC.h"
#import "TJBCircuitDesignVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// test

#import "TJBCompleteChainHistoryVC.h"


@interface TJBLiftOptionsVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *freeformButton;
@property (weak, nonatomic) IBOutlet UIButton *designedButton;
@property (weak, nonatomic) IBOutlet UIButton *createNewRoutineButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *analysisOptionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *liftOptionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewWorkoutLogButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;
- (IBAction)didPressCreateNewRoutine:(id)sender;
- (IBAction)didPressViewWorkoutLog:(id)sender;


@end

@implementation TJBLiftOptionsVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
//    self.
    
}

- (void)configureViewAesthetics{
    
    // buttons
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton,
                         self.createNewRoutineButton,
                         self.viewWorkoutLogButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 16.0;
        
    }
    
    // labels
    
    self.titleLabel1.backgroundColor = [UIColor darkGrayColor];
    self.titleLabel1.textColor = [UIColor whiteColor];
    self.titleLabel1.font = [UIFont boldSystemFontOfSize: 40.0];
    
    self.titleLabel2.backgroundColor = [UIColor darkGrayColor];
    self.titleLabel2.textColor = [UIColor whiteColor];
    self.titleLabel2.font = [UIFont boldSystemFontOfSize: 20.0];
    
    NSArray *grayLabels = @[self.analysisOptionsLabel, self.liftOptionsLabel];
    for (UILabel *label in grayLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 4.0;
        
    }
    

    
}



#pragma mark - IBAction

- (IBAction)didPressFreeformButton:(id)sender{
    
    // tab bar vc's
    
    TJBRealizedSetActiveEntryVC *vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
    vc1.tabBarItem.title = @"Active";
    
    TJBWorkoutNavigationHub *vc2 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO];
    vc2.tabBarItem.title = @"Workout Log";
    
    // tab bar controller
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers: @[vc1, vc2]];
    tbc.tabBar.translucent = NO;
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressDesignedButton:(id)sender{
    
    // tab bar vc's
    
    NewOrExistinigCircuitVC *vc1 = [[NewOrExistinigCircuitVC alloc] init];
    vc1.tabBarItem.title = @"Selection";
    
    TJBWorkoutNavigationHub *vc2 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO];
    vc2.tabBarItem.title = @"Workout Log";
    
    // tab bar
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers: @[vc1, vc2]];
    tbc.tabBar.translucent = NO;

    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressCreateNewRoutine:(id)sender{
    
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}




- (void)didPressBack{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}






- (IBAction)didPressViewWorkoutLog:(id)sender{
    
    TJBWorkoutNavigationHub *navHub = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: YES];

    [self presentViewController: navHub
                       animated: YES
                     completion: nil];
    
    
}









@end
