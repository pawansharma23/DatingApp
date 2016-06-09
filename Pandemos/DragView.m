

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 6 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DragView.h"
#import "AppConstants.h"

@implementation DragView
{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

static float CARD_HEIGHT;
static float CARD_WIDTH;

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize nameLabel;
@synthesize nameAndSchoolView;
@synthesize overlayView;
@synthesize imageScroll;
@synthesize profileImageView;
@synthesize profileImageView2;
@synthesize profileImageView3;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupView];

        if (IS_IPHONE4)
        {
            CARD_WIDTH = 290;
            CARD_HEIGHT = 400;
        }
        else if (IS_IPHONE5)
        {
            CARD_WIDTH = 290;
            CARD_HEIGHT = 500;
        }
        else if (IS_IPHONE6)
        {
            CARD_WIDTH = 290;
            CARD_HEIGHT = 500;
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
        imageScroll.userInteractionEnabled = YES;
        imageScroll.scrollsToTop = NO;
        //imageScroll.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 3);//multiplied by profileimages.count

        //load view for all the proffile images but that data is in draggableviewbackgroud

        profileImageView = [UIImageView new];

        profileImageView.backgroundColor = [UIColor blackColor];
        [self setProfileImage:profileImageView];
        [self addProfileImage1Constraints];

        profileImageView2 = [UIImageView new];
        [self setProfileImage:profileImageView2];
        profileImageView2.backgroundColor = [UIColor redColor];
        [self addProfileImage2Constraints];

        profileImageView3 = [UIImageView new];
        [self setProfileImage:profileImageView3];
        profileImageView3.backgroundColor = [UIColor greenColor];
        [self addProfileImage3Constraints];
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

-(void)setProfileImage:(UIImageView*)imageView
{
    [imageScroll addSubview:imageView];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.layer.cornerRadius = 8;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Did end decelerating");
    //do your code here
}

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    //yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down

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

-(void)addScrollViewConstraints
{
    NSDictionary *imageDict = @{@"imageScroll":imageScroll};
    //NSDictionary *metrics = @{@"width":@(CARD_WIDTH), @"height":@(CARD_HEIGHT)};

    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[imageScroll]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *yPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imageScroll]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    //    NSArray *hardCodeWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(width)]"
    //                                                                     options:0
    //                                                                     metrics:metrics
    //                                                                       views:imageDict];
    //
    //    NSArray *hardCodeHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(height)]"
    //                                                                      options:0
    //                                                                      metrics:metrics
    //                                                                        views:imageDict];

    [self addConstraints:xPosition];
    [self addConstraints:yPosition];
    //[profileImageView addConstraints:hardCodeWidth];
    //[profileImageView addConstraints:hardCodeHeight];
}

-(void)addProfileImage1Constraints
{
    NSDictionary *imageDict = @{@"imageView":profileImageView, @"width":@(CARD_WIDTH), @"height":@(CARD_HEIGHT)};
    NSDictionary *metrics = @{@"width":@(CARD_WIDTH), @"height":@(CARD_HEIGHT)};

    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *hardCodeWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(width)]"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:imageDict];

    NSArray *hardCodeHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(height)]"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:imageDict];

    [imageScroll addConstraints:xPosition];
    [profileImageView addConstraints:hardCodeWidth];
    [profileImageView addConstraints:hardCodeHeight];
}



-(void)addProfileImage2Constraints
{
    NSDictionary *imageDict = @{@"imageView2":profileImageView2};
    NSDictionary *metrics = @{@"width":@(CARD_WIDTH), @"height":@(CARD_HEIGHT)};

    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView2]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView2(height)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView2(width)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:imageDict];


    [self addConstraints:xPosition];
    [profileImageView2 addConstraints:imgConstraint_POS_H];
    [profileImageView2 addConstraints:imgConstraint_POS_V];
}

-(void)addProfileImage3Constraints
{
    NSDictionary *imageDict = @{@"imageView":profileImageView, @"imageView2":profileImageView2, @"imageView3":profileImageView3};
    NSDictionary *metrics = @{@"width":@(CARD_WIDTH), @"height":@(CARD_HEIGHT)};

    NSArray *xPosition = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView3]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:imageDict];

    NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView3(height)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:imageDict];

    NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView3(width)]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:imageDict];

    NSArray *threeViewsCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imageView]-[imageView2]-[imageView3]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:imageDict];
    [self addConstraints:xPosition];
    [profileImageView3 addConstraints:imgConstraint_POS_H];
    [profileImageView3 addConstraints:imgConstraint_POS_V];
    [imageScroll addConstraints:threeViewsCons];
}
@end
