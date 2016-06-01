//
//  DraggableView.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#import "UIColor+Pandemos.h"
#import "DraggableView.h"

@implementation DraggableView
{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize information;
@synthesize overlayView;
@synthesize schoolLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        self.backgroundColor = [UIColor whiteColor];

        UIView *matchDescView = [[UIView alloc]init];
        matchDescView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *viewsDictionary = @{@"matchView":matchDescView};
        matchDescView.backgroundColor = [UIColor lightGrayColor];
        matchDescView.layer.cornerRadius = 8;
        [self addSubview:matchDescView];

        NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView(80)]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];

//        NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[matchView(200)]"
//                                                                        options:0
//                                                                        metrics:nil
//                                                                          views:viewsDictionary];

        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView]-15-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];

        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[matchView]-20-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];

  //      child cons
        [matchDescView addConstraints:constraint_H];
        //[matchDescView addConstraints:constraint_V];
//        parent to child cons
        [self addConstraints:constraint_POS_H];
        [self addConstraints:constraint_POS_V];

        information = [UILabel new];
        information.translatesAutoresizingMaskIntoConstraints = NO;
        [matchDescView addSubview:information];
        [information setFont:[UIFont fontWithName:@"GeezaPro" size:18.0]];
        information.text = @"Loading...";
        [information setTextAlignment:NSTextAlignmentCenter];
        [self setNameAndAgeLabel:information andSuperView:matchDescView];

        schoolLabel = [UILabel new];
        schoolLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [matchDescView addSubview:schoolLabel];
        [schoolLabel setFont:[UIFont fontWithName:@"GeezaPro" size:16.0]];
        schoolLabel.text = @"Loading...";
        [schoolLabel setTextAlignment:NSTextAlignmentCenter];
        [self setSchoolLabel:schoolLabel andSuperView:matchDescView];






        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];

        [self addGestureRecognizer:panGestureRecognizer];

        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView.alpha = 1;
        [self addSubview:overlayView];

//        [potentialMatchView addSubview:overlayView];
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

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down

    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);

            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);

            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);

            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);

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
    else if (yFromCenter > ACTION_MARGIN)
    {
        [self downImageAction];
    }
    else if(yFromCenter < -ACTION_MARGIN)
    {
        [self upImageAction];
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

-(void)upImageAction
{
    CGPoint finishPoint = CGPointMake(self.originalPoint.y, -700);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedUp:self];

    NSLog(@"Up: Next Image");
}


-(void)downImageAction
{
    CGPoint finishPoint = CGPointMake(self.originalPoint.y, 500);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedDown:self];

    NSLog(@"Down: Previous Image");
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

#pragma mark -- VIEW HELPERS
-(void)setNameAndAgeLabel:(UIView*)view andSuperView:(UIView*)superView
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

-(void)setSchoolLabel:(UIView*)view andSuperView:(UIView*)superView
{

    NSDictionary *informationDict = @{@"school": schoolLabel, @"info":information};
    NSArray *infoCon_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[school(20)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:informationDict];

    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[school]-5-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];

    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-23-[school]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];
    [schoolLabel addConstraints:infoCon_H];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}
@end











