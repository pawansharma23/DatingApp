//
//  ChooseMatchView.m
//  Pandemos
//
//  Created by Michael Sevy on 4/25/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "ChooseMatchView.h"
#import "ImageLabelViews.h"
#import "User.h"

static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;

@interface ChooseMatchView ()
@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ImageLabelViews *cameraImageLabelView;
@property (nonatomic, strong) ImageLabelViews *interestsImageLabelView;
@property (nonatomic, strong) ImageLabelViews *friendsImageLabelView;
@end

@implementation ChooseMatchView

- (instancetype)initWithFrame:(CGRect)frame
                       user:(User *)user
                      options:(MDCSwipeToChooseViewOptions *)options
{
    self = [super initWithFrame:frame options:options];
    if (self)
    {
        _user = user;
        self.imageView.image = _user.image;

        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.autoresizingMask = self.autoresizingMask;

        [self constructInformationView];
    }

    return self;
}


- (void)constructInformationView
{
    CGFloat bottomHeight = 60.f;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    bottomHeight);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    _informationView.backgroundColor = [UIColor whiteColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];

    [self constructNameLabel];
    [self constructCameraImageLabelView];
    [self constructInterestsImageLabelView];
    [self constructFriendsImageLabelView];
}

- (void)constructNameLabel
{
    CGFloat leftPadding = 12.f;
    CGFloat topPadding = 17.f;
    CGRect frame = CGRectMake(leftPadding,
                              topPadding,
                              floorf(CGRectGetWidth(_informationView.frame)/2),
                              CGRectGetHeight(_informationView.frame) - topPadding);
    _nameLabel = [[UILabel alloc] initWithFrame:frame];
    _nameLabel.text = [NSString stringWithFormat:@"%@, %@", _user.username, _user.birthday];
    [_informationView addSubview:_nameLabel];
}

- (void)constructCameraImageLabelView
{
    CGFloat rightPadding = 10.f;
    UIImage *image = [UIImage imageNamed:@"gear-wheel-icon"];
    _cameraImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetWidth(_informationView.bounds) - rightPadding
                                                      image:image
                                                       text:_user.age];
    [_informationView addSubview:_cameraImageLabelView];
}

- (void)constructInterestsImageLabelView
{
    UIImage *image = [UIImage imageNamed:@"gear-wheel-icon"];
    _interestsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_cameraImageLabelView.frame)
                                                         image:image
                                                          text:_user.age];
    [_informationView addSubview:_interestsImageLabelView];
}

- (void)constructFriendsImageLabelView
{
    UIImage *image = [UIImage imageNamed:@"gear-wheel-icon"];
    _friendsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_interestsImageLabelView.frame)
                                                       image:image
                                                        text:_user.age];
    [_informationView addSubview:_friendsImageLabelView];
}

- (ImageLabelViews *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text
{
    CGRect frame = CGRectMake(x - ChoosePersonViewImageLabelWidth,
                              0,
                              ChoosePersonViewImageLabelWidth,
                              CGRectGetHeight(_informationView.bounds));
    ImageLabelViews *view = [[ImageLabelViews alloc] initWithFrame:frame
                                                           image:image
                                                            text:text];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return view;
}
@end
