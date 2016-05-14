//
//  MessagingViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessagingViewController.h"
#import "MessagingCell.h"
#import "MatchesCell.h"
#import "MessageDetailViewCon.h"
#import "User.h"
#import "UserManager.h"
#import "MessageManager.h"
#import "UIColor+Pandemos.h"
#import "UIImage+Additions.h"

@interface MessagingViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UserManagerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *recipientUser;
@property (strong, nonatomic) User *chatter;

@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) MessageManager *messageManager;

@property (strong, nonatomic) NSArray *matches;
@property (strong, nonatomic) NSArray *chatters;
@property (strong, nonatomic) NSArray *lastLines;

@end

@implementation MessagingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];
    self.messageManager = [MessageManager new];
    
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.navigationItem.title = @"Messages";

    self.backButton.tintColor = [UIColor mikeGray];
    UIImage *closeNavBarButton = [UIImage imageWithImage:[UIImage imageNamed:@"Back-100"] scaledToSize:CGSizeMake(30.0, 30.0)];
    [self.navigationItem.leftBarButtonItem setImage:closeNavBarButton];

    self.matches = [NSArray new];
    self.chatters = [NSArray new];
    self.lastLines = [NSArray new];

    self.tableView.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setupMatches];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setupMatches];
    [self setupConversationList];
    [self setupChatters];
}

#pragma mark -- COLLECTION VIEW DELEGATE
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.matches.count;
}

-(MatchesCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MatchesCell";
    MatchesCell *cell = (MatchesCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    User *user = [self.matches objectAtIndex:indexPath.item];

    [self setupCVCell:cell];
    cell.matchImage.image = [UIImage imageWithData:[user stringURLToData:user.profileImages.firstObject]];
    cell.nameLabel.text = user[@"givenName"];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index Path: %d", (int)indexPath.row);
    self.recipientUser = [self.matches objectAtIndex:indexPath.row];

    [self.messageManager queryIfChatExists:self.recipientUser currentUser:self.currentUser withSuccess:^(BOOL success, NSError *error) {

        if (success)
        {
            //add code to switch PFRelation object text
            [self performSegueWithIdentifier:@"detailMessage" sender:self];
            NSLog(@"chat object already exists");

        }
        else
        {
            [self.messageManager sendInitialMessage:self.recipientUser];
            NSLog(@"first time chatters send initial message");
            [self performSegueWithIdentifier:@"detailMessage" sender:self];
        }
    }];


}

#pragma mark -- TABLEVIEW DELEGATE
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Chats";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatters.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *chat = [self.chatters objectAtIndex:indexPath.row];
    [self setupConversationCell:cell withUserData:chat];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chatter = [self.chatters objectAtIndex:indexPath.row];
    self.recipientUser = self.chatter[@"toUser"];
    [self performSegueWithIdentifier:@"detailMessage" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessageDetailViewCon *mdvc = segue.destinationViewController;
    mdvc.recipient = self.recipientUser;
}

- (IBAction)onBackButton:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- HELPERS
-(void)setupMatches
{
    [self.messageManager queryForMatches:^(NSArray *result, NSError *error) {

        self.matches = result;
        [self.collectionView reloadData];
    }];
}

-(void)setupConversationList
{
    //every chat object, filtered to take out blank string chats
    [self.messageManager queryForChats:^(NSArray *result, NSError *error) {

        //the chatter object shuld query the [PFUser query] PFRelation with the updated status string from line 108

        for (NSDictionary *dict in result)
        {
            //only grabbing last object in result array
            self.lastLines = dict[@"text"];

        }

        [self.tableView reloadData];
    }];
}

-(void)setupChatters
{
    //only the first send chat to get the user data from for the tableview
    [self.messageManager queryForChattersImage:^(NSArray *result, NSError *error) {

        self.chatters = result;
        [self.tableView reloadData];
    }];
}

-(void)setupConversationCell:(MessagingCell*)cell withUserData:(NSDictionary*)chatter
{
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.userImage.layer.cornerRadius = 22.0 / 2.0f;
    cell.userImage.clipsToBounds = YES;
    cell.lastMessage.text = chatter[@"repName"];
    cell.lastMessageTime.text = chatter[@"text"];
    cell.userImage.image = [UIImage imageWithData:[self stringURLToData:chatter[@"repImage"]]];

    //data unique to individual chat
//    NSDate *theDate = [user objectForKey:@"timestamp"];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH:mm a"];
//    NSString *timeString = [formatter stringFromDate:theDate];
//    [user objectForKey:@"text"];
}

-(void)setupCVCell:(MatchesCell*)cell
{
    //cell.matchImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.matchImage.layer.cornerRadius = 22.0 / 2.0f;
    //cell.matchImage.clipsToBounds = YES;
}

-(NSData *)stringURLToData:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];

    return data;
}
@end






