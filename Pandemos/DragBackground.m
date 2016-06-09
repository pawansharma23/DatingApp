

#import "DragBackground.h"
#import "AppConstants.h"

@implementation DragBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)

    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static float CARD_HEIGHT;
static float CARD_WIDTH;

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super layoutSubviews];

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

        //load user objects
        exampleCardLabels = [[NSArray alloc]initWithObjects:@"first",@"second",@"third",@"fourth",@"last", nil]; //%%% placeholder for card-specific information
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;

        [self loadCards];
    }
    return self;
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DragView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{

    self.dragView = [[DragView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH) / 2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
    //self.dragView.information.text = [exampleCardLabels objectAtIndex:index]; //%%% placeholder for card-specific information
    self.dragView.delegate = self;

    [self loadProfileImages];

    return self.dragView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0) {
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen

        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            DragView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];

            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }

        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

-(void)loadProfileImages
{
    int count = 2;
    switch (count)
    {
        case 1:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height);
            self.dragView.profileImageView.image = [UIImage imageNamed:@"yesButton"];

            break;
        case 2:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 2);
            self.dragView.profileImageView.image = [UIImage imageNamed:@"yesButton"];
            self.dragView.profileImageView2.image = [UIImage imageNamed:@"xButton"];
            break;
        default:
            NSLog(@"no images for ProfileImageView switch");
            break;
    }
}
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;

    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"

    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;

    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"

    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }

}

-(void)cardSwipedUp:(UIView *)card
{
    //call up action for new image
    NSLog(@"card swiped up");
}

-(void)cardSwipedDown:(UIView *)card
{
    NSLog(@"card swiped down");
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DragView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DragView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
