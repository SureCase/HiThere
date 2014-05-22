//
//  SCViewController.h
//  HiThere
//
//  Created by Miroslaw Stanek on 03.04.2014.
//  Copyright (c) 2014 Sure Case. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnSwitch;

- (IBAction)toggleBeaconMonitoring:(id)sender;

@end
