//
//  DraggableView.h
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests


#import <UIKit/UIKit.h>
#import "OverlayView.h"
#import "ImageScroll.h"
#import "DraggableViewBackground.h"

@protocol DraggableViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
@end

@interface DraggableView : UIView<UIScrollViewDelegate>

@property (weak) id <DraggableViewDelegate> delegate;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic,strong)UIImageView *profileImageView;
@property (nonatomic,strong)OverlayView* overlayView;
@property (nonatomic,strong)UILabel *information;
@property (nonatomic,strong)UILabel *schoolLabel;
@property (nonatomic,strong)UIButton *b1;
@property (nonatomic,strong)UIButton *b2;
@property (nonatomic,strong)UIButton *b3;
@property (nonatomic,strong)UIButton *b4;
@property (nonatomic,strong)UIButton *b5;
@property (nonatomic,strong)UIButton *b6;
@property (nonatomic,strong)UIButton *noButton;
@property (nonatomic,strong)UIButton *yesButton;
@property (nonatomic, strong)ImageScroll *imageScroll;

-(void)leftClickAction;
-(void)rightClickAction;
@end
