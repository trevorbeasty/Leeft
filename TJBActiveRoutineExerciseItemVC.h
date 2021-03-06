//
//  TJBActiveRoutineExerciseItemVC.h
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBPreviousMarksDictionary; // previous marks

@interface TJBActiveRoutineExerciseItemVC : UIViewController

- (instancetype)initWithTitleNumber:(NSString *)titleNumber targetExerciseName:(NSString *)targetExerciseName targetWeight:(NSString *)targetWeight targetReps:(NSString *)targetReps previousEntries:(NSArray<TJBPreviousMarksDictionary *> *)previousEntries;

- (CGFloat)suggestedHeight;

@end
