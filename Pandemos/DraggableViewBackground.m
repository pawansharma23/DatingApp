//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "UserManager.h"
#import "User.h"

@interface DraggableViewBackground()<
UserManagerDelegate>

@property (strong, nonatomic) UserManager *userManager;

@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *sexPref;
@property (strong, nonatomic) NSString *milesAway;
@property (strong, nonatomic) NSString *minAge;
@property (strong, nonatomic) NSString *maxAge;
@property (strong, nonatomic) NSString *userImageForMatching;
@end
@implementation DraggableViewBackground{
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
static const float CARD_HEIGHT = 386; //%%% height of the draggable card
static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize potentialMatchData; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super layoutSubviews];
        [self setupView];
        //1) load current user search constraints
        self.potentialMatchData = [NSMutableArray new];
        self.userManager = [UserManager new];
        self.userManager.delegate = self;
        [self.userManager loadUserData:[User currentUser]];
    
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
    }
    return self;
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
    self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 34, 22, 15)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    messageButton = [[UIButton alloc]initWithFrame:CGRectMake(284, 34, 18, 18)];
    [messageButton setImage:[UIImage imageNamed:@"messageButton"] forState:UIControlStateNormal];
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 485, 59, 59)];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 485, 59, 59)];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:menuButton];
    [self addSubview:messageButton];
    [self addSubview:xButton];
    [self addSubview:checkButton];
}

-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
    User *user = [self.potentialMatchData objectAtIndex:index];
    NSString *infoText = [NSString stringWithFormat:@"%@, %@", user.givenName, [user ageFromBirthday:user.birthday]];
    draggableView.information.text = infoText;
    draggableView.schoolLabel.text = user.lastSchool;
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([self.potentialMatchData count] > 0)
    {
        NSInteger numLoadedCardsCap =(([self.potentialMatchData count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[self.potentialMatchData count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen

        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[self.potentialMatchData count]; i++)
        {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
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

#pragma mark -- SWIPE DIRECTION ACTIONS
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
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

#pragma mark - USER MANAGER DELEGATES
//Step 2
-(void)didReceiveUserData:(NSArray *)data
{
    NSDictionary *userData = [data firstObject];
    self.sexPref = userData[@"sexPref"];
    self.milesAway = userData[@"milesAway"];
    self.minAge = userData[@"minAge"];
    self.maxAge = userData[@"maxAge"];
    self.gender = userData[@"gender"];

    //this method take user preferences and returns allMatchedUsers
    [self.userManager loadUsersUnseenPotentialMatches:self.sexPref minAge:self.minAge maxAge:self.maxAge];
}

-(void)failedToFetchUserData:(NSError *)error
{
    NSLog(@"failed to fetch Data: %@", error);
}
//Step 3
-(void)didReceivePotentialMatchData:(NSArray *)data
{
    [self.userManager loadMatchedUsers:^(NSArray *users, NSError *error) {
        //returns [usermanager].alreadySeenUser
    }];
}
//Step 4
-(void)didLoadMatchedUsers:(NSArray<User *> *)users
{
    //loop through all matched users and compare to all current matches
    NSMutableArray *intersectionArray = [NSMutableArray arrayWithArray:self.userManager.allMatchedUsers];

    for (User *user in self.userManager.allMatchedUsers)
    {
        NSLog(@"match: %@", user.givenName);

        for (NSDictionary *matchRequest in users)//self.userManager.alreadySeenUser
        {
            User *userObjectFrom = matchRequest[@"fromUser"];

            NSString *seenIdFrom = userObjectFrom.objectId;
            NSString *strIdTo = matchRequest[@"strId"];
            //NSString *seenIdTo = userObjectTo.objectId;

            if ([user.objectId isEqualToString:seenIdFrom] || [user.objectId isEqualToString:strIdTo])
            {
                //                    [intersectionArray addObject:user.objectId];
                NSLog(@"filtered matches to remove: %@", user.givenName);
                [intersectionArray removeObject:user];
            }
        }
    }

    if (intersectionArray.count > 0)
    {

        self.potentialMatchData = intersectionArray;
        [self loadCards];
        //[self loadInitialMatch:intersectionArray];
        //NSLog(@"filtered matches: %d", (int)self.potentialMatchData.count);
    }
    else
    {
        //no matches left
        NSLog(@"no cards left");
//        self.noMatchesImage.image = [UIImage imageWithImage:[UIImage imageNamed:@"Close"] scaledToSize:CGSizeMake(240.0, 128.0)];
//        [self.view insertSubview:self.activityView aboveSubview:self.userImage];
//        self.userInfoView.hidden = YES;
//        self.greenButton.hidden = YES;
//        self.redButton.hidden = YES;
    }
}

-(void)failedToFetchPotentialMatchData:(NSError *)error
{
    NSLog(@"NO POTENTIAL MATCHES FOR USER TO SEE: %@", error);
}
@end
