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
@property (nonatomic,strong)UIButton *noButton;
@property (nonatomic,strong)UIButton *yesButton;
@property (nonatomic, strong)ImageScroll *imageScroll;
@property (nonatomic, strong)UIView *matchDescView;
@property (nonatomic,strong)OverlayView* overlayView;
@property (nonatomic,strong)UILabel *information;
@property (nonatomic,strong)UILabel *schoolLabel;

@property (nonatomic,strong)UIImageView* profileImageView;
@property (nonatomic,strong)UIImageView* profileImageView2;
@property (nonatomic,strong)UIImageView* profileImageView3;
@property (nonatomic,strong)UIImageView* profileImageView4;
@property (nonatomic,strong)UIImageView* profileImageView5;
@property (nonatomic,strong)UIImageView* profileImageView6;

@property (nonatomic,strong)UIView *v1;
@property (nonatomic,strong)UIView *v2;
@property (nonatomic,strong)UIView *v3;
@property (nonatomic,strong)UIView *v4;
@property (nonatomic,strong)UIView *v5;
@property (nonatomic,strong)UIView *v6;
@property unsigned long imageCount;

-(void)leftClickAction;
-(void)rightClickAction;
@end
