//
//  TJBStopwatch.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

//// only the primary stopwatch observer keeps track of the update dates.  The primary stopwatch should always be used first and the secondary stopwatch should only be used if the primary stopwatch is already in immediate use.

#import "TJBStopwatch.h"

// local notifications

#import <UserNotifications/UserNotifications.h>

// stopwatch

#import "TJBStopwatch.h"

#import "AppDelegate.h" // app delegate

@interface TJBStopwatch () <NSCoding>

{
    float _primaryElapsedTimeInSeconds;
    float _secondaryElapsedTimeInSeconds;
    
    BOOL _incrementPrimaryElapsedTimeForwards;
    BOOL _incrementSecondaryElapsedTimeForwards;
    
    BOOL _primaryStopwatchIsOn;
    BOOL _secondaryStopwatchIsOn;
    
}

@property (nonatomic, strong) NSTimer *stopwatch;

@property (nonatomic, strong) NSMutableSet *primaryTimeObservers;
@property (nonatomic, strong) NSMutableSet *secondaryTimeObservers;

@property (nonatomic, strong) NSMutableArray <UIViewController<TJBStopwatchObserver> *> *primaryStopwatchObserverVCs;
@property (nonatomic, strong) NSMutableArray <UIViewController<TJBStopwatchObserver> *> *secondaryStopwatchObserverVCs;

@property (nonatomic, strong) NSDate *dateAtLastPrimaryUpdate;
@property (nonatomic, strong) NSDate *dateAtLastSecondaryUpdate;

// local notifications

@property (nonatomic, strong) NSString *activeLocalAlertID;


@end



#pragma mark - Constants

static NSString * const activeLocalAlertIDKey = @"activeLocalAlertID";
static NSString * const stopwatchStateKey = @"StopwatchState";





@implementation TJBStopwatch

#pragma mark - Singleton

+ (instancetype)singleton{
    
    static TJBStopwatch *singleton = nil;
    
    if (!singleton){
        
        NSData *appStateData = [[NSUserDefaults standardUserDefaults] objectForKey: stopwatchStateKey];
        
        if (appStateData){
            
            singleton = [NSKeyedUnarchiver unarchiveObjectWithData: appStateData];
            
        } else{
            
            singleton = [[self alloc] initPrivate];
            
        }
        
    }
    
    return singleton;
    
}

- (instancetype)initPrivate{
    
    self = [super init];
    
    _primaryElapsedTimeInSeconds = 0;
    _secondaryElapsedTimeInSeconds = 0;
    
    self.primaryTimeObservers = [[NSMutableSet alloc] init];
    self.secondaryTimeObservers = [[NSMutableSet alloc] init];
    
    self.primaryStopwatchObserverVCs = [[NSMutableArray alloc] init];
    self.secondaryStopwatchObserverVCs = [[NSMutableArray alloc] init];
    
    _primaryStopwatchIsOn = NO;
    _secondaryStopwatchIsOn = NO;
    
    self.stopwatch = [NSTimer scheduledTimerWithTimeInterval: .1
                                                      target: self
                                                    selector: @selector(updateTimerLabels)
                                                    userInfo: nil
                                                     repeats: YES];

    
    return self;
    
}


- (instancetype)init{
    
    @throw [NSException exceptionWithName: @"Singleton"
                                   reason: @"Use +[TJBStopwatch singleton]"
                                 userInfo: nil];
    
}

#pragma mark - Internal Methods

- (void)updateTimerLabels{
    
    if (_primaryStopwatchIsOn){
        
        [self incrementPrimaryTimer];
        
        [self updatePrimaryTimerLabels];
        
    }
    
    if (_secondaryStopwatchIsOn){
        
        [self incrementSecondaryTimer];
        
        for (UILabel *timerLabel in self.secondaryTimeObservers){
            
            timerLabel.text = [self minutesAndSecondsStringFromNumberOfSeconds: _secondaryElapsedTimeInSeconds];
            
        }
        
    }
    
}

- (void)updatePrimaryTimerLabels{
    
    for (UILabel *timerLabel in self.primaryTimeObservers){
        
        timerLabel.text = [self minutesAndSecondsStringFromNumberOfSeconds: _primaryElapsedTimeInSeconds];
        
    }
    
}

- (void)incrementPrimaryTimer{
    
    // elapsed time
    
    NSDate *now = [NSDate date];
    float elapsedTime;
    
    if (!self.dateAtLastPrimaryUpdate){
        
        elapsedTime = .1;
        
    } else{
        
        elapsedTime = [now timeIntervalSinceDate: self.dateAtLastPrimaryUpdate];
        
    }
    
    //  timer
    
    if (_incrementPrimaryElapsedTimeForwards == YES){
        
        _primaryElapsedTimeInSeconds += elapsedTime;
        
    } else{
        
        _primaryElapsedTimeInSeconds -= elapsedTime;
        
    }
    
    [self callPrimaryObserverProtocolMethod];
    
}

- (void)callPrimaryObserverProtocolMethod{
    
    NSDate *now = [NSDate date];
    
    self.dateAtLastPrimaryUpdate = now;
    
    for (UIViewController<TJBStopwatchObserver> *vc in self.primaryStopwatchObserverVCs){
        
        [vc primaryTimerDidUpdateWithUpdateDate: now
                                     timerValue: _primaryElapsedTimeInSeconds];
        
    }
    
}

- (void)incrementSecondaryTimer{
    
    // elapsed time
    
    NSDate *currentDate = [NSDate date];
    float elapsedTime;
    
    if (!self.dateAtLastSecondaryUpdate){
        
        elapsedTime = .1;
        
    } else{
        
        elapsedTime = [currentDate timeIntervalSinceDate: self.dateAtLastSecondaryUpdate];
        
    }
    
    //  timer
    
    if (_incrementSecondaryElapsedTimeForwards == YES){
        
        _secondaryElapsedTimeInSeconds += elapsedTime;
        
    } else{
        
        _secondaryElapsedTimeInSeconds -= elapsedTime;
        
    }
    
    self.dateAtLastSecondaryUpdate = currentDate;
    
    for (UIViewController<TJBStopwatchObserver> *vc in self.secondaryStopwatchObserverVCs){
        
        [vc secondaryTimerDidUpdateWithUpdateDate: currentDate];
        
    }
    
}





#pragma mark - Observers

- (void)addPrimaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel{
    
    //// add both the observing VC and timer label to their respective IVs
    
    [self.primaryStopwatchObserverVCs addObject: viewController];
    
    [self.primaryTimeObservers addObject: timerLabel];
    
}

- (void)addSecondaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel{
    
    [self.secondaryStopwatchObserverVCs addObject: viewController];
    
    [self.secondaryTimeObservers addObject: timerLabel];
    
}



- (void)removePrimaryStopwatchObserver:(UILabel *)timerLabel{
    
    [self.primaryTimeObservers removeObject: timerLabel];
    
    return;
    
}

- (void)removeAllPrimaryStopwatchObservers{
    
    self.primaryTimeObservers = [[NSMutableSet alloc] init];
    
}



#pragma mark - Stopwatch Manipulation

- (void)resetPrimaryTimer{
    
    _primaryElapsedTimeInSeconds = 0.0;
    
    // local alert management
    [self deleteActiveLocalAlert];
    
    if (_primaryStopwatchIsOn == YES){
        
        [self scheduleAlertBasedOnUserPermissions];
        
    }
    
    [self updatePrimaryTimerLabels];
    
}

- (void)pausePrimaryTimer{
    
    // check to see if the timer was running. If so, delete the existing local alert
    
    if (_primaryStopwatchIsOn == YES && self.activeLocalAlertID){
        
        [self deleteActiveLocalAlert];
        
    }
    
    _primaryStopwatchIsOn = NO;
    
}

- (void)playPrimaryTimer{
    
    // local alert management
    
    if (_primaryStopwatchIsOn == NO){
        
        [self scheduleAlertBasedOnUserPermissions];
        
    }
    
    self.dateAtLastPrimaryUpdate = nil; // must nullify this IV; if not, the timer calculates the time since the last update, so it is as if the timer was never paused in the first place
    
    _primaryStopwatchIsOn = YES;
    
}

- (void)deleteActiveLocalAlert{
    
    if (self.activeLocalAlertID){
        
        [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers: @[self.activeLocalAlertID]];
        self.activeLocalAlertID = nil;
        
    }
    
}


- (void)setSecondaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate{
    
    _secondaryStopwatchIsOn = YES;
    
    _secondaryElapsedTimeInSeconds = timeInSeconds;
    
    _incrementSecondaryElapsedTimeForwards = forwardIncrementing;
    
    if (lastUpdateDate){
        
        self.dateAtLastSecondaryUpdate = lastUpdateDate;
        
    }
    
}

- (void)setPrimaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate{
    
    _primaryStopwatchIsOn = YES;
    
    if (lastUpdateDate){
        
        NSDate *now = [NSDate date];
        int elapsedTimeSinceLastUpdate = [now timeIntervalSinceDate: lastUpdateDate];
        
        self.dateAtLastPrimaryUpdate = now;
        
        _primaryElapsedTimeInSeconds = timeInSeconds + elapsedTimeSinceLastUpdate;
        
    } else{
        
        _primaryElapsedTimeInSeconds = timeInSeconds;
        self.dateAtLastPrimaryUpdate = [NSDate date];
        
    }
    
    _incrementPrimaryElapsedTimeForwards = forwardIncrementing;
    
}


#pragma mark - Getters

- (NSNumber *)primaryTimeElapsedInSeconds
{
    return [NSNumber numberWithInt: _primaryElapsedTimeInSeconds];
}

- (NSNumber *)secondaryTimeElapsedInSeconds{
    
    return [NSNumber numberWithFloat: _secondaryElapsedTimeInSeconds];
    
}

- (NSString *)primaryTimeElapsedAsString
{
    return [self minutesAndSecondsStringFromNumberOfSeconds: _primaryElapsedTimeInSeconds];
}

- (NSString *)secondaryTimeElapsedAsString
{
    return [self minutesAndSecondsStringFromNumberOfSeconds: _secondaryElapsedTimeInSeconds];
}

#pragma mark - Conversion

- (NSString *)minutesAndSecondsStringFromNumberOfSeconds:(int)numberOfSeconds{
    
    if (numberOfSeconds < 0)
        
    {
        numberOfSeconds *= -1;
        
        int minutes = numberOfSeconds / 60;
        int seconds = numberOfSeconds % 60;
        
        return [NSString stringWithFormat: @"-%02d:%02d", minutes, seconds];
        
    } else{
        
        int minutes = numberOfSeconds / 60;
        int seconds = numberOfSeconds % 60;
        
        return [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
        
    }
    
}

#pragma mark - Direct Timer Manipulation

- (void)resetAndPausePrimaryTimer{
    
    _primaryStopwatchIsOn = NO;
    _primaryElapsedTimeInSeconds = 0;
    
}

#pragma mark - Local Notification

- (void)setAlertParameters_targetRest:(NSNumber *)targetRest alertTiming:(NSNumber *)alertTiming{
    
    self.targetRest = targetRest;
    self.alertTiming = alertTiming;
    
}



- (void)scheduleAlertBasedOnUserPermissions{
    
    UNUserNotificationCenter *nCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    void (^alertPermissionsHandler)(UNNotificationSettings *) = ^(UNNotificationSettings *settings){
        
        if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined){
            
            [self initialLocalNotificationRequestAlertSequence];
            
        } else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized){
            
            [self scheduleLocalNotificationBasedOnClassIVs];
            
        }
        
        else{
            
            return;
            
        }
        
    };
    
    [nCenter getNotificationSettingsWithCompletionHandler: alertPermissionsHandler];
    
}

- (void)initialLocalNotificationRequestAlertSequence{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Target Rest Alerts"
                                                                   message: @"Push notifications must be enabled in order for target rest alerts to work. Enable push notification in the following prompt if you would like to use rest alerts"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: ^(UIAlertAction *action){
                                                               
                                                               
                                                               void (^authorizationRequestHandler)(BOOL, NSError *) = ^(BOOL granted, NSError *error){
                                                                   
                                                                   [self scheduleAlertBasedOnUserPermissions];
                                                                   
                                                               };
                                                               
                                                               [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions: (UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                                                                                                                                   completionHandler: authorizationRequestHandler];
                                                               
                                                               
                                                           }];
    [alert addAction: continueAction];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[ad topViewController] presentViewController: alert
                                         animated: YES
                                       completion: nil];
    
}


- (void)scheduleLocalNotificationBasedOnClassIVs{
    
    // will only schedule a notification if both the targetRest and alertTiming IV's exist
    // an alert should not be scheduled if the stopwatch is not running. Pressing the play button will schedule an alert
    
    if (self.targetRest && self.alertTiming && _primaryStopwatchIsOn == YES){
        
        NSTimeInterval targetStopwatchValue = [self.targetRest floatValue] - [self.alertTiming floatValue];
        
        // schedule if the current primary stopwatch value is less than the targetStopwatchValue
        
        if (_primaryElapsedTimeInSeconds < targetStopwatchValue){

            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval: targetStopwatchValue - _primaryElapsedTimeInSeconds // this is the remaining time before the alert should sound
                                                                                                            repeats: NO];
            
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            content.title = @"Leeft Timer Alert";
            NSString *formattedAlertTiming = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.alertTiming intValue]];
            content.subtitle = [NSString stringWithFormat: @"%@ until set begin", formattedAlertTiming];
            content.body = @"This is your scheduled Leeft alert. Please prepare for your upcoming set";
            content.sound = [UNNotificationSound defaultSound];
            
            // delete the active alert, if one exists
            // I never want to have 2 alerts active at the same time
            
            [self deleteActiveLocalAlert];
            
            NSUUID *alertID = [NSUUID UUID];
            NSString *alertIDString = [alertID UUIDString];
            self.activeLocalAlertID = alertIDString;
            
            [self saveStateToUserDefaults];
            
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier: alertIDString
                                                                                  content: content
                                                                                  trigger: trigger];
            
            [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest: request
                                                                   withCompletionHandler: nil];
            
            
        }
        
        
        
    }
    
    return;
    
}

- (NSString *)alertTextFromTargetValues{
    
    NSString *alertText;
    
    if (self.targetRest && self.alertTiming){
        
        int alertValue = [self.targetRest intValue] - [self.alertTiming intValue];
        NSString *formattedValue = [self minutesAndSecondsStringFromNumberOfSeconds: alertValue];
        alertText = [NSString stringWithFormat: @"Alert at %@", formattedValue];
        
    } else{
        
        alertText = @"No Alert";
        
    }
    
    return  alertText;
    
}

- (void)clearTargetRestAndAlertTiming{
    
    self.targetRest = nil;
    self.alertTiming = nil;
    
}

- (BOOL)alertIsFullyDefined{
    
    return self.targetRest && self.alertTiming && _primaryStopwatchIsOn == YES;
    
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    if (self.activeLocalAlertID){
        
        [aCoder encodeObject: self.activeLocalAlertID
                      forKey: activeLocalAlertIDKey];
        
    }

    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [self initPrivate];
    
    NSString *restoredActiveLocalAlertID = [aDecoder decodeObjectForKey: activeLocalAlertIDKey];
    
    if (restoredActiveLocalAlertID){
        
        self.activeLocalAlertID = restoredActiveLocalAlertID;
        
    }
    
    
    return self;
    
}

- (void)saveStateToUserDefaults{
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: self];
    [[NSUserDefaults standardUserDefaults] setObject: data
                                              forKey: stopwatchStateKey];
    
    
}


@end






























