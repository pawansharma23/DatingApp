
//
//  MessagingViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessagingList.h"
#import "MessagingCell.h"
#import "MatchesCell.h"
#import "MessageDetailViewCon.h"
#import "User.h"
#import "UserManager.h"
#import "MessageManager.h"
#import "AllyAdditions.h"
#import "AppConstants.h"
#import "SVProgressHUD.h"

@interface MessagingList ()
<UITableViewDataSource,
UITableViewDelegate,
UserManagerDelegate,
UICollectionViewDelegate,
UICollectionViewDataSource,
MessageManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *recipientUser;
@property (strong, nonatomic) User *recipientNewConvoUser;


@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) MessageManager *messageManager;

@property (strong, nonatomic) NSArray *matches;
@property (strong, nonatomic) NSArray *chatters;

@property (strong, nonatomic) NSArray *lastLines;
@property (strong, nonatomic) NSString *selectedId;

@property (strong, nonatomic) MessageDetailViewCon *activeDialogViewController;

@end

@implementation MessagingList

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];
    self.messageManager = [MessageManager new];
    self.messageManager.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.navigationItem.title = @"Messages";
    self.backButton.tintColor = [UIColor mikeGray];
    self.backButton.image = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];

    self.matches = [NSArray new];
    self.chatters = [NSMutableArray new];
    self.lastLines = [NSArray new];

    self.tableView.delegate = self;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setFlowLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //collectionView matches pre chat
    [self setupMatches];

    //tableview chats
    [self setupChatters];
}

#pragma mark -- COLLECTION VIEW DELEGATE
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"match count: %d", (int)self.matches.count);
    return self.matches.count;
}

-(MatchesCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MatchesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MatchesCell" forIndexPath:indexPath];
    User *user = [self.matches objectAtIndex:indexPath.item];

    cell.nameLabel.text = user.givenName;
    cell.matchImage.layer.cornerRadius = 37.5;
    cell.matchImage.layer.masksToBounds = YES;
    cell.matchImage.image = [UIImage imageWithImage:[UIImage imageWithString:user.profileImages.firstObject] scaledToSize:CGSizeMake(75, 75)];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    User *matchedUser = [self.matches objectAtIndex:indexPath.row];
    [self.messageManager queryIfChatExists:matchedUser currentUser:self.currentUser withSuccess:^(BOOL success, NSError *error) {

        if (success)
        {
            [self addConversationAlreadyExistsAlert:matchedUser];
        }
        else
        {
            NSLog(@"first time chatters send initial message");
            [self.messageManager sendInitialMessage:matchedUser];
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
    return 25;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatters.count;
}

-(MessagingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *chat = [self.chatters objectAtIndex:indexPath.row];

    cell.userImage.image = [UIImage imageWithImage:[UIImage imageWithString:chat[@"repImage"]] scaledToSize:CGSizeMake(45, 45)];
    cell.userImage.layer.cornerRadius = 22.5;
    cell.userImage.layer.masksToBounds = YES;
    cell.lastMessage.text = chat[@"repName"];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *chat = [self.chatters objectAtIndex:indexPath.row];
    User *toUser = chat[@"toUser"];
    User *fromUser = chat[@"fromUser"];

    if ([toUser isEqual:[User currentUser]])
    {
        [UserManager sharedSettings].recipient = fromUser;
    }
    else
    {
        [UserManager sharedSettings].recipient = toUser;
    }

    [self performSegueWithIdentifier:@"detailMessage" sender:self];
}

#pragma mark --NAV
- (IBAction)onBackButton:(UIBarButtonItem *)sender
{
    NSLog(@"tapping");
    [self.navigationController dismissViewControllerAnimated:YES completion:^{

    }];
}

#pragma mark -- MESSAGE MANAGER DELEGATES
//from creation of new convo from CollectionView selection
-(void)didRecieveChatterData:(User *)chatter
{
    if (chatter)
    {
        NSLog(@"initial message went through, now send to message detail VC");
        [UserManager sharedSettings].recipient = chatter;
        [self performSegueWithIdentifier:@"detailMessage" sender:self];
    }

    [self.tableView reloadData];
}

#pragma mark -- HELPERS
//collectionview
-(void)setupMatches
{
    [self.messageManager queryForMatches:^(NSArray *result, NSError *error) {

        if (result.count > 0)
        {
            self.matches = result;
            NSLog(@"matches: %d", (int)result.count);
        }
        else
        {
            NSLog(@"no matches returned");
        }

        [self.collectionView reloadData];

    }];

    [SVProgressHUD dismiss];

}

//tableview
-(void)setupChatters
{
    [self.messageManager queryForChattersImage:^(NSArray *result, NSError *error) {

        if (result.count > 0)
        {
            self.chatters = result;
            NSLog(@"chatters: %d", (int)result.count);
        }
        
        [self.tableView reloadData];
    }];

        [SVProgressHUD dismiss];
}

-(void)addConversationAlreadyExistsAlert:(User *)matchedUser
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Chat exists"
                                message:nil
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"Go to Conversation ->"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [UserManager sharedSettings].recipient = matchedUser;
                             [self performSegueWithIdentifier:@"detailMessage" sender:self];
                         }];

    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:^{

                                 }];
                             }];

    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)setFlowLayout
{
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 2;
    layout.headerReferenceSize = CGSizeMake(300, 20);

//    LXReorderableCollectionViewFlowLayout *flowlayouts = [LXReorderableCollectionViewFlowLayout new];
//    [flowlayouts setItemSize:CGSizeMake(100, 100)];
//    [flowlayouts setScrollDirection:UICollectionViewScrollDirectionVertical];
//    flowlayouts.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    flowlayouts.headerReferenceSize = CGSizeMake(300, 20);
//    flowlayouts.footerReferenceSize = CGSizeZero;

    //[self.collectionView setCollectionViewLayout:flowlayouts];
    self.collectionView.contentInset = UIEdgeInsetsZero;
}
@end





