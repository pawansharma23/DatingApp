//
//  ProfileImageView.h
//  Pandemos
//
//  Created by Michael Sevy on 6/3/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileImageViewDelegate <NSObject>

@end

@interface ProfileImageView : UIView<UIScrollViewDelegate>

@property (weak) id <ProfileImageViewDelegate> delegate;

@property (nonatomic, strong)UIScrollView *imageScroll;

@property (nonatomic, strong)UIView *descriptionView;
@property (nonatomic,strong)UILabel *nameLabel; //%%% a placeholder for any card-specific information
@property (nonatomic,strong)UILabel *schoolLabel; //%%% a placeholder for any card-specific information

@property (nonatomic,strong)UIImageView* profileImageView;
@property (nonatomic,strong)UIImageView* profileImageView2;
@property (nonatomic,strong)UIImageView* profileImageView3;
@property (nonatomic,strong)UIImageView* profileImageView4;
@property (nonatomic,strong)UIImageView* profileImageView5;
@property (nonatomic,strong)UIImageView* profileImageView6;
@property (nonatomic,strong)UIButton *b1;
@property (nonatomic,strong)UIButton *b2;
@property (nonatomic,strong)UIButton *b3;
@property (nonatomic,strong)UIButton *b4;
@property (nonatomic,strong)UIButton *b5;
@property (nonatomic,strong)UIButton *b6;
@property (nonatomic,strong)NSNumber *imageCount;
@property (nonatomic,strong)UIView *v1;

@property int count;
@end
