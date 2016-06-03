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
#import "UIButton+Additions.h"
#import "AppConstants.h"
#import "UIImage+Additions.h"

@interface DraggableViewBackground()<DraggableViewDelegate>

@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *sexPref;
@property (strong, nonatomic) NSString *milesAway;
@property (strong, nonatomic) NSString *minAge;
@property (strong, nonatomic) NSString *maxAge;
@property (strong, nonatomic) NSString *userImageForMatching;
@property (strong, nonatomic) DraggableView *dragView;
@property int imageCount;
@end

@implementation DraggableViewBackground
{
    NSInteger imagesLoadedIndex;
    NSMutableArray *loadedProfileCards;
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static float CARD_HEIGHT;
//= 386; //%%% height of the draggable card
static float CARD_WIDTH;
//= 290; //%%% width of the draggable card

@synthesize potentialMatchData; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super layoutSubviews];
        //1) load current user search constraints
        self.potentialMatchData = [NSMutableArray new];
        self.userManager = [UserManager new];
        self.userManager.delegate = self;
        [self.userManager loadUserData:[User currentUser]];
    
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        loadedProfileCards = [[NSMutableArray alloc]init];

        cardsLoadedIndex = 0;
        imagesLoadedIndex = 0;

        self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
        [self.dragView.noButton addTarget:self action:@selector(onSwipeLeft:) forControlEvents:UIControlEventTouchUpInside];
        [self.dragView.yesButton addTarget:self action:@selector(onSwipeRight) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
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
        CARD_WIDTH = 330;
        CARD_HEIGHT = 570;
    }
    else if (IS_IPHONE6PLUS)
    {
        CARD_WIDTH = 390;
        CARD_HEIGHT = 680;
    }
    self.dragView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/1.25, CARD_WIDTH, CARD_HEIGHT)];
    User *user = [self.potentialMatchData objectAtIndex:index];
    self.dragView.profileImageView.image = [UIImage imageWithString:user.profileImages.firstObject];
    NSString *infoText = [NSString stringWithFormat:@"%@, %@", user.givenName, [user ageFromBirthday:user.birthday]];
    self.dragView.information.text = infoText;
    self.dragView.schoolLabel.text = user.lastSchool;
    //set current users images
//    [self.delegate didFetchImagesForMatchedProfile:user.profileImages];
//    matchProfileImages = user.profileImages;
 //   self.dragView.profileImageView2.image = [UIImage imageWithString:[user.profileImages objectAtIndex:1]];

    [UIButton loadIndicatorLightsForProfileImages:self.dragView.b1 image2:self.dragView.b2 image3:self.dragView.b3 image4:self.dragView.b4 image5:self.dragView.b5 image6:self.dragView.b6 imageCount:(int)user.profileImages.count];

    [UIButton setIndicatorLight:self.dragView.b1 l2:self.dragView.b2 l3:self.dragView.b3 l4:self.dragView.b4 l5:self.dragView.b5 l6:self.dragView.b6 forCount:0];
    
    self.dragView.delegate = self;
    
    return self.dragView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([self.potentialMatchData count] > 0)
    {
        NSInteger numLoadedCardsCap =(([self.potentialMatchData count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[self.potentialMatchData count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen

        //%%% loops through all potential matches to create a card for each match
        for (int i = 0; i<[self.potentialMatchData count]; i++)
        {
            DraggableView *newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];

            if (i<numLoadedCardsCap)
            {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++)
        {
            if (i>0)
            {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            }
            else
            {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
    else
    {
        NSLog(@"out of matches");
    }
}

#pragma mark -- SWIPE DIRECTION ACTIONS
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;

    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"

    if (cardsLoadedIndex < [allCards count])
    { //%%% if we haven't reached the end of all cards, put another into the loaded cards
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

    if (cardsLoadedIndex < [allCards count])
    { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }

}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)onSwipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
- (void)onSwipeLeft:(UIButton *)sender
{
    if (sender.selected)
    {
        DraggableView *dragView = [loadedCards firstObject];
        dragView.overlayView.mode = GGOverlayViewModeLeft;
        [UIView animateWithDuration:0.2 animations:^{
            dragView.overlayView.alpha = 1;
        }];
            [dragView leftClickAction];
    }
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
    }
    else
    {
        //no matches left
        NSLog(@"no cards left");
    }
}

-(void)failedToFetchPotentialMatchData:(NSError *)error
{
    NSLog(@"NO POTENTIAL MATCHES FOR USER TO SEE: %@", error);
}

#pragma mark -- HELPERS
-(void)swipeUpForNextImage
{

}
@end
