//
//  SWAlertViewController.m
//  Dynamics Demo
//
//  Created by Simon Whitaker on 23/03/2014.
//  Copyright (c) 2014 Netcetera. All rights reserved.
//

#import "SWAlertViewController.h"

@interface SWAlertViewController ()
@property (nonatomic) IBOutlet UIView *alertView;
@property (nonatomic) IBOutlet UIView *alertBackgroundView;
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIGravityBehavior *gravity;
@end

@implementation SWAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *alertView = self.alertView;
    alertView.layer.cornerRadius = 10.0;
    alertView.layer.masksToBounds = YES;
    
    // Configure the animator
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator = animator;
    
    // Configure the gravity behavior
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] init];
    gravity.magnitude = 4;
    [self.animator addBehavior:gravity];
    self.gravity = gravity;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.alertBackgroundView.alpha = 0.0;
}

- (IBAction)showAlertView:(id)sender {
    UIView *alertView = self.alertView;
    UIView *alertBackgroundView = self.alertBackgroundView;

    alertView.center = CGPointMake(alertBackgroundView.bounds.size.width/2, alertBackgroundView.bounds.size.height/2);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertBackgroundView.alpha = 1.0;
    }];
}

- (IBAction)dismissAlertView:(id)sender {
    UIView *alertView = self.alertView;
    UIView *alertBackgroundView = self.alertBackgroundView;
    
    [self.gravity addItem:alertView];
    
    __weak __typeof(self) weakSelf = self;
    self.gravity.action = ^{
        if (!CGRectIntersectsRect(alertView.frame, weakSelf.view.frame)) {
            [weakSelf.gravity removeItem:alertView];
            [UIView animateWithDuration:0.1 animations:^{
                alertBackgroundView.alpha = 0.0;
            }];
        }
    };
}

@end
