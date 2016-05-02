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
#import "UIColor+Pandemos.h"
#import "User.h"
#import "UserManager.h"
#import "MessageManager.h"

@interface MessagingViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UserManagerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *recipientUser;
@property (strong, nonatomic) User *chatter;

@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) MessageManager *messageManager;

@property (strong, nonatomic) NSArray *matches;
@property (strong, nonatomic) NSArray *rawMatches;
@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation MessagingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];

    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.navigationItem.title = @"Messages";

    self.matches = [NSArray new];
    self.rawMatches = [NSArray new];
    self.chats = [NSMutableArray new];

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
    cell.matchImage.image = [UIImage imageWithData:[user stringURLToData:[user.profileImages objectAtIndex:indexPath.row]]];
    cell.nameLabel.text = user.givenName;

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.recipientUser = [self.messageManager.matches objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"detailMessage" sender:self];

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
    return self.chats.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    User *user = [self.chats objectAtIndex:indexPath.row];
    [self setupImageForCell:cell];
    //cell.userImage.image = [UIImage imageWithData:[user stringURLToData:[user.profileImages objectAtIndex:indexPath.row]]];
    //cell.lastMessage.text = user.givenName;
    //cell.lastMessageTime.text = user.work;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chatter = [self.chats objectAtIndex:indexPath.row];
    NSLog(@"%@", self.chatter);

   // [self performSegueWithIdentifier:@"detailMessage" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessageDetailViewCon *mdvc = segue.destinationViewController;
    mdvc.recipient = self.recipientUser;
}


#pragma mark -- HELPERS
-(void)setupMatches
{
    self.messageManager = [MessageManager new];
    [self.messageManager queryForMatches:self.currentUser withResult:^(NSArray *result, NSError *error) {

        self.matches = [result firstObject];
        [self.collectionView reloadData];
    }];
}

-(void)setupChatters
{
    [self.messageManager queryForChats:self.currentUser withResult:^(NSArray *result, NSError *error) {

        self.chats = [NSMutableArray arrayWithArray:result];
        NSLog(@"chatter objects: %@", self.chats);
        [self.tableView reloadData];
    }];
}

-(void)setupImageForCell:(MessagingCell*)cell
{
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.userImage.layer.cornerRadius = 22.0 / 2.0f;
    cell.userImage.clipsToBounds = YES;
}

-(void)setupCVCell:(MatchesCell*)cell
{
    cell.matchImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.matchImage.layer.cornerRadius = 22.0 / 2.0f;
    cell.matchImage.clipsToBounds = YES;
}
@end






