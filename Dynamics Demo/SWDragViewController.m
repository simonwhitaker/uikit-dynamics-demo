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
        
        // Get the point of the touch within the view we're dragging, and use that point as the connection point for the attachment behavior. In other words, it makes a difference whether you drag from the edge of the view or the center, just as it would if you dragged a real object around on a table top.
        CGPoint p = [recognizer locationInView:view];
        UIOffset offset = UIOffsetMake(p.x - view.bounds.size.width / 2, p.y - view.bounds.size.height / 2);
        
        // Create an attachment behavior that connects the point we first dragged to an anchor point. We'll update the anchor point as we drag, and let UIKit Dynamics do the rest.
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view offsetFromCenter:offset attachedToAnchor:[recognizer locationInView:self.view]];
        [self.animator addBehavior:self.attachmentBehavior];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Just move the attachment behavior's anchor point, let UIKit Dynamics animate the view accordingly.
        CGPoint delta = [recognizer translationInView:self.view];
        self.attachmentBehavior.anchorPoint = CGPointApplyAffineTransform(self.attachmentBehavior.anchorPoint, CGAffineTransformMakeTranslation(delta.x, delta.y));
        [recognizer setTranslation:CGPointZero inView:self.view];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        // Check the velocity we were dragging at.
        CGPoint velocity = [recognizer velocityInView:self.view];

        [self.animator removeBehavior:self.attachmentBehavior];
        
        // If velocity in simple points/second is higher than a threshold, fling the view offscreen
        if (sqrt(velocity.x * velocity.x + velocity.y * velocity.y) > kDismissalSwipeVelocityThreshold) {
            // Use a UIDynamicItemBehavior to continue the view moving with the same velocity as when we finished dragging
            UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
            [itemBehavior addLinearVelocity:velocity forItem:view];

            // Stop animating and dismiss the background view when the large view goes offscreen
            __weak __typeof(self) weakSelf = self;
            __weak __typeof(itemBehavior) weakItemBehavior = itemBehavior;
            itemBehavior.action = ^{
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                __strong __typeof(weakItemBehavior) strongItemBehavior = weakItemBehavior;
                if (!CGRectIntersectsRect(weakSelf.view.bounds, view.frame)) {
                    [strongSelf.animator removeBehavior:strongItemBehavior];
                    [strongSelf dismissBackgroundView];
                }
            };
            [self.animator addBehavior:itemBehavior];
        } else {
            // They didn't fling the view with sufficient vim, so just snap it back into place
            UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:self.sourceImageView.center];
            snapBehavior.damping = 1;
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
