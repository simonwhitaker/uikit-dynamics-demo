//
//  SWViewController.m
//  Dynamics Demo
//
//  Created by Simon Whitaker on 16/03/2014.
//  Copyright (c) 2014 Netcetera. All rights reserved.
//

#import "SWBannerViewController.h"

@interface SWBannerViewController () <UIDynamicAnimatorDelegate>
@property (nonatomic) IBOutlet UIView *bannerView;
@property (nonatomic) IBOutlet UILabel *bangLabel;
@property (nonatomic) UIDynamicAnimator *animator;
@end

@implementation SWBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator.delegate = self;
    
    self.bangLabel.layer.cornerRadius = self.bangLabel.bounds.size.width / 2;
    self.bangLabel.textColor = self.bannerView.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [self resetBanner];
}

- (IBAction)showBanner:(id)sender {
    [self.animator removeAllBehaviors];
    
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.bannerView]];
    CGFloat boundaryY = self.bannerView.frame.size.height;
    [collision addBoundaryWithIdentifier:@"floor" fromPoint:CGPointMake(0, boundaryY) toPoint:CGPointMake(CGRectGetMaxX(self.view.bounds), boundaryY)];
    [self.animator addBehavior:collision];
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.bannerView]];
    [self.animator addBehavior:gravity];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.bannerView]];
    itemBehavior.elasticity = 0.4;
    [self.animator addBehavior:itemBehavior];
}

- (void)resetBanner {
    CGRect bannerFrame = self.bannerView.frame;
    bannerFrame.origin.y = 0 - bannerFrame.size.height;
    self.bannerView.frame = bannerFrame;
}

#pragma mark - UIDynamicAnimatorDelegate methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    [animator removeAllBehaviors];
    
    // Wait a couple of seconds, then dismiss the banner
    [UIView animateWithDuration:0.2 delay:2.0 options:0 animations:^{
        [self resetBanner];
    } completion:nil];
}

@end
