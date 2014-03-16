//
//  SWViewController.m
//  Dynamics Demo
//
//  Created by Simon Whitaker on 16/03/2014.
//  Copyright (c) 2014 Netcetera. All rights reserved.
//

#import "SWViewController.h"

@interface SWViewController ()
@property (nonatomic) UIDynamicAnimator *animator;
@end

@implementation SWViewController

- (IBAction)dropIt:(id)sender {
    UIView *alertView = [self alertView];
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[alertView]];
    CGFloat floorY = alertView.frame.size.height;
    [collision addBoundaryWithIdentifier:@"floor" fromPoint:CGPointMake(0, floorY) toPoint:CGPointMake(CGRectGetMaxX(self.view.bounds), floorY)];
    [self.animator addBehavior:collision];
    
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[alertView]];
    [self.animator addBehavior:gravity];
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[alertView]];
    itemBehavior.elasticity = 0.5;
    [self.animator addBehavior:itemBehavior];
    
    [UIView animateWithDuration:0.2 delay:2.0 options:0 animations:^{
        alertView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
        [self.animator removeAllBehaviors];
    }];
}

- (UIView*)alertView {
    CGFloat height = 70;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -height, self.view.bounds.size.width, height)];
    view.backgroundColor = [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    [self.view addSubview:view];
    
    CGRect labelFrame = CGRectInset(view.bounds, 10, 10);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:17.0];
    label.text = @"No Internet Connection";
    
    [view addSubview:label];
    
    return view;
}

- (UIDynamicAnimator *)animator {
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    }
    return _animator;
}

@end
