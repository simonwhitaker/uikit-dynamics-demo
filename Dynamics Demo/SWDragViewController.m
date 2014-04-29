//
//  SWDragViewController.m
//  Dynamics Demo
//
//  Created by Simon Whitaker on 29/04/2014.
//  Copyright (c) 2014 Netcetera. All rights reserved.
//

#import "SWDragViewController.h"

@interface SWDragViewController ()
@property (nonatomic) UIDynamicAnimator *animator;
@property (nonatomic) UIAttachmentBehavior *attachmentBehavior;
@end

@implementation SWDragViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (IBAction)handlePanGestureRecognizer:(UIPanGestureRecognizer*)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *view = panGestureRecognizer.view;
        CGPoint p = [panGestureRecognizer locationInView:view];
        UIOffset offset = UIOffsetMake(p.x - view.bounds.size.width / 2, p.y - view.bounds.size.height / 2);
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view offsetFromCenter:offset attachedToAnchor:[panGestureRecognizer locationInView:self.view]];
        [self.animator addBehavior:self.attachmentBehavior];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = [panGestureRecognizer translationInView:self.view];
        self.attachmentBehavior.anchorPoint = CGPointApplyAffineTransform(self.attachmentBehavior.anchorPoint, CGAffineTransformMakeTranslation(delta.x, delta.y));
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state == UIGestureRecognizerStateCancelled || panGestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self.animator removeAllBehaviors];
    }
}

@end
