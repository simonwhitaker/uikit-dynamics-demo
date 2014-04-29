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

- (IBAction)handlePanGestureRecognizer:(UIPanGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIView *view = recognizer.view;
        CGPoint p = [recognizer locationInView:view];
        UIOffset offset = UIOffsetMake(p.x - view.bounds.size.width / 2, p.y - view.bounds.size.height / 2);
        self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:view offsetFromCenter:offset attachedToAnchor:[recognizer locationInView:self.view]];
        [self.animator addBehavior:self.attachmentBehavior];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint delta = [recognizer translationInView:self.view];
        self.attachmentBehavior.anchorPoint = CGPointApplyAffineTransform(self.attachmentBehavior.anchorPoint, CGAffineTransformMakeTranslation(delta.x, delta.y));
        [recognizer setTranslation:CGPointZero inView:self.view];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        [self.animator removeAllBehaviors];
    }
}

@end
