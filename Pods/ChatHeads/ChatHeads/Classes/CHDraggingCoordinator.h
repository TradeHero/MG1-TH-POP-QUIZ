//
//  CHDraggingCoordinator.h
//  ChatHeads
//
//  Created by Matthias Hochgatterer on 4/19/13.
//  Copyright (c) 2013 Matthias Hochgatterer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CHDraggableView.h"

typedef enum {
    CHSnappingEdgeBoth,
    CHSnappingEdgeRight,
    CHSnappingEdgeLeft
} CHSnappingEdge;

@class CHDraggingCoordinator;
typedef void(^CHDraggingCoordinatorActionBlock)(CHDraggingCoordinator*, CHDraggableView*);


@protocol CHDraggingCoordinatorDelegate;
@interface CHDraggingCoordinator : NSObject <CHDraggableViewDelegate>

@property (nonatomic) CHSnappingEdge snappingEdge;
@property (nonatomic, weak) id<CHDraggingCoordinatorDelegate> delegate;
@property (nonatomic, copy) CHDraggingCoordinatorActionBlock actionBlock;       // use this action block instead of the delegate draggingCoordinator:viewControllerForDraggableView: method (if actionBlock exists, it gets called instead of the delegate)

- (instancetype)initWithWindow:(UIWindow *)window draggableViewBounds:(CGRect)bounds;
- (instancetype)initWithWindow:(UIWindow *)window draggableViewBounds:(CGRect)bounds closeView:(UIView *)closeView;

@end

@protocol CHDraggingCoordinatorDelegate <NSObject>

- (UIViewController *)draggingCoordinator:(CHDraggingCoordinator *)coordinator viewControllerForDraggableView:(CHDraggableView *)draggableView;

@end
