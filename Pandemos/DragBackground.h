//
//  DragBackground.h
//  Pandemos
//
//  Created by Michael Sevy on 6/8/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DragView.h"
#import "UserManager.h"

@interface DragBackground : UIView <DragViewDelegate>

//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;

@property (retain,nonatomic)NSArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards
@property (strong, nonatomic) DragView *dragView;

@end
