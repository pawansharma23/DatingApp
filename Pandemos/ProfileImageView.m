//
//  ProfileImageView.m
//  Pandemos
//
//  Created by Michael Sevy on 6/3/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "ProfileImageView.h"
#import "AppConstants.h"
#import "UIColor+Pandemos.h"

@implementation ProfileImageView

static float CARD_HEIGHT;
static float CARD_WIDTH;

@synthesize delegate;

@synthesize imageScroll;
@synthesize schoolLabel;
@synthesize nameLabel;
@synthesize descriptionView;
@synthesize profileImageView;
@synthesize profileImageView2;
@synthesize profileImageView3;
@synthesize profileImageView4;
@synthesize profileImageView5;
@synthesize profileImageView6;
@synthesize b1;
@synthesize b2;
@synthesize b3;
@synthesize b4;
@synthesize b5;
@synthesize b6;
@synthesize v1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];

        if (IS_IPHONE4)
        {
            CARD_HEIGHT = 400;
            CARD_WIDTH = 280;
        }
        else if (IS_IPHONE5)
        {
            CARD_WIDTH = 280;
            CARD_HEIGHT = 500;
        }
        else if (IS_IPHONE6)
        {
            CARD_WIDTH = 376;
            CARD_HEIGHT = 676;
        }
        else if (IS_IPHONE6PLUS)
        {
            CARD_WIDTH = 390;
            CARD_HEIGHT = 680;
        }

        imageScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, self.frame.size.width, self.frame.size.height)];
        [self addSubview:imageScroll];
        imageScroll.delegate = self;
        imageScroll.pagingEnabled = YES;
        imageScroll.scrollEnabled = YES;
        imageScroll.clipsToBounds = NO;
        imageScroll.userInteractionEnabled = YES;
        imageScroll.scrollsToTop = NO;
        //imageScroll.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 3);//multiplied by pro

        profileImageView = [UIImageView new];
        [imageScroll addSubview:profileImageView];
        profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView.backgroundColor = [UIColor blackColor];
        [self addProfileImage1Constraints];

        profileImageView2 = [UIImageView new];
        [imageScroll addSubview:profileImageView2];
        profileImageView2.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView2.backgroundColor = [UIColor redColor];
        [self addProfileImage2Constraints];

        profileImageView3 = [UIImageView new];
        [imageScroll addSubview:profileImageView3];
        profileImageView3.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView3.backgroundColor = [UIColor greenColor];
        [self addProfileImage3Constraints];

        profileImageView4 = [UIImageView new];
        [imageScroll addSubview:profileImageView4];
        profileImageView4.translatesAutoresizingMaskIntoConstraints = NO;
        [self addProfileImage4Constraints];

        profileImageView5 = [UIImageView new];
        [imageScroll addSubview:profileImageView5];
        profileImageView5.translatesAutoresizingMaskIntoConstraints = NO;
        [self addProfileImage5Constraints];

        profileImageView6 = [UIImageView new];
        [imageScroll addSubview:profileImageView6];
        profileImageView6.translatesAutoresizingMaskIntoConstraints = NO;
        [self addProfileImage6Constraints];

//        b1 = [UIButton new];
//        [self addSubview:b1];
//        [self addButton1Constraints];
//        [self setforButton:b1];
        v1 = [UIView new];
        [self addSubview:v1];
        v1.translatesAutoresizingMaskIntoConstraints = NO;
        v1.layer.cornerRadius = 6;
        v1.layer.masksToBounds = YES;
        v1.layer.borderWidth = 1.0;
        v1.layer.borderColor = [UIColor blackColor].CGColor;
        [self addView1Constraints];

        b2 = [UIButton new];
        [self addSubview:b2];
        [self addButton2Constraints];
        [self setforButton:b2];

        b3 = [UIButton new];
        [self addSubview:b3];
        [self addButton3Constraints];
        [self setforButton:b3];

        b4 = [UIButton new];
        [self addSubview:b4];
        [self addButton4Constraints];
        [self setforButton:b4];

        b5 = [UIButton new];
        [self addSubview:b5];
        [self addButton5Constraints];
        [self setforButton:b5];

//        b6 = [UIButton new];
//        [self addSubview:b6];
//        [self addButton6Constraints];
//        [self setforButton:b6];

        descriptionView = [UIView new];
        [self addSubview:descriptionView];
        descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
        descriptionView.layer.cornerRadius = 8;
        descriptionView.backgroundColor = [UIColor grayColor];
        [self addDescriptionViewConstraints];

        nameLabel = [UILabel new];
        [descriptionView addSubview:nameLabel];
        nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [nameLabel setFont:[UIFont fontWithName:@"GeezaPro" size:18.0]];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self addNameLabelConstraints];

        schoolLabel = [UILabel new];
        [descriptionView addSubview:schoolLabel];
        schoolLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [schoolLabel setFont:[UIFont fontWithName:@"GeezaPro" size:16.0]];
        schoolLabel.lineBreakMode = NSLineBreakByWordWrapping;
        schoolLabel.numberOfLines = 0;
        [schoolLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSchoolLabelConstraints];
    }

    return self;
}

-(void)setupView
{
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

-(void)setforButton:(UIButton*)button
{
    [imageScroll addSubview:button];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor yellowGreen].CGColor;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //static NSInteger previousPage = 0;
    CGFloat pageHeight = scrollView.frame.size.height;
    float fractionalPage = scrollView.contentOffset.y / pageHeight;
    NSInteger page = lround(fractionalPage);

    switch (page)
    {
        case 0:
            [b1 setBackgroundColor:[UIColor whiteColor]];
            [b2 setBackgroundColor:nil];
            [b3 setBackgroundColor:nil];
            [b4 setBackgroundColor:nil];
            [b5 setBackgroundColor:nil];
            [b6 setBackgroundColor:nil];

            break;
        case 1:
            [b1 setBackgroundColor:nil];
            [b2 setBackgroundColor:[UIColor whiteColor]];
            [b3 setBackgroundColor:nil];
            [b4 setBackgroundColor:nil];
            [b5 setBackgroundColor:nil];
            [b6 setBackgroundColor:nil];
            break;
        case 2:
            [b1 setBackgroundColor:nil];
            [b3 setBackgroundColor:[UIColor whiteColor]];
            [b2 setBackgroundColor:nil];
            [b4 setBackgroundColor:nil];
            [b5 setBackgroundColor:nil];
            [b6 setBackgroundColor:nil];
            break;
        case 3:
            [b3 setBackgroundColor:[UIColor whiteColor]];
            break;
        case 4:
            [b4 setBackgroundColor:[UIColor whiteColor]];
            break;
        case 5:
            [b5 setBackgroundColor:[UIColor whiteColor]];
            break;
        case 6:
            [b6 setBackgroundColor:[UIColor whiteColor]];
            break;
        default:
            break;
    }
}

#pragma mark -- HELPERS
#pragma mark -- CONSTRAINTS
-(void)addDescriptionViewConstraints
{
    NSDictionary *viewsDictionary = @{@"matchView":descriptionView};
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView(70)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];

    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView]-15-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];

    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[matchView]-32-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    [descriptionView addConstraints:constraint_H];
    [self addConstraints:constraint_POS_H];
    [self addConstraints:constraint_POS_V];
}

-(void)addNameLabelConstraints
{
    NSDictionary *informationDict = @{@"name":nameLabel};

    NSArray *infoCon_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[name(20)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:informationDict];

    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[name]-5-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];

    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[name]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];
    [nameLabel addConstraints:infoCon_H];
    [descriptionView addConstraints:infoCon_PosH];
    [descriptionView addConstraints:infoCon_PosV];
}

-(void)addSchoolLabelConstraints
{
    NSDictionary *informationDict = @{@"school": schoolLabel, @"name":nameLabel};
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[school]-8-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];

    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[school]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];
    [descriptionView addConstraints:infoCon_PosH];
    [descriptionView addConstraints:infoCon_PosV];
}

-(void)addProfileImage1Constraints
{
    NSDictionary *imageDict = @{@"imageView":profileImageView};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(width)]"
                                                                           options:0
                                                                           metrics:@{@"width":@(CARD_WIDTH)}
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView addConstraints:imgConstraint_POS_H];
    [profileImageView addConstraints:imgConstraint_POS_V];
}


-(void)addProfileImage2Constraints
{
    NSDictionary *imageDict = @{@"imageView2":profileImageView2};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView2]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView2(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView2(width)]"
                                                                           options:0
                                                                           metrics:@{@"width":@(CARD_WIDTH)}
                                                                           views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView2 addConstraints:imgConstraint_POS_H];
    [profileImageView2 addConstraints:imgConstraint_POS_V];
}

-(void)addProfileImage3Constraints
{
    NSDictionary *imageDict = @{@"imageView3":profileImageView3};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView3]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView3(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView3(width)]"
                                                                           options:0
                                                                           metrics:@{@"width":@(CARD_WIDTH)}
                                                                             views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView3 addConstraints:imgConstraint_POS_H];
    [profileImageView3 addConstraints:imgConstraint_POS_V];
}

-(void)addProfileImage4Constraints
{
    NSDictionary *imageDict = @{@"imageView4":profileImageView4};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView4]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView4(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView4(width)]"
                                                                           options:0
                                                                           metrics:@{@"width":@(CARD_WIDTH)}
                                                                             views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView4 addConstraints:imgConstraint_POS_H];
    [profileImageView4 addConstraints:imgConstraint_POS_V];
}

-(void)addProfileImage5Constraints
{
    NSDictionary *imageDict = @{@"imageView5":profileImageView5};

    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView5]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView5(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView5(width)]"
                                                                           options:0
                                                                           metrics:@{@"width":@(CARD_WIDTH)}
                                                                             views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView5 addConstraints:imgConstraint_POS_H];
    [profileImageView5 addConstraints:imgConstraint_POS_V];
}

-(void)addProfileImage6Constraints
{
    NSDictionary *imageDict = @{@"imageView":profileImageView, @"imageView2":profileImageView2, @"imageView3":profileImageView3, @"imageView4": profileImageView4, @"imageView5":profileImageView5, @"imageView6":profileImageView6};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView6]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView6(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView6(width)]"
                                                                           options:0
                                                                           metrics:@{@"width":@(CARD_WIDTH)}
                                                                             views:imageDict];

    NSArray *sixViewsCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-[imageView2]-[imageView3]-[imageView4]-[imageView5]-[imageView6]-5-|"
                                                options:0
                                                metrics:nil
                                                views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView6 addConstraints:imgConstraint_POS_H];
    [profileImageView6 addConstraints:imgConstraint_POS_V];
    [imageScroll addConstraints:sixViewsCons];
}

-(void)addButton1Constraints
{
    NSDictionary *buttonDict = @{@"b1": b1};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b1(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b1(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b1]-12-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b1 addConstraints:buttonHeight];
    [b1 addConstraints:buttonWidth];
    [self addConstraints:infoCon_PosH];
}


-(void)addView1Constraints
{
    NSDictionary *buttonDict = @{@"v1": v1};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v1(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v1(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v1]-12-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-105-[v1]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];


    [v1 addConstraints:buttonHeight];
    [v1 addConstraints:buttonWidth];
    [self addConstraints:infoCon_PosH];
    [self addConstraints:infoCon_PosV];
}


-(void)addButton2Constraints
{
    NSDictionary *buttonDict = @{@"b2": b2};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b2(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b2(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b2]-12-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b2 addConstraints:buttonHeight];
    [b2 addConstraints:buttonWidth];
    [self addConstraints:infoCon_PosH];
}

-(void)addButton3Constraints
{
    NSDictionary *buttonDict = @{@"b3": b3};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b3(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b3(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b3]-12-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b3 addConstraints:buttonHeight];
    [b3 addConstraints:buttonWidth];
    [self addConstraints:infoCon_PosH];
}

-(void)addButton4Constraints
{
    NSDictionary *buttonDict = @{@"b4": b4};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b4(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b4(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b4]-12-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b4 addConstraints:buttonHeight];
    [b4 addConstraints:buttonWidth];
    [self addConstraints:infoCon_PosH];
}

-(void)addButton5Constraints
{
    NSDictionary *buttonDict = @{@"b5": b5};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b5(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b5(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b5]-12-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b5 addConstraints:buttonHeight];
    [b5 addConstraints:buttonWidth];
    [self addConstraints:infoCon_PosH];
}

-(void)addButton6Constraints
{
    NSDictionary *buttonDict = @{@"b2":b2, @"b3": b3, @"b4": b4, @"b5": b5, @"b6": b6};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b6(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b6(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b6]-12-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-45-[b1]-3-[b2]-3-[b3]-3-[b4]-3-[b5]-3-[b6]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b6 addConstraints:buttonHeight];
    [b6 addConstraints:buttonWidth];
    [self addConstraints:infoCon_PosH];
    [self addConstraints:infoCon_PosV];
}

@end
