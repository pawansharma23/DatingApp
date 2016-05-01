//
//  MessagingViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessagingViewController.h"
#import "MessagingCell.h"
#import "MessageDetailViewCon.h"
#import "UIColor+Pandemos.h"
#import "User.h"
#import "UserManager.h"
#import "MessageManager.h"

@interface MessagingViewController ()
<UITableViewDataSource,
UITableViewDelegate,
UserManagerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) User *recipientUser;
@property (strong, nonatomic) NSArray *matchesNotYetConfirmed;
@property (strong, nonatomic) UserManager *userManager;
@property (strong, nonatomic) MessageManager *messageManager;

@property (strong, nonatomic) NSArray *matches;

@end

@implementation MessagingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [User currentUser];

    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.navigationItem.title = @"Messages";

    self.matchesNotYetConfirmed = [NSArray new];
    self.tableView.delegate = self;

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.matches = [NSArray new];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setupMessageManager];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matches.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessagingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    User *userSelected = [self.matches objectAtIndex:indexPath.row];
    cell.userImage.image = [UIImage imageWithData:[userSelected stringURLToData:[userSelected.profileImages objectAtIndex:indexPath.row]]];
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.userImage.layer.cornerRadius = 22.0 / 2.0f;
    cell.userImage.clipsToBounds = YES;
    cell.lastMessage.text = userSelected.givenName;
    cell.lastMessageTime.text = userSelected.work;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.recipientUser = [self.matches objectAtIndex:indexPath.row];

    [self performSegueWithIdentifier:@"MessageDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessageDetailViewCon *mdvc = segue.destinationViewController;
    mdvc.recipient = self.recipientUser;
}


#pragma mark -- HELPERS
-(void)setupMessageManager
{
    self.messageManager = [MessageManager new];
    [self.messageManager queryForMatches:self.currentUser withResult:^(NSArray *result, NSError *error) {

        self.matches = [result firstObject];

        [self.tableView reloadData];
    }];
}
@end






