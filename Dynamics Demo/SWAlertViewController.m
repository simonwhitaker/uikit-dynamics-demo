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
//@property (nonatomic) UIGravityBehavior *gravity;
@end

@implementation SWAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Give the alert view rounded corners. The kids these days love rounded corners.
    self.alertView.layer.cornerRadius = 10.0;
    self.alertView.layer.masksToBounds = YES;
    
    // Instantiate the animator
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Hide the semi-opaque background view. (The alert view is a subview of the background view, so this hides the alert view too.)
    self.alertBackgroundView.alpha = 0.0;
}

- (IBAction)showAlertView:(id)sender {
    // Position the alert view in the middle of its superview...
    self.alertView.center = CGPointMake(self.alertBackgroundView.bounds.size.width/2, self.alertBackgroundView.bounds.size.height/2);
    
    // ...then show it.
    [UIView animateWithDuration:0.2 animations:^{
        self.alertBackgroundView.alpha = 1.0;
    }];
}

- (IBAction)dismissAlertView:(id)sender {
    // Instantiate a gravity behavior
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.alertView]];
    
    // The default magnitude of 1 feels a bit sluggish, let's beef it up.
    gravity.magnitude = 4;
    
    // When the alert view goes out of view, stop animating and dismiss the semi-opaque background view
    __weak __typeof(self) weakSelf = self;
    gravity.action = ^{
        __typeof(weakSelf) strongSelf = weakSelf;
        if (!CGRectIntersectsRect(strongSelf.alertView.frame, strongSelf.alertBackgroundView.bounds)) {
            
            // Remove all behaviors from the animator; we don't need to animate anything now
            [strongSelf.animator removeAllBehaviors];
            
            // Dismiss the semi-opaque background view
            [UIView animateWithDuration:0.1 animations:^{
                strongSelf.alertBackgroundView.alpha = 0.0;
            }];
        }
    };
    
    [self.animator addBehavior:gravity];
}

@end
