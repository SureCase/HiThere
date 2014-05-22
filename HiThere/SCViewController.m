//
//  SCViewController.m
//  HiThere
//
//  Created by Miroslaw Stanek on 03.04.2014.
//  Copyright (c) 2014 Sure Case. All rights reserved.
//

#import "SCViewController.h"
#import "ESTBeaconManager.h"

#define BEACON_MAJOR 5810
#define BEACON_MINOR 27179


NSString *const kEnableBeaconsMonitoring = @"enableBeaconsMonitoring";

@interface SCViewController () <ESTBeaconManagerDelegate>

@property(nonatomic, strong) ESTBeaconManager *beaconManager;
@property(nonatomic, strong) ESTBeaconRegion *beaconRegion;

@property(nonatomic, strong) UILocalNotification *welcomeNotification;
@property(nonatomic, strong) UILocalNotification *goodbyeNotification;

@end

@implementation SCViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initBeaconManager];
    [self initRegion];
    [self initNotifications];

    [self updateSwitchState];
}

- (void)initBeaconManager {
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;

    self.beaconManager.avoidUnknownStateBeacons = YES;
}

- (void)initRegion {
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                 major:BEACON_MAJOR
                                                                 minor:BEACON_MINOR
                                                            identifier:@"HiThere"];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
}

- (void)initNotifications {
    self.welcomeNotification = [[UILocalNotification alloc] init];
    self.welcomeNotification.alertBody = [NSString stringWithFormat:@"Welcome to work, your second home! It's nice to see you. :)"];
    self.welcomeNotification.soundName = UILocalNotificationDefaultSoundName;

    self.goodbyeNotification = [[UILocalNotification alloc] init];
    self.goodbyeNotification.alertBody = [NSString stringWithFormat:@"See you tomorrow. Don't be late!"];
    self.goodbyeNotification.soundName = UILocalNotificationDefaultSoundName;
}

- (void)updateSwitchState {
    if ([self isMonitoringEnabled]) {
        [self.btnSwitch setImage:[UIImage imageNamed:@"btn_be_quiet"] forState:UIControlStateNormal];
    } else {
        [self.btnSwitch setImage:[UIImage imageNamed:@"btn_say_hello"] forState:UIControlStateNormal];
    }
}

- (BOOL)isMonitoringEnabled {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:kEnableBeaconsMonitoring];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark IBactions

- (IBAction)toggleBeaconMonitoring:(id)sender {
    if ([self toggleMonitoring]) {
        [self startMonitoring];
    } else {
        [self stopMonitoring];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (BOOL)toggleMonitoring {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL monitorBeacons = ![userDefaults boolForKey:kEnableBeaconsMonitoring];
    [userDefaults setBool:monitorBeacons forKey:kEnableBeaconsMonitoring];
    [userDefaults synchronize];

    [self updateSwitchState];
    return monitorBeacons;
}

- (void)startMonitoring {
    NSLog(@"Start monitoring");
    [self.beaconManager startMonitoringForRegion:self.beaconRegion];
    [self.beaconManager requestStateForRegion:self.beaconRegion];
}

- (void)stopMonitoring {
    NSLog(@"Stop monitoring");
    [self.beaconManager stopMonitoringForRegion:self.beaconRegion];
}

#pragma mark BeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager
       didEnterRegion:(ESTBeaconRegion *)region {
    NSLog(@"Entered region: %@", region);
    [self showWelcomeMessage];
}

- (void)showWelcomeMessage {
    [[UIApplication sharedApplication] cancelLocalNotification:self.goodbyeNotification];
    [[UIApplication sharedApplication] presentLocalNotificationNow:self.welcomeNotification];
}

- (void)beaconManager:(ESTBeaconManager *)manager
        didExitRegion:(ESTBeaconRegion *)region {
    NSLog(@"Left region: %@", region);
    [self showGoodbyeMessage];
}

- (void)showGoodbyeMessage {
    [[UIApplication sharedApplication] cancelLocalNotification:self.welcomeNotification];
    [[UIApplication sharedApplication] presentLocalNotificationNow:self.goodbyeNotification];
}

- (void)beaconManager:(ESTBeaconManager *)manager
    didDetermineState:(CLRegionState)state
            forRegion:(ESTBeaconRegion *)region {
    if (state == CLRegionStateInside) {
        NSLog(@"Determine inside region");
        [self showWelcomeMessage];
    } else if (state == CLRegionStateOutside) {
        NSLog(@"Determine outside region");
        [self showGoodbyeMessage];
    }
}

- (void)beaconManagerDidStartAdvertising:(ESTBeaconManager *)manager
                                   error:(NSError *)error {
    NSLog(@"Beacond did start advertising");
    NSLog(@"manager = %@", manager);
    NSLog(@"error = %@", error);
}

@end
