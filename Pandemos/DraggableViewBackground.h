//
//  DraggableViewBackground.h
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "DraggableView.h"
#import "User.h"
#import "UserManager.h"

@protocol DraggableViewBackgroundDelegate <NSObject>

-(void)didFetchImagesForMatchedProfile:(NSArray*)profileImages;
@end

@interface DraggableViewBackground : UIView <UserManagerDelegate>

//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
//-(void)profileImages:(NSArray*)profileImages;

@property (retain, nonatomic) NSArray<User*> *potentialMatchData;
@property (retain, nonatomic) NSMutableArray* allCards; //%%% the labels the card

@property (weak) id <DraggableViewBackgroundDelegate> delegate;
@end
