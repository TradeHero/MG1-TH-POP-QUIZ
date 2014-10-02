//
//  CHDraggingCoordinator.m
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import "CHDraggingCoordinator.h"
#import <QuartzCore/QuartzCore.h>
#import "CHDraggableView.h"
#import "CHAvatarView.h"

typedef enum {
    CHInteractionStateNormal,
    CHInteractionStateConversation
} CHInteractionState;

@interface CHDraggingCoordinator ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableDictionary *edgePointDictionary;;
@property (nonatomic, assign) CGRect draggableViewBounds;
@property (nonatomic, assign) CHInteractionState state;
@property (nonatomic, strong) UINavigationController *presentedNavigationController;
@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *closeView;                // view on center bottom - drag the draggable view on top of it to make it go away
@property (nonatomic, assign) CGSize closeViewSize;

@end


@implementation CHDraggingCoordinator

- (instancetype)initWithWindow:(UIWindow *)window draggableViewBounds:(CGRect)bounds
{
    UIView *aCloseView = [[UIView alloc] initWithFrame:bounds];
    aCloseView.layer.cornerRadius = 30;
    aCloseView.backgroundColor = [UIColor lightGrayColor];
    aCloseView.alpha = 0.8;
    
    return [self initWithWindow:window draggableViewBounds:bounds closeView:aCloseView];
}

- (instancetype)initWithWindow:(UIWindow *)window draggableViewBounds:(CGRect)bounds closeView:(UIView *)closeView
{
    self = [super init];
    if (self) {
        _window = window;
        _draggableViewBounds = bounds;
        _state = CHInteractionStateNormal;
        _edgePointDictionary = [NSMutableDictionary dictionary];
        
        _closeView = closeView;
        _closeViewSize = closeView.frame.size;
        _closeView.frame = [self _closeViewOnScreenRect];
    }
    return self;
}

#pragma mark - Geometry

- (CGRect)_closeViewOnEnterScreenRect {
    CGRect superviewBounds = self.closeView.superview ? self.closeView.superview.bounds : [[self.window subviews][0] bounds];
    
    CGPoint center = CGPointMake(CGRectGetMidX(superviewBounds), CGRectGetMaxY(superviewBounds));
    CGRect enterScreenRect = CGRectMake(center.x - round(self.closeViewSize.width / 2),
                                        center.y - round(self.closeViewSize.height / 2),
                                        self.closeViewSize.width,
                                        self.closeViewSize.height);
    
    return enterScreenRect;
}

- (CGRect)_closeViewOnScreenRect {
    CGRect superviewBounds = self.closeView.superview.bounds;
    
    CGPoint center = CGPointMake(CGRectGetMidX(superviewBounds), CGRectGetMaxY(superviewBounds));
    CGRect onScreenRect = CGRectMake(center.x - round(self.closeViewSize.width / 2),
                                     center.y - round(self.closeViewSize.height / 2) - 20 - self.draggableViewBounds.size.height,
                                     self.closeViewSize.width,
                                     self.closeViewSize.height);
    
    return onScreenRect;
}

- (CGRect)_closeViewEnlargedRect {
    CGRect superviewBounds = self.closeView.superview.bounds;
    
    CGPoint center = CGPointMake(CGRectGetMidX(superviewBounds), CGRectGetMaxY(superviewBounds));
    
    // extend width and height by preserving center position
    CGFloat delta = 10;
    CGRect enlargedRect = CGRectMake(center.x - round(self.closeViewSize.width / 2) - delta,
                                     center.y - round(self.closeViewSize.height / 2) - 20 - self.draggableViewBounds.size.height - delta,
                                     self.closeViewSize.width + 2 * delta,
                                     self.closeViewSize.height + 2 * delta);
    
    return enlargedRect;
}

- (CGRect)_dropArea
{
    return CGRectInset([self.window.screen applicationFrame], -(int)(CGRectGetWidth(_draggableViewBounds)/6), 0);
}

- (CGRect)_conversationArea
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide([self.window.screen applicationFrame], &slice, &remainder, CGRectGetHeight(CGRectInset(_draggableViewBounds, -10, 0)), CGRectMinYEdge);
    return slice;
}

- (CGRectEdge)_destinationEdgeForReleasePointInCurrentState:(CGPoint)releasePoint
{
    if (_state == CHInteractionStateConversation) {
        return CGRectMinYEdge;
    } else if(_state == CHInteractionStateNormal) {
        return releasePoint.x < CGRectGetMidX([self _dropArea]) ? CGRectMinXEdge : CGRectMaxXEdge;
    }
    NSAssert(false, @"State not supported");
    return CGRectMinYEdge;
}

- (CGPoint)_destinationPointForReleasePoint:(CGPoint)releasePoint
{
    CGRect dropArea = [self _dropArea];
    
    CGFloat midXDragView = CGRectGetMidX(_draggableViewBounds);
    CGRectEdge destinationEdge = [self _destinationEdgeForReleasePointInCurrentState:releasePoint];
    CGFloat destinationY;
    CGFloat destinationX;
    
    CGFloat topYConstraint = CGRectGetMinY(dropArea) + CGRectGetMidY(_draggableViewBounds);
    CGFloat bottomYConstraint = CGRectGetMaxY(dropArea) - CGRectGetMidY(_draggableViewBounds);
    if (releasePoint.y < topYConstraint) { // Align ChatHead vertically
        destinationY = topYConstraint;
    }else if (releasePoint.y > bottomYConstraint) {
        destinationY = bottomYConstraint;
    }else {
        destinationY = releasePoint.y;
    }
    
    if (self.snappingEdge == CHSnappingEdgeBoth){   //ChatHead will snap to both edges
        if (destinationEdge == CGRectMinXEdge) {
            destinationX = CGRectGetMinX(dropArea) + midXDragView;
        } else {
            destinationX = CGRectGetMaxX(dropArea) - midXDragView;
        }
        
    }else if(self.snappingEdge == CHSnappingEdgeLeft){  //ChatHead will snap only to left edge
        destinationX = CGRectGetMinX(dropArea) + midXDragView;
        
    }else{  //ChatHead will snap only to right edge
        destinationX = CGRectGetMaxX(dropArea) - midXDragView;
    }
    
    return CGPointMake(destinationX, destinationY);
}

#pragma mark - Dragging

- (void)draggableViewHold:(CHDraggableView *)view
{
    // make sure the close view is positioned at the entry screen position
    self.closeView.frame = [self _closeViewOnEnterScreenRect];
    
    // then animate it to on screen position and add it
    [UIView transitionWithView:self.window
                      duration:0.4
                       options:UIViewAnimationOptionCurveEaseIn
                    animations:^ {
                        [[self.window subviews][0] insertSubview:self.closeView belowSubview:view];
                        self.closeView.frame = [self _closeViewOnScreenRect];
                    }
                    completion:nil];
}

- (BOOL)shouldRemoveDraggableView:(CHDraggableView *)view
{
    // this determines if based on the draggable and close view positions, the draggable should be closed aka removed
    return CGRectIntersectsRect(view.frame, self.closeView.frame);
}

- (void)draggableView:(CHDraggableView *)view didMoveToPoint:(CGPoint)point
{
    CGRect frame = CGRectZero;
    if ([self shouldRemoveDraggableView:view]) {
        frame = [self _closeViewEnlargedRect];
    } else {
        frame = [self _closeViewOnScreenRect];
    }
    
    if (!CGRectEqualToRect(frame, self.closeView.frame)) {
        [UIView animateWithDuration:0.2 animations:^{
            self.closeView.frame = frame;
        }];
    }
    
    if (_state == CHInteractionStateConversation) {
        if (_presentedNavigationController) {
            [self _dismissPresentedNavigationController];
        }
    }
}

- (void)draggableViewReleased:(CHDraggableView *)view
{
    BOOL shouldRemoveDraggableView = [self shouldRemoveDraggableView:view];
    
    // in case we will remove the draggable, no need to do anything else
    if (!shouldRemoveDraggableView) {
        if (_state == CHInteractionStateNormal) {
            [self _animateViewToEdges:view];
        } else if(_state == CHInteractionStateConversation) {
            [self _animateViewToConversationArea:view];
            [self _presentViewControllerForDraggableView:view];
        }
    }
    
    // animation: the close view dissapears. If draggable needs to dissapear as well, make it happen in the same animation
    [UIView transitionWithView:self.window
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^ {
                        self.closeView.frame = [self _closeViewOnEnterScreenRect];
                        if (shouldRemoveDraggableView) {
                            CGRect frame = view.frame;
                            frame.origin.y = self.closeView.frame.origin.y;
                            frame.origin.x = self.closeView.frame.origin.x;
                            view.frame = frame;
                        }
                    }
                    completion:^(BOOL finished) {
                        [self.closeView removeFromSuperview];
                        if (shouldRemoveDraggableView) {
                            [view removeFromSuperview];
                        }
                    }];
}

- (void)draggableViewTouched:(CHDraggableView *)view
{
    if (_state == CHInteractionStateNormal) {
        if (!self.actionBlock) {
            _state = CHInteractionStateConversation;
            [self _animateViewToConversationArea:view];
        }
        
        [self _presentViewControllerForDraggableView:view];
    } else if(_state == CHInteractionStateConversation) {
        _state = CHInteractionStateNormal;
        NSValue *knownEdgePoint = [_edgePointDictionary objectForKey:@(view.tag)];
        if (knownEdgePoint) {
            [self _animateView:view toEdgePoint:[knownEdgePoint CGPointValue]];
        } else {
            [self _animateViewToEdges:view];
        }
        [self _dismissPresentedNavigationController];
    }
}

#pragma mark - Alignment

- (void)draggableViewNeedsAlignment:(CHDraggableView *)view
{
    NSLog(@"Align view");
    [self _animateViewToEdges:view];
}

#pragma mark Dragging Helper

- (void)_animateViewToEdges:(CHDraggableView *)view
{
    CGPoint destinationPoint = [self _destinationPointForReleasePoint:view.center];
    [self _animateView:view toEdgePoint:destinationPoint];
}

- (void)_animateView:(CHDraggableView *)view toEdgePoint:(CGPoint)point
{
    [_edgePointDictionary setObject:[NSValue valueWithCGPoint:point] forKey:@(view.tag)];
    [view snapViewCenterToPoint:point edge:[self _destinationEdgeForReleasePointInCurrentState:view.center]];
}

- (void)_animateViewToConversationArea:(CHDraggableView *)view
{
    CGRect conversationArea = [self _conversationArea];
    CGPoint center = CGPointMake(CGRectGetMidX(conversationArea), CGRectGetMidY(conversationArea));
    [view snapViewCenterToPoint:center edge:[self _destinationEdgeForReleasePointInCurrentState:view.center]];
}

#pragma mark - View Controller Handling

- (CGRect)_navigationControllerFrame
{
    CGRect slice;
    CGRect remainder;
    CGRectDivide([self.window.screen applicationFrame], &slice, &remainder, CGRectGetMaxY([self _conversationArea]), CGRectMinYEdge);
    return remainder;
}

- (CGRect)_navigationControllerHiddenFrame
{
    return CGRectMake(CGRectGetMidX([self _conversationArea]), CGRectGetMaxY([self _conversationArea]), 0, 0);
}

- (void)_presentViewControllerForDraggableView:(CHDraggableView *)draggableView
{
    if (_actionBlock) {
        [self.closeView removeFromSuperview];
        _actionBlock(self, draggableView);
    } else {
        UIViewController *viewController = [_delegate draggingCoordinator:self viewControllerForDraggableView:draggableView];
        
        _presentedNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        _presentedNavigationController.view.layer.cornerRadius = 3;
        _presentedNavigationController.view.layer.masksToBounds = YES;
        _presentedNavigationController.view.layer.anchorPoint = CGPointMake(0.5f, 0);
        _presentedNavigationController.view.frame = [self _navigationControllerFrame];
        _presentedNavigationController.view.transform = CGAffineTransformMakeScale(0, 0);
        
        [self.window insertSubview:_presentedNavigationController.view belowSubview:draggableView];
        [self _unhidePresentedNavigationControllerCompletion:^{}];
    }
}

- (void)_dismissPresentedNavigationController
{
    UINavigationController *reference = _presentedNavigationController;
    [self _hidePresentedNavigationControllerCompletion:^{
        [reference.view removeFromSuperview];
    }];
    _presentedNavigationController = nil;
}

- (void)_unhidePresentedNavigationControllerCompletion:(void(^)())completionBlock
{
    CGAffineTransform transformStep1 = CGAffineTransformMakeScale(1.1f, 1.1f);
    CGAffineTransform transformStep2 = CGAffineTransformMakeScale(1, 1);
    
    _backgroundView = [[UIView alloc] initWithFrame:[self.window bounds]];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5f];
    _backgroundView.alpha = 0.0f;
    [self.window insertSubview:_backgroundView belowSubview:_presentedNavigationController.view];
    
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _presentedNavigationController.view.layer.affineTransform = transformStep1;
        _backgroundView.alpha = 1.0f;
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.3f animations:^{
                _presentedNavigationController.view.layer.affineTransform = transformStep2;
            }];
        }
    }];
}

- (void)_hidePresentedNavigationControllerCompletion:(void(^)())completionBlock
{
    UIView *viewToDisplay = _backgroundView;
    [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _presentedNavigationController.view.transform = CGAffineTransformMakeScale(0, 0);
        _presentedNavigationController.view.alpha = 0.0f;
        _backgroundView.alpha = 0.0f;
    } completion:^(BOOL finished){
        if (finished) {
            [viewToDisplay removeFromSuperview];
            if (viewToDisplay == _backgroundView) {
                _backgroundView = nil;
            }
            completionBlock();
        }
    }];
}

@end
