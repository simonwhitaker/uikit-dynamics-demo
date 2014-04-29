//
//  SWDragViewController.m
//  Dynamics Demo
//
//  Created by Simon Whitaker on 29/04/2014.
//  Copyright (c) 2014 Netcetera. All rights reserved.
//

#import "SWDragViewController.h"

static const CGFloat kDismissalSwipeVelocityThreshold = 100.0;

@interface SWDragViewController () <UIDynamicAnimatorDelegate>
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic) UIView *largeImageBackgroundView;
@property (nonatomic) UIImageView *largeImageView;
@property (nonatomic) IBOutlet UIImageView *sourceImageView;
@end

@implementation SWDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

/// Handle a tap on the source image. This displays the large image above a semi-opaque background
- (IBAction)handleTap:(UITapGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded && !self.largeImageBackgroundView) {

        // Create a semi-opaque background view between the source image and the large image
        self.largeImageBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.largeImageBackgroundView.backgroundColor = [UIColor blackColor];
        self.largeImageBackgroundView.alpha = 0;
        self.largeImageBackgroundView.userInteractionEnabled = NO;
        [self.view addSubview:self.largeImageBackgroundView];
        
        // Create a copy of the image view for large display
        UIImageView *sourceImageView = (UIImageView*)recognizer.view;
        self.largeImageView = [[UIImageView alloc] initWithFrame:sourceImageView.frame];
        self.largeImageView.image = sourceImageView.image;
        [self.view addSubview:self.largeImageView];
        
        CGFloat animationDuration = 0.5;
        
        // Note that this UIView class method which gives a springy animation is nothing to do with UIKit Dynamics.
        [UIView animateWithDuration:animationDuration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:0 animations:^{
            self.largeImageView.bounds = CGRectMake(0, 0, 300, 200);
        } completion:^(BOOL finished) {
            self.largeImageView.userInteractionEnabled = YES;
            [self.largeImageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
        }];

        [UIView animateWithDuration:animationDuration animations:^{
            self.largeImageBackgroundView.alpha = 0.8;
        }];
    }
}

- (IBAction)handlePan:(UIPanGestureRecognizer*)recognizer {
    UIView *view = recognizer.view;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Make sure any existing behaviors are removed before adding new ones
        [self.animator removeAllBehaviors];
        
        CGPoint p = [recognizer locationInView:view];
        UIOffset offset = UIOffsetMake(p.x - view.bounds.size.width / 2, p.y - view.bounds.size.height / 2);
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view offsetFromCenter:offset attachedToAnchor:[recognizer locationInView:self.view]];
        [self.animator addBehavior:self.attachmentBehavior];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = [recognizer translationInView:self.view];
        self.attachmentBehavior.anchorPoint = CGPointApplyAffineTransform(self.attachmentBehavior.anchorPoint, CGAffineTransformMakeTranslation(delta.x, delta.y));
        [recognizer setTranslation:CGPointZero inView:self.view];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        CGPoint velocity = [recognizer velocityInView:self.view];

        [self.animator removeBehavior:self.attachmentBehavior];
        
        // If velocity in simple points/second is higher than a threshold, animate off screen
        if (sqrt(velocity.x * velocity.x + velocity.y * velocity.y) > kDismissalSwipeVelocityThreshold) {
            UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
            [itemBehavior addLinearVelocity:velocity forItem:view];
            
            UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[view]];
            gravity.magnitude = 4;
            [self.animator addBehavior:itemBehavior];
            [self.animator addBehavior:gravity];
            
            // Stop animating and dismiss the background view when the large view goes offscreen
            __weak typeof(self) weakSelf = self;
            __weak typeof(gravity) weakGravity = gravity;
            gravity.action = ^{
                if (!CGRectIntersectsRect(weakSelf.view.bounds, view.frame)) {
                    [weakSelf.animator removeBehavior:weakGravity];
                    [weakSelf dismissBackgroundView];
                }
            };
        } else {
            // Snap back to home position
            UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:self.sourceImageView.center];
            [self.animator addBehavior:snapBehavior];
        }
    }
}

- (void)dismissBackgroundView {
    [UIView animateWithDuration:0.3 animations:^{
        self.largeImageBackgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.largeImageBackgroundView removeFromSuperview];
        self.largeImageBackgroundView = nil;
    }];
}

@end
