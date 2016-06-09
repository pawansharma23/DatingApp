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
#import "DraggableView.h"

@implementation DraggableViewBackground
{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static float CARD_HEIGHT;
static float CARD_WIDTH;

@synthesize potentialMatchData; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards
@synthesize gender;
@synthesize sexPref;
@synthesize milesAway;
@synthesize minAge;
@synthesize maxAge;
@synthesize userImageForMatching;
@synthesize profileImages;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super layoutSubviews];
        //1) load current user search constraints
        [self iPhoneType];
        self.userManager = [UserManager new];
        self.userManager.delegate = self;
        [self.userManager loadUserData:[User currentUser]];

        potentialMatchData = [NSMutableArray new];
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];

        cardsLoadedIndex = 0;

    
        //[self.dragView.noButton addTarget:self action:@selector(onSwipeLeft:) forControlEvents:UIControlEventTouchUpInside];
        //[self.dragView.yesButton addTarget:self action:@selector(onSwipeRight) forControlEvents:UIControlEventTouchUpInside];

    }

    return self;
}

-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    [self iPhoneType];

    self.dragView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH) / 2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];

    self.dragView = [[DraggableView alloc]initWithFrame:CGRectMake(0, 0, 250, 400)];


//    User *user = [self.potentialMatchData objectAtIndex:index];
    //self.dragView.profileImageView.image = [UIImage imageWithString:[user.profileImages objectAtIndex:index]];

    //load all photo images here?
    [self loadProfileImages];

//    NSString *infoText = [NSString stringWithFormat:@"%@, %@", user.givenName, [user ageFromBirthday:user.birthday]];
//    self.dragView.information.text = infoText;
//    self.dragView.schoolLabel.text = user.lastSchool;

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
                [self loadProfileImages];
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

-(void)loadProfileImages
{
    User *userDict = [self.potentialMatchData objectAtIndex:0];//changed to current user objectAtIndex
    NSString *nameAndAge = [NSString stringWithFormat:@"%@, %@", userDict[@"givenName"], [userDict[@"birthday"] ageFromBirthday:userDict[@"birthday"]]];
    self.dragView.information.text = nameAndAge;
    self.dragView.schoolLabel.text = userDict[@"lastSchool"];
    //self.dragView.v1.backgroundColor = [UIColor whiteColor];
    //send a usermanaer delegate the profileimagecount to call in View
    self.profileImages = userDict[@"profileImages"];

    switch ((int)self.profileImages.count)
    {
        case 1:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height);
            self.dragView.profileImageView.image = [UIImage imageWithImage:[UIImage imageWithString:[self.profileImages objectAtIndex:0]] scaledToSize:CGSizeMake(375, 667)];
            [self.dragView.v2 removeFromSuperview];
            [self.dragView.v3 removeFromSuperview];
            [self.dragView.v4 removeFromSuperview];
            [self.dragView.v5 removeFromSuperview];
            [self.dragView.v6 removeFromSuperview];
            break;
        case 2:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 2);
            self.dragView.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
            self.dragView.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
            [self.dragView.v3 removeFromSuperview];
            [self.dragView.v4 removeFromSuperview];
            [self.dragView.v5 removeFromSuperview];
            [self.dragView.v6 removeFromSuperview];
            break;
        case 3:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 3);
            self.dragView.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
            self.dragView.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
            self.dragView.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
            [self.dragView.v4 removeFromSuperview];
            [self.dragView.v5 removeFromSuperview];
            [self.dragView.v6 removeFromSuperview];
            break;
        case 4:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 4);
            self.dragView.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
            self.dragView.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
            self.dragView.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
            self.dragView.profileImageView4.image = [UIImage imageWithString:[self.profileImages objectAtIndex:3]];
            [self.dragView.v5 removeFromSuperview];
            [self.dragView.v6 removeFromSuperview];
            break;
        case 5:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 5);
            self.dragView.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
            self.dragView.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
            self.dragView.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
            self.dragView.profileImageView4.image = [UIImage imageWithString:[self.profileImages objectAtIndex:3]];
            self.dragView.profileImageView5.image = [UIImage imageWithString:[self.profileImages objectAtIndex:4]];
            [self.dragView.v6 removeFromSuperview];
            break;
        case 6:
            self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 6);
            self.dragView.profileImageView.image = [UIImage imageWithString:[self.profileImages objectAtIndex:0]];
            self.dragView.profileImageView2.image = [UIImage imageWithString:[self.profileImages objectAtIndex:1]];
            self.dragView.profileImageView3.image = [UIImage imageWithString:[self.profileImages objectAtIndex:2]];
            self.dragView.profileImageView4.image = [UIImage imageWithString:[self.profileImages objectAtIndex:3]];
            self.dragView.profileImageView5.image = [UIImage imageWithString:[self.profileImages objectAtIndex:4]];
            self.dragView.profileImageView6.image = [UIImage imageWithString:[self.profileImages objectAtIndex:5]];
            break;
        default:
            NSLog(@"no images for ProfileImageView switch");
            break;
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

        //[self loadProfileImages];

    }
    else
    {
        NSLog(@"no cards left");
    }
}

-(void)failedToFetchPotentialMatchData:(NSError *)error
{
    NSLog(@"NO POTENTIAL MATCHES FOR USER TO SEE: %@", error);
}

-(void)iPhoneType
{
    if (IS_IPHONE4)
    {
        CARD_HEIGHT = 430;
        CARD_WIDTH = 300;
    }
    else if (IS_IPHONE5)
    {
        CARD_WIDTH = 300;
        CARD_HEIGHT = 518;
    }
    else if (IS_IPHONE6)
    {
        CARD_WIDTH = 355;
        CARD_HEIGHT = 597;
    }
    else if (IS_IPHONE6PLUS)
    {
        CARD_WIDTH = 394;
        CARD_HEIGHT = 686;
    }
}
@end
