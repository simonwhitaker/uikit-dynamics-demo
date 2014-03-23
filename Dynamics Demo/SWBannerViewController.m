//
//  SWViewController.m
//  Dynamics Demo
//
//  Created by Simon Whitaker on 16/03/2014.
//  Copyright (c) 2014 Netcetera. All rights reserved.
//

#import "SWBannerViewController.h"

@interface SWBannerViewController ()
@property (nonatomic, weak) IBOutlet UIView *bannerView;
@property (nonatomic, weak) IBOutlet UILabel *bangLabel;
@property (nonatomic) UIDynamicAnimator *animator;
@end

@implementation SWBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIView *bangLabel = self.bangLabel;
    bangLabel.layer.cornerRadius = bangLabel.bounds.size.width / 2;
}

- (void)viewWillAppear:(BOOL)animated {
    [self resetBanner];
}

- (IBAction)showBanner:(id)sender {
    UIView *bannerView = self.bannerView;
    
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[bannerView]];
    CGFloat floorY = bannerView.frame.size.height;
    [collision addBoundaryWithIdentifier:@"floor" fromPoint:CGPointMake(0, floorY) toPoint:CGPointMake(CGRectGetMaxX(self.view.bounds), floorY)];
    [self.animator addBehavior:collision];
    
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[bannerView]];
    [self.animator addBehavior:gravity];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[bannerView]];
    itemBehavior.elasticity = 0.5;
    [self.animator addBehavior:itemBehavior];
    
    [UIView animateWithDuration:0.2 delay:2.0 options:0 animations:^{
        bannerView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.animator removeAllBehaviors];
        [self resetBanner];
    }];
}

- (void)resetBanner {
    UIView *bannerView = self.bannerView;
    CGRect bannerFrame = bannerView.frame;
    bannerFrame.origin.y = 0 - bannerFrame.size.height;
    bannerView.frame = bannerFrame;
    
    bannerView.alpha = 1.0;
}

@end
