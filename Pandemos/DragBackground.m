

#import "DragBackground.h"
#import "AppConstants.h"
#import "UIImage+Additions.h"
#import "SVProgressHUD.h"
#import "AcceptedMatchView.h"
#import "NoMatchesView.h"

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

@synthesize allCards;//%%% all the cards
@synthesize profileImages;
@synthesize alreadyMatched;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [super layoutSubviews];

        [SVProgressHUD show];

        if (IS_IPHONE4)
        {
            CARD_WIDTH = 320 - 20;
            CARD_HEIGHT = 480 - 50;
        }
        else if (IS_IPHONE5)
        {
            CARD_WIDTH = 320 - 20;
            CARD_HEIGHT = 568 - 55;
        }
        else if (IS_IPHONE6)
        {
            CARD_WIDTH = 375 - 30;
            CARD_HEIGHT = 667 - 70;
        }
        else if (IS_IPHONE6PLUS)
        {
            CARD_WIDTH = 414 - 40;
            CARD_HEIGHT = 736 - 80;
        }

        self.userManager = [UserManager new];
        self.userManager.delegate = self;
        //load user data for search preferences
        [self.userManager loadUserData:[User currentUser]];

        //load user objects
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
    }

    return self;
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DragView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    self.dragView = [[DragView alloc]initWithFrame:CGRectMake(15, 50, CARD_WIDTH, CARD_HEIGHT)];
                    //self.dragView.information.text = [exampleCardLabels objectAtIndex:index]; //%%% placeholder for card-specific information
    self.dragView.delegate = self;

    [self loadProfileImagesAtIndex:index];

    return self.dragView;
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
            DragView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];

            NSLog(@"user matched count: %d", i);
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
            if (i > 0)
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
}

-(void)loadProfileImagesAtIndex:(NSInteger)i
{
    User *userDict = [self.potentialMatchData objectAtIndex:i];
    //changed to current user objectAtIndex

    //self.dragView = [[DragView alloc]initWithFrame:self.view.frame];
    
    NSString *nameAndAge = [NSString stringWithFormat:@"%@, %@", userDict[@"givenName"], [userDict[@"birthday"] ageFromBirthday:userDict[@"birthday"]]];
    self.dragView.nameLabel.text = nameAndAge;
    self.dragView.schoolLabel.text = userDict[@"lastSchool"];

    profileImages = userDict[@"profileImages"];

    NSLog(@"%d images for user: %@",(int)profileImages.count, nameAndAge);

    if (profileImages.count == 1)
    {
        [self loadOneImage];
    }
    else if (profileImages.count == 2)
    {
        [self loadTwoImages];
    }
    else if (profileImages.count == 3)
    {
        [self loadThreeImages];
    }
    else if (profileImages.count == 4)
    {
        [self loadFourImages];
    }
    else if (profileImages.count == 5)
    {
        [self loadFiveImages];
    }
    else if (profileImages.count == 6)
    {
        [self loadSixImages];
    }
}

-(void)cardSwipedLeft:(UIView *)card;
{
    User *matchedObject = [self.potentialMatchData objectAtIndex:self.userCount];
    [self setNoStatusForMatchRequestObject:matchedObject];
    self.userCount++;

    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"

    if (cardsLoadedIndex < [allCards count])
    { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    else
    {
        NSLog(@"reached the end of your matches, insert a view");
    }
}

-(void)cardSwipedRight:(UIView *)card
{
    self.currentMatch = [self.potentialMatchData objectAtIndex:self.userCount];
    NSLog(@"matched: %@ & %@", _currentMatch.givenName, [User currentUser].givenName);

    //set match
    [self setYesStatusForMatchRequestObject:self.currentMatch];

    //*** this is the magic that did it!!!
    self.userCount++;
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"

    if (cardsLoadedIndex < [allCards count])
    { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    else
    {
        if (self.userCount >1)
        {
            NSLog(@"user count: %d", (int)self.userCount);
        }
        else
        {
            //need to implement these methods when no users are left this is hitting when there is one left??
            
            //NoMatchesView *matchView = [[NoMatchesView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH + 30, CARD_HEIGHT + 70)];
            //[matchView loadNoMatchesImage:@"aLogo"];
            //[self addSubview:matchView];
        }
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

#pragma mark -- HELPERS
-(void)snapAcceptedMatchViewToStartNewConvo
{
    self.alpha = .7;
    self.backgroundColor = [UIColor blackColor];

    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];

    AcceptedMatchView *matchView = [[AcceptedMatchView alloc]initWithFrame:CGRectMake(0, 0, 200, 100)];
    [self addSubview:matchView];

    UISnapBehavior *snapBehaviour = [[UISnapBehavior alloc] initWithItem:matchView snapToPoint:CGPointMake(100, 300)];
    snapBehaviour.damping = 0.65f;
    [animator addBehavior:snapBehaviour];
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
    [self.userManager loadAlreadySeenMatches];//returns to the didLoadAlreadySeen
}
//Step 4
-(void)didLoadAlreadySeen:(NSArray<User *> *)users
{
    //NSLog(@"already seen users: %@", users);
    //loop through all matched users and compare to all current matches
    NSMutableArray *intersectionArray = [NSMutableArray arrayWithArray:self.userManager.allMatchedUsers];

    for (User *allMatches in self.userManager.allMatchedUsers)
    {
        NSLog(@"match: %@", allMatches.givenName);

        for (NSDictionary *matchRequest in users)//self.userManager.alreadySeenUser
        {
            User *fromUser = matchRequest[@"fromUser"];
            User *toUser = matchRequest[@"toUser"];

            if ([allMatches.objectId isEqualToString:fromUser.objectId] || [allMatches.objectId isEqualToString:toUser.objectId])
            {
                NSLog(@"Removed: %@", allMatches.givenName);
                [intersectionArray removeObject:allMatches];
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
        NoMatchesView *matchView = [[NoMatchesView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH + 30, CARD_HEIGHT + 70)];
        //[matchView loadNoMatchesImage:@"aLogo"];
        [self addSubview:matchView];
    }

    [SVProgressHUD dismiss];
}

-(void)failedToFetchPotentialMatchData:(NSError *)error
{
    NSLog(@"NO POTENTIAL MATCHES FOR USER TO SEE: %@", error);
}

#pragma mark -- Swipe YES OR NO HELPERS
-(void)setYesStatusForMatchRequestObject:(User*)potentialMatch
{
    if ([self.gender isEqualToString:@"male"])
    {
        [self matchStatus:@"boyYes" potentialMatch:potentialMatch];
    }
    else if ([self.gender isEqualToString:@"female"])
    {
        [self matchStatus:@"girlYes" potentialMatch:potentialMatch];
    }
    else
    {
        NSLog(@"neither boy nor girl???");
    }
}

//1a)
-(void)setNoStatusForMatchRequestObject:(User*)deniedMatch
{
    [self matchStatus:@"denied" potentialMatch:deniedMatch];
}

//2
-(void)matchStatus:(NSString*)status potentialMatch:(User*)potMatch
{
    [[MatchManager sharedSettings] createMatchRequest:potMatch withStatus:status andBlock:^(MatchRequest *matchRequest, NSError *error) {
        
        //2a) Status on MatchRequest class determines what to do
        [[MatchManager sharedSettings] queryForMatchRequestWithUserSeen:potMatch withStatusBlock:^(NSString *status, NSError *error) {

            if ([status isEqualToString:@"denied"])//2a-1 & 2b-2
            {
                NSLog(@"dies here, no further action necessary");
            }

            else if ([status isEqualToString:@"boyYes"])//2a-2
            {
                //we have a mutal match between users
                NSString *email = [User currentUser].confidantEmail;
                [[MatchManager sharedSettings] sendEmailForMatch:potMatch.objectId withMatchId:matchRequest.objectId withEmail:email matchedUser:potMatch];
            }

            else if ([status isEqualToString:@"girlYes"])//2b-1
            {
                //means the current user has matched with a girl and she has accepted but hasnt gone to her confidant yet
                //BEta 2 screen that says "it's a match, now at the mercy of her confidant"
                NSLog(@"do nothing, wait for Heroku to send message from Confidant adding the PFRelation and it will send a Notification");
            }

            else if ([status isEqualToString:@"girlVerified"])//2b-3
            {
                //we have a match, the guy can send a message---> setup PFRelation from other perspective and in callback block call the match view allowing the guy to chat right away with the girl
                [[MatchManager sharedSettings] createVerifiedPFRelationWithPFCloud:potMatch andMatchRequest:matchRequest withMatchBlock:^(MatchRequest *matchRequest, NSError *error) {

                    if (matchRequest)
                    {
                        [self loadMatchAndChatView];
                    }
                    else
                    {
                        NSLog(@"error saving PFRelation to Parse: %@", error);
                    }
                }];
            }

            else if([status isEqualToString:@"confidantNo"])//2b-4
            {
                NSLog(@"do nothing but... girl sent email to confidant they said no, Beta 1.01 guy can pay to get a PFRelation");
            }

            else if ([status isEqualToString:@"confidantKibosh"])//2b-4
            {
                NSLog(@"dies here, version 2 will offer guy to pay");
            }

            else
            {
                if ([[User currentUser].gender isEqualToString:@"female"])//2a-3//for unseen
                {
                    NSString *email = [User currentUser].confidantEmail;
                    [[MatchManager sharedSettings] sendEmailForUnseen:matchRequest.objectId withEmail:email matchedUser:potMatch];
                }
            }
        }];

        [SVProgressHUD dismiss];//after the MatchRequest is made the progress bar is dismissed
    }];
}

#pragma mark -- USER IMAGES
-(void)loadMatchAndChatView
{
    MatchAndChatView *matchView = [[MatchAndChatView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH -20, CARD_HEIGHT-40)];
    matchView.delegate = self;
    [matchView setMatchImages:profileImages.firstObject.url];
    [matchView setLabelNames:_currentMatch.givenName];
    matchView.center = CGPointMake((self.frame.size.width - 85) / 2, self.frame.size.height / 2);
    [self addSubview:matchView];
}

-(void)didPressElsewhere
{
    NSLog(@"take away nib");
}

-(void)didPressToChat
{
    NSLog(@"chat segue");
}

-(void)loadOneImage
{
    self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 1);

    PFFile *i0 = [profileImages objectAtIndex:0];
    self.dragView.profileImageView.image = [UIImage imageWithString:i0.url];

    [self.dragView.v2 removeFromSuperview];
    [self.dragView.v3 removeFromSuperview];
    [self.dragView.v4 removeFromSuperview];
    [self.dragView.v5 removeFromSuperview];
    [self.dragView.v6 removeFromSuperview];
    [SVProgressHUD dismiss];
}

-(void)loadTwoImages
{
    self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 2);

    PFFile *i0 = [profileImages objectAtIndex:0];
    PFFile *i1 = [profileImages objectAtIndex:1];
    self.dragView.profileImageView.image = [UIImage imageWithString:i0.url];
    self.dragView.profileImageView2.image = [UIImage imageWithString:i1.url];

    [self.dragView.v3 removeFromSuperview];
    [self.dragView.v4 removeFromSuperview];
    [self.dragView.v5 removeFromSuperview];
    [self.dragView.v6 removeFromSuperview];
    [SVProgressHUD dismiss];
}

-(void)loadThreeImages
{
    self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 3);

    PFFile *i0 = [profileImages objectAtIndex:0];
    PFFile *i1 = [profileImages objectAtIndex:1];
    PFFile *i2 = [profileImages objectAtIndex:2];
    self.dragView.profileImageView.image = [UIImage imageWithString:i0.url];
    self.dragView.profileImageView2.image = [UIImage imageWithString:i1.url];
    self.dragView.profileImageView3.image = [UIImage imageWithString:i2.url];

    [self.dragView.v4 removeFromSuperview];
    [self.dragView.v5 removeFromSuperview];
    [self.dragView.v6 removeFromSuperview];
    [SVProgressHUD dismiss];
}

-(void)loadFourImages
{
    self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 4);

    PFFile *i0 = [profileImages objectAtIndex:0];
    PFFile *i1 = [profileImages objectAtIndex:1];
    PFFile *i2 = [profileImages objectAtIndex:2];
    PFFile *i3 = [profileImages objectAtIndex:3];
    self.dragView.profileImageView.image = [UIImage imageWithString:i0.url];
    self.dragView.profileImageView2.image = [UIImage imageWithString:i1.url];
    self.dragView.profileImageView3.image = [UIImage imageWithString:i2.url];
    self.dragView.profileImageView4.image = [UIImage imageWithString:i3.url];

    [self.dragView.v5 removeFromSuperview];
    [self.dragView.v6 removeFromSuperview];
    [SVProgressHUD dismiss];
}

-(void)loadFiveImages
{
    self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 5);

    PFFile *i0 = [profileImages objectAtIndex:0];
    PFFile *i1 = [profileImages objectAtIndex:1];
    PFFile *i2 = [profileImages objectAtIndex:2];
    PFFile *i3 = [profileImages objectAtIndex:3];
    PFFile *i4 = [profileImages objectAtIndex:4];
    self.dragView.profileImageView.image = [UIImage imageWithString:i0.url];
    self.dragView.profileImageView2.image = [UIImage imageWithString:i1.url];
    self.dragView.profileImageView3.image = [UIImage imageWithString:i2.url];
    self.dragView.profileImageView4.image = [UIImage imageWithString:i3.url];
    self.dragView.profileImageView5.image = [UIImage imageWithString:i4.url];

    [self.dragView.v6 removeFromSuperview];
    [SVProgressHUD dismiss];
}

-(void)loadSixImages
{
    self.dragView.imageScroll.contentSize = CGSizeMake(self.dragView.frame.size.width, self.dragView.frame.size.height * 6);

    PFFile *i0 = [profileImages objectAtIndex:0];
    PFFile *i1 = [profileImages objectAtIndex:1];
    PFFile *i2 = [profileImages objectAtIndex:2];
    PFFile *i3 = [profileImages objectAtIndex:3];
    PFFile *i4 = [profileImages objectAtIndex:4];
    PFFile *i5 = [profileImages objectAtIndex:5];
    self.dragView.profileImageView.image = [UIImage imageWithString:i0.url];
    self.dragView.profileImageView2.image = [UIImage imageWithString:i1.url];
    self.dragView.profileImageView3.image = [UIImage imageWithString:i2.url];
    self.dragView.profileImageView4.image = [UIImage imageWithString:i3.url];
    self.dragView.profileImageView5.image = [UIImage imageWithString:i4.url];
    self.dragView.profileImageView6.image = [UIImage imageWithString:i5.url];
    [SVProgressHUD dismiss];
}
@end
