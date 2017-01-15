//
//  TJBCircuitActiveUpdatingVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingVC.h"

// child VC's

#import "TJBCircuitActiveUpdatingExerciseComp.h"
#import "TJBCircuitActiveUpdatingRowComp.h"

// core data

#import "CoreDataController.h"

#import "TJBRealizedChain+CoreDataProperties.h"
#import "TJBChainTemplate+CoreDataProperties.h"
#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataProperties.h"
#import "SetBeginDateArray+CoreDataProperties.h"
#import "SetEndDateArray+CoreDataProperties.h"

// protocols

#import "TJBCircuitActiveUpdatingRowCompProtocol.h"

// utility

#import "TJBAssortedUtilities.h"

@interface TJBCircuitActiveUpdatingVC ()

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

@property (nonatomic, strong) NSNumber *viewHeight;
@property (nonatomic, strong) NSNumber *viewWidth;

// IV's derived from realizedChain

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;

@property (nonatomic, strong) NSString *realizedChainUniqueID;

@property (nonatomic, strong) NSNumber *firstIncompleteExerciseIndex;
@property (nonatomic, strong) NSNumber *firstIncompleteRoundIndex;

// for programmatic layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

// keeps track of its children rows and exercise components to facillitate delegate functionality

@property (nonatomic, strong) NSMutableArray<NSMutableArray <TJBCircuitActiveUpdatingRowComp<TJBCircuitActiveUpdatingRowCompProtocol> *> *> *childRowControllers;

@end

@implementation TJBCircuitActiveUpdatingVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth{
    
    self = [super init];
    
    // core
    
    self.realizedChain = realizedChain;
    self.viewHeight = viewHeight;
    self.viewWidth = viewWidth;
    
    //// order dependent - derived instance variables must be set before the skeleton array for childRowControllers is created
    
    // set derived instance variables
    
    [self setDerivedInstanceVariables];
    
    // instantiate childRowControllers in preparation for adding objects during view layout
    
    [self createSkeletonChildRowControllersArray];

    // for notifications
    
    [self registerForRelevantNotifications];
    
    return self;
}

- (void)createSkeletonChildRowControllersArray{
    
    //// create a skeleton array of arrays for childRowControllers so that objects can be added during view layout
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    NSMutableArray *metaArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < exerciseLimit; i++){
        
        NSMutableArray *subArray = [[NSMutableArray alloc] init];
        
        [metaArray addObject: subArray];
        
    }
    
    self.childRowControllers = metaArray;
    
}

- (void)setDerivedInstanceVariables{
    
    // set IV's derived from chain template
    
    TJBRealizedChain *realizedChain = self.realizedChain;
    
    self.numberOfRounds = [NSNumber numberWithInt: realizedChain.numberOfRounds];
    self.numberOfExercises = [NSNumber numberWithInt: realizedChain.numberOfExercises];
    self.realizedChainUniqueID = self.realizedChain.uniqueID;
    
    self.firstIncompleteRoundIndex = [NSNumber numberWithInt: realizedChain.firstIncompleteRoundIndex];
    self.firstIncompleteExerciseIndex = [NSNumber numberWithInt: realizedChain.firstIncompleteExerciseIndex];
    
    return;
    
}

- (void)updateDerivedFirstIncompleteTypeRealizedChainProperties{
    
    //// update the first incomplete round/exercise derived properties
    
    TJBRealizedChain *realizedChain = self.realizedChain;
    
    self.firstIncompleteRoundIndex = [NSNumber numberWithInt: realizedChain.firstIncompleteRoundIndex];
    self.firstIncompleteExerciseIndex = [NSNumber numberWithInt: realizedChain.firstIncompleteExerciseIndex];
    
}

- (void)registerForRelevantNotifications{
    
    // this notification relies on the TJBActiveCircuitGuidance using the same TJBRealizedChain as is stored in this VC
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(realizedChainDidChange)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: self.realizedChain];
    
}

#pragma mark - Notification Actions

- (void)realizedChainDidChange{
    
    // changes made to the realized chain by the 'active guidance' vc are immediately realized here.  All that needs to be done is to update the relevant derived IV's
    
    NSLog(@"first incomplete exercise index: %d\nfirst incomplete round index: %d",
          self.realizedChain.firstIncompleteExerciseIndex,
          self.realizedChain.firstIncompleteRoundIndex);
    
    [self updateDerivedFirstIncompleteTypeRealizedChainProperties];
    
    return;
    
}


#pragma mark - View Life Cycle

- (void)loadView{
    
    // this must be called when creating the view programatically
    
    float viewWidth = [self.viewWidth floatValue];
    float viewHeight = [self.viewHeight floatValue];
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, viewWidth,  viewHeight)];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
}


- (void)viewDidLoad{
    
    [self createChildViewControllersAndLayoutViews];
}

- (void)createChildViewControllersAndLayoutViews{
    
    // for constraint mapping
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // scroll view
    
    CGRect scrollViewFrame = CGRectMake(0, 0, [self.viewWidth floatValue], [self.viewHeight floatValue]);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: scrollViewFrame];
    
    // determine height of scroll view content size
    
    CGFloat rowHeight = 30;
    CGFloat componentToComponentSpacing = 16;
    CGFloat componentStyleSpacing = 8;
    CGFloat componentHeight;
    
    // the extra height allows the user to drag the bottom-most exercise further up on the screen
    
    CGFloat extraHeight = [UIScreen mainScreen].bounds.size.height / 2.0;
    
    componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
    
    int numberOfComponents = [self.numberOfExercises intValue];
    CGFloat scrollContentHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1) + extraHeight;
    
    scrollView.contentSize = CGSizeMake([self.viewWidth floatValue], scrollContentHeight);
    [self.view addSubview: scrollView];
    
    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, [self.viewWidth floatValue], scrollContentHeight);
    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
    [scrollView addSubview: scrollViewSubview];
    
    // row components
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: @"V:|-"];
    
    for (int i = 0 ; i < [self.numberOfExercises intValue] ; i ++){
        
        // create the ordered sets with realized chain data and other data that will be fed into the exercise component
        
        TJBRealizedChain *chain = self.realizedChain;
        
        NSNumber *numberOfRounds = [NSNumber numberWithInt: chain.numberOfRounds];
        NSNumber *chainNumber = [NSNumber numberWithInt: i + 1];
        TJBExercise *exercise = chain.exercises[i];
        NSNumber *firstIncompleteExerciseIndex = [NSNumber numberWithInt: chain.firstIncompleteExerciseIndex];
        NSNumber *firstIncompleteRoundIndex = [NSNumber numberWithInt: chain.firstIncompleteRoundIndex];
        NSOrderedSet <TJBNumberTypeArrayComp *> *weightData = chain.weightArrays[i].numbers;
        NSOrderedSet <TJBNumberTypeArrayComp *> *repsData = chain.repsArrays[i].numbers;
        NSOrderedSet <TJBBeginDateComp *> *setBeginDatesData = chain.setBeginDateArrays[i].dates;
        NSOrderedSet <TJBEndDateComp *> *setEndDatesData = chain.setEndDateArrays[i].dates;
        NSNumber *numberOfExercises = [NSNumber numberWithInt: chain.numberOfExercises];
        NSOrderedSet <TJBEndDateComp *> *previousExerciseSetEndDatesData = [TJBAssortedUtilities previousExerciseSetEndDatesForRealizedChain: chain
                                                                                                                    currentExerciseIndex: i];
        
        // create the exercise component
        
        TJBCircuitActiveUpdatingExerciseComp *vc = [[TJBCircuitActiveUpdatingExerciseComp alloc] initWithNumberOfRounds: numberOfRounds
                                                                                                            chainNumber: chainNumber
                                                                                                               exercise: exercise
                                                                                           firstIncompleteExerciseIndex: firstIncompleteExerciseIndex
                                                                                              firstIncompleteRoundIndex: firstIncompleteRoundIndex
                                                                                                             weightData: weightData
                                                                                                               repsData: repsData
                                                                                                      setBeginDatesData: setBeginDatesData
                                                                                                        setEndDatesData: setEndDatesData
                                                                                        previousExerciseSetEndDatesData: previousExerciseSetEndDatesData
                                                                                                      numberOfExercises: numberOfExercises
                                                                                                       masterController: self];
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: vc];
        
        [scrollViewSubview addSubview: vc.view];
        
        NSString *dynamicComponentName = [NSString stringWithFormat: @"exerciseComponent%d",
                                          i];
        
        [self.constraintMapping setObject: vc.view
                                   forKey: dynamicComponentName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if (i == [self.numberOfExercises intValue] - 1){
            
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%d)]",
                                    dynamicComponentName,
                                    (int)componentHeight];
        } else{
            
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%d)]-%d-",
                                    dynamicComponentName,
                                    (int)componentHeight,
                                    (int)componentToComponentSpacing];
        }
        
        [verticalLayoutConstraintsString appendString: verticalAppendString];
        
        // horizontal constraints
        
        NSString *horizontalLayoutConstraintsString = [NSString stringWithFormat: @"H:|-0-[%@]-0-|",
                                                       dynamicComponentName];
        
        NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horizontalLayoutConstraintsString
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: self.constraintMapping];
        
        [scrollViewSubview addConstraints: horizontalLayoutConstraints];
    }
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [scrollViewSubview addConstraints: verticalLayoutConstraints];
    
    for (TJBCircuitActiveUpdatingExerciseComp *child in self.childViewControllers){
        
        [child didMoveToParentViewController: self];
    }
}

#pragma mark - <TJBCircuitActiveUpdatingVCProtocol>

- (void)addChildRowController:(TJBCircuitActiveUpdatingRowComp<TJBCircuitActiveUpdatingRowCompProtocol> *)rowController forExerciseIndex:(int)exerciseIndex{
    
    //// add the child row controller for specified exercise index.  Row controllers should be passed-in in the correct order so that it is not necessary to specify the round in this method
    
    [self.childRowControllers[exerciseIndex] addObject: rowController];
    
    return;
    
}

- (void)didCompleteSetWithExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex weight:(NSNumber *)weight reps:(NSNumber *)reps setBeginDate:(NSDate *)setBeginDate setEndDate:(NSDate *)setEndDate{
    
    //// use the protocol method of the appropriate child row controller to update its views
    
    TJBCircuitActiveUpdatingRowComp <TJBCircuitActiveUpdatingRowCompProtocol> *rowComp = self.childRowControllers[exerciseIndex][roundIndex];
    
    [rowComp updateViewsWithWeight: weight
                              reps: reps];
    
    return;
    
}

@end





























