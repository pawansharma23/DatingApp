//
//  DraggableView.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 80 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#import "UIColor+Pandemos.h"
#import "DraggableView.h"
#import "UIButton+Additions.h"
#import "AppConstants.h"

@implementation DraggableView
{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

static float CARD_HEIGHT;
static float CARD_WIDTH;

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize information;
@synthesize overlayView;
@synthesize schoolLabel;
@synthesize profileImageView;
@synthesize profileImageView2;
@synthesize profileImageView3;
@synthesize profileImageView4;
@synthesize profileImageView5;
@synthesize profileImageView6;
@synthesize v1;
@synthesize v2;
@synthesize v3;
@synthesize v4;
@synthesize v5;
@synthesize v6;
@synthesize imageCount;
@synthesize noButton;
@synthesize yesButton;
@synthesize imageScroll;
@synthesize matchDescView;

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
            CARD_WIDTH = 355;
            CARD_HEIGHT = 617;
        }
        else if (IS_IPHONE6PLUS)
        {
            CARD_WIDTH = 390;
            CARD_HEIGHT = 680;
        }

        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        [self addGestureRecognizer:panGestureRecognizer];

        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];

        imageScroll = [[ImageScroll alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:imageScroll];
        imageScroll.backgroundColor = [UIColor blueColor];
        imageScroll.delegate = self;
        imageScroll.pagingEnabled = YES;
        imageScroll.scrollEnabled = YES;
        imageScroll.clipsToBounds = NO;
        imageScroll.layer.cornerRadius = 8;
        imageScroll.userInteractionEnabled = YES;
        imageScroll.scrollsToTop = NO;
        imageScroll.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 3);//multiplied by profileimages.coun

        profileImageView = [UIImageView new];
        [imageScroll addSubview:profileImageView];
        profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView.layer.cornerRadius = 8;
        profileImageView.backgroundColor = [UIColor blackColor];
        [self addProfileImage1Constraints];

        profileImageView2 = [UIImageView new];
        [imageScroll addSubview:profileImageView2];
        profileImageView2.backgroundColor = [UIColor redColor];
        profileImageView2.translatesAutoresizingMaskIntoConstraints = NO;
        [self addProfileImage2Constraints];

        profileImageView3 = [UIImageView new];
        [imageScroll addSubview:profileImageView3];
        profileImageView3.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView3.backgroundColor = [UIColor blueColor];
        [self addProfileImage3Constraints];

        profileImageView4 = [UIImageView new];
        [imageScroll addSubview:profileImageView4];
        profileImageView4.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView.layer.cornerRadius = 8;
        profileImageView4.backgroundColor = [UIColor blackColor];
        [self addProfileImage4Constraints];

        profileImageView5 = [UIImageView new];
        [imageScroll addSubview:profileImageView5];
        profileImageView5.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView5.backgroundColor = [UIColor blueColor];
        [self addProfileImage5Constraints];

        profileImageView6 = [UIImageView new];
        [imageScroll addSubview:profileImageView6];
        profileImageView6.translatesAutoresizingMaskIntoConstraints = NO;
        profileImageView6.backgroundColor = [UIColor redColor];
        [self addProfileImage6Constraints];

        matchDescView = [[UIView alloc]init];
        [self addSubview:matchDescView];
        matchDescView.translatesAutoresizingMaskIntoConstraints = NO;
        matchDescView.layer.cornerRadius = 8;
        matchDescView.backgroundColor = [UIColor grayColor];
        [self addMatchViewConstraints];

        information = [UILabel new];
        [matchDescView addSubview:information];
        information.translatesAutoresizingMaskIntoConstraints = NO;
        [information setFont:[UIFont fontWithName:@"GeezaPro" size:18.0]];
        [information setTextAlignment:NSTextAlignmentCenter];
        [self addNameAndAgeLabelConstraints:information andSuperView:matchDescView];

        schoolLabel = [UILabel new];
        [matchDescView addSubview:schoolLabel];
        schoolLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [schoolLabel setFont:[UIFont fontWithName:@"GeezaPro" size:16.0]];
        schoolLabel.text = @"Loading...";
        schoolLabel.lineBreakMode = NSLineBreakByWordWrapping;
        schoolLabel.numberOfLines = 0;
        [schoolLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSchoolLabelConstraints:schoolLabel andSuperView:matchDescView];



        //View Indicator for scrolling profileImages
        //imageCount = 0;

        v1 = [UIView new];
        [self addSubview:v1];
        [self setForViewIndicator:v1];
        [self addView1Constraints];
        v1.backgroundColor = [UIColor whiteColor];

        v2 = [UIView new];
        [self addSubview:v2];
        [self setForViewIndicator:v2];
        [self addView2Constraints];

        v3 = [UIView new];
        [self addSubview:v3];
        [self setForViewIndicator:v3];
        [self addView3Constraints];

        v4 = [UIView new];
        [self addSubview:v4];
        [self setForViewIndicator:v4];
        [self addView4Constraints];

        v5 = [UIView new];
        [self addSubview:v5];
        [self setForViewIndicator:v5];
        [self addView5Constraints];

        v6 = [UIView new];
        [self addSubview:v6];
        [self setForViewIndicator:v6];
        [self addView6Constraints];


//        noButton = [UIButton new];
//        [matchDescView addSubview:noButton];
//        noButton.translatesAutoresizingMaskIntoConstraints = NO;
//        noButton.layer.masksToBounds = YES;
//        noButton.layer.cornerRadius = 25;
//        [UIButton rotateLeftButton:noButton];
//        [noButton setTitle:@"✖️" forState:UIControlStateNormal];
//        noButton.titleLabel.text = @"X";
//        noButton.backgroundColor = [UIColor redColor];
//        noButton.layer.borderWidth = 1.0;
//        noButton.layer.borderColor = [UIColor blackColor].CGColor;
//        [self addNoButtonConstraints];
//
//        yesButton = [UIButton new];
//        [matchDescView addSubview:yesButton];
//        yesButton.translatesAutoresizingMaskIntoConstraints = NO;
//        yesButton.layer.masksToBounds = YES;
//        yesButton.layer.cornerRadius = 25;
//        [UIButton rotateRightButton:yesButton];
//        [yesButton setTitle:@"✔️" forState:UIControlStateNormal];
//        yesButton.backgroundColor = [UIColor greenColor];
//        yesButton.layer.borderWidth = 1.0;
//        yesButton.layer.borderColor = [UIColor blackColor].CGColor;
//        [self addYesButtonConstraints];
    }

    return self;
}

-(void)setupView
{
    self.layer.cornerRadius = 8;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

-(void)setForViewIndicator:(UIView*)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 6;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = [UIColor yellowGreen].CGColor;
}

#pragma mark SCROLLVIEW DELEGATES
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    NSLog(@"dragging in scroll view");
//}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"Did end decelerating");
//    //do your code here
//}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageHeight = CARD_HEIGHT;
    float fractionalPage = scrollView.contentOffset.y / pageHeight;
    NSInteger page = ceilf(fractionalPage);
    NSLog(@"page: %ld", (long)page);

    switch (page)
    {
        case 0:
            [v2 setBackgroundColor:nil];
            [v1 setBackgroundColor:[UIColor whiteColor]];
            [v3 setBackgroundColor:nil];
            [v4 setBackgroundColor:nil];
            [v5 setBackgroundColor:nil];
            [v6 setBackgroundColor:nil];
            break;
        case 1:
            [v1 setBackgroundColor:nil];
            [v2 setBackgroundColor:[UIColor whiteColor]];
            [v3 setBackgroundColor:nil];
            [v4 setBackgroundColor:nil];
            [v5 setBackgroundColor:nil];
            [v6 setBackgroundColor:nil];
            break;
        case 2:
            [v1 setBackgroundColor:nil];
            [v3 setBackgroundColor:[UIColor whiteColor]];
            [v2 setBackgroundColor:nil];
            [v4 setBackgroundColor:nil];
            [v5 setBackgroundColor:nil];
            [v6 setBackgroundColor:nil];
            break;
        case 3:
            [v1 setBackgroundColor:nil];
            [v4 setBackgroundColor:[UIColor whiteColor]];
            [v2 setBackgroundColor:nil];
            [v3 setBackgroundColor:nil];
            [v5 setBackgroundColor:nil];
            [v6 setBackgroundColor:nil];
            break;
        case 4:
            [v1 setBackgroundColor:nil];
            [v5 setBackgroundColor:[UIColor whiteColor]];
            [v2 setBackgroundColor:nil];
            [v4 setBackgroundColor:nil];
            [v3 setBackgroundColor:nil];
            [v6 setBackgroundColor:nil];
            break;
        case 5:
            [v1 setBackgroundColor:nil];
            [v6 setBackgroundColor:[UIColor whiteColor]];
            [v2 setBackgroundColor:nil];
            [v4 setBackgroundColor:nil];
            [v5 setBackgroundColor:nil];
            [v3 setBackgroundColor:nil];
            break;
        default:
            break;
    }
}


//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    //yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down

    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:
        {
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);

            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);

            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);

            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y);
    
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);

            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);

            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];

            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }

    overlayView.alpha = MIN(fabs(distance)/100, 0.4);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN)
    {
        [self rightAction];
    }
    else if (xFromCenter < -ACTION_MARGIN)
    {
        [self leftAction];
    }
    else
    { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedRight:self];

    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedLeft:self];

    NSLog(@"NO");
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedRight:self];

    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedLeft:self];

    NSLog(@"NO");
}

#pragma mark -- MATCH VIEW CONSTRAINT
-(void)addMatchViewConstraints
{
    NSDictionary *viewsDictionary = @{@"matchView":matchDescView};
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView(70)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:viewsDictionary];

    NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView]-23-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];

    NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[matchView]-32-|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];
    //view specific constraints
    [matchDescView addConstraints:constraint_H];
    [self addConstraints:constraint_POS_H];
    [self addConstraints:constraint_POS_V];
}
-(void)addNameAndAgeLabelConstraints:(UIView*)view andSuperView:(UIView*)superView
{
    NSDictionary *informationDict = @{@"info":information};

    NSArray *infoCon_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[info(20)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:informationDict];

    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[info]-5-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];

    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[info]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];
    [information addConstraints:infoCon_H];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addSchoolLabelConstraints:(UIView*)view andSuperView:(UIView*)superView
{

    NSDictionary *informationDict = @{@"school": schoolLabel, @"info":information};
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[school]-15-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];

    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[school]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}


#pragma mark -- PROFILE VIEW CONSTRAINTS
-(void)addProfileImage1Constraints
{
    NSDictionary *imageDict = @{@"imageView":profileImageView};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *widthCon = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(width)]"
                                                                           options:0
                                                                           metrics:@{@"width":@(CARD_WIDTH)}
                                                                             views:imageDict];

    NSArray *heightCon = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView addConstraints:widthCon];
    [profileImageView addConstraints:heightCon];
}


-(void)addProfileImage2Constraints
{
    NSDictionary *imageDict = @{@"imageView2":profileImageView2};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView2]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];
    NSArray *widthCon = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView2(width)]"
                                                                options:0
                                                                metrics:@{@"width":@(CARD_WIDTH)}
                                                                  views:imageDict];

    NSArray *heightCon = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView2(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView2 addConstraints:heightCon];
    [profileImageView2 addConstraints:widthCon];
}

-(void)addProfileImage3Constraints
{
    NSDictionary *imageDict = @{@"imageView3":profileImageView3};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView3]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *heightCon = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView3(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *widthCon = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView3(width)]"
                                                                options:0
                                                                metrics:@{@"width":@(CARD_WIDTH)}
                                                                  views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView3 addConstraints:heightCon];
    [profileImageView3 addConstraints:widthCon];
}

-(void)addProfileImage4Constraints
{
    NSDictionary *imageDict = @{@"imageView4":profileImageView4};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView4]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *heightCon = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView4(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *widthCon = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView4(width)]"
                                                                options:0
                                                                metrics:@{@"width":@(CARD_WIDTH)}
                                                                  views:imageDict];

    [imageScroll addConstraints:xPosition];
    [profileImageView4 addConstraints:heightCon];
    [profileImageView4 addConstraints:widthCon];
}

-(void)addProfileImage5Constraints
{
    NSDictionary *imageDict = @{@"imageView5":profileImageView5};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView5]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *heightCon = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView5(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *widthCon = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView5(width)]"
                                                                options:0
                                                                metrics:@{@"width":@(CARD_WIDTH)}
                                                                  views:imageDict];

    [imageScroll addConstraints:xPosition];
    [profileImageView5 addConstraints:heightCon];
    [profileImageView5 addConstraints:widthCon];
}

-(void)addProfileImage6Constraints
{
    NSDictionary *imageDict = @{@"imageView":profileImageView, @"imageView2":profileImageView2, @"imageView3":profileImageView3, @"imageView4": profileImageView4, @"imageView5":profileImageView5, @"imageView6":profileImageView6};
    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView6]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *heightCon = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView6(height)]"
                                                                           options:0
                                                                           metrics:@{@"height":@(CARD_HEIGHT)}
                                                                             views:imageDict];

    NSArray *widthCon = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView6(width)]"
                                                                options:0
                                                                metrics:@{@"width":@(CARD_WIDTH)}
                                                                  views:imageDict];

    NSArray *sixViewsCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-[imageView2]-[imageView3]-[imageView4]-[imageView5]-[imageView6]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:imageDict];
    [imageScroll addConstraints:xPosition];
    [profileImageView6 addConstraints:heightCon];
    [profileImageView6 addConstraints:widthCon];
    [imageScroll addConstraints:sixViewsCons];
}

#pragma mark -- VIEW INDICATOR CONSTRAINTS
-(void)addView1Constraints
{
    NSDictionary *viewDict = @{@"v1": v1};
    NSArray *viewHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v1(12)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewDict];
    NSArray *viewWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v1(12)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    NSArray *trailingH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v1]-12-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    [v1 addConstraints:viewHeight];
    [v1 addConstraints:viewWidth];
    [self addConstraints:trailingH];
}

-(void)addView2Constraints
{
    NSDictionary *viewDict = @{@"v2": v2};
    NSArray *viewHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v2(12)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewDict];
    NSArray *viewWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v2(12)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    NSArray *trailingH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v2]-12-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    [v2 addConstraints:viewHeight];
    [v2 addConstraints:viewWidth];
    [self addConstraints:trailingH];
}

-(void)addView3Constraints
{
    NSDictionary *viewDict = @{@"v3": v3};
    NSArray *viewHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v3(12)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewDict];
    NSArray *viewWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v3(12)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    NSArray *trailingH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v3]-12-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    [v3 addConstraints:viewHeight];
    [v3 addConstraints:viewWidth];
    [self addConstraints:trailingH];
}

-(void)addView4Constraints
{
    NSDictionary *viewDict = @{@"v4": v4};
    NSArray *viewHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v4(12)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewDict];
    NSArray *viewWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v4(12)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    NSArray *trailingH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v4]-12-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    [v4 addConstraints:viewHeight];
    [v4 addConstraints:viewWidth];
    [self addConstraints:trailingH];
}

-(void)addView5Constraints
{
    NSDictionary *viewDict = @{@"v5": v5};
    NSArray *viewHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v5(12)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewDict];
    NSArray *viewWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v5(12)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    NSArray *trailingH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v5]-12-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    [v5 addConstraints:viewHeight];
    [v5 addConstraints:viewWidth];
    [self addConstraints:trailingH];
}

-(void)addView6Constraints
{
    NSDictionary *viewDict = @{@"v1":v1, @"v2":v2, @"v3":v3, @"v4":v4, @"v5":v5, @"v6":v6};
    NSArray *viewHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[v6(12)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:viewDict];

    NSArray *viewWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v6(12)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];

    NSArray *trailingH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[v6]-12-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];

    NSArray *sixSpaces = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[v1]-3-[v2]-3-[v3]-3-[v4]-3-[v5]-3-[v6]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewDict];
    [v6 addConstraints:viewHeight];
    [v6 addConstraints:viewWidth];
    [self addConstraints:trailingH];
    [self addConstraints:sixSpaces];
}



#pragma mark -- YES & NO BUTTONS
-(void)addNoButtonConstraints
{
    NSDictionary *buttonDict = @{@"noButton": noButton};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noButton(50)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[noButton(50)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-13)-[noButton]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noButton]-20-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [noButton addConstraints:buttonHeight];
    [noButton addConstraints:buttonWidth];
    [imageScroll addConstraints:infoCon_PosH];
    [imageScroll addConstraints:infoCon_PosV];
}

-(void)addYesButtonConstraints
{
    NSDictionary *buttonDict = @{@"yesButton": yesButton};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yesButton(50)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[yesButton(50)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[yesButton]-(-10)-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yesButton]-20-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [yesButton addConstraints:buttonHeight];
    [yesButton addConstraints:buttonWidth];
    [imageScroll addConstraints:infoCon_PosH];
    [imageScroll addConstraints:infoCon_PosV];
}
@end