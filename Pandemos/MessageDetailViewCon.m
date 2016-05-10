//
//  MessageDetailViewCon.m
//  Pandemos
//
//  Created by Michael Sevy on 1/13/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessageDetailViewCon.h"
#import "MessageDetailCell.h"
#import "MessagingViewController.h"
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>
#import <Parse/Parse.h>
#import "User.h"
#import "UIColor+Pandemos.h"
#import "MessageManager.h"
#import "UserManager.h"
#import "UIImage+Additions.h"
#import "MessagerProfileVC.h"

#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 50

@interface MessageDetailViewCon ()<UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButton;
@property BOOL reloading;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) NSDictionary *lastObject;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) MessageManager *messageManager;
@property (strong, nonatomic) NSString *userImage;


@end

@implementation MessageDetailViewCon
//@synthesize textField;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];
    self.messageManager = [MessageManager new];
    self.lastObject = [NSDictionary new];
    self.chatData = [NSMutableArray new];

    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    self.navigationController.navigationBar.backgroundColor = [UIColor rubyRed];

//    UIImage *moreButton = [UIImage imageWithImage:[UIImage imageNamed:@"Forward"] scaledToSize:CGSizeMake(25.0, 25.0)];
    //[self.navigationItem.rightBarButtonItem setImage:moreButton];
    //self.navigationItem.rightBarButtonItem.tintColor = [UIColor darkGrayColor];
    [self.forwardBarButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"Forward"] scaledToSize:CGSizeMake(25.0, 25.0)]];
    self.forwardBarButton.tintColor = [UIColor darkGrayColor];

    [self.backBarButton setImage:[UIImage imageWithImage:[UIImage imageNamed:@"Back-100"] scaledToSize:CGSizeMake(25.0, 25.0)]];
    self.backBarButton.tintColor = [UIColor darkGrayColor];

    _textField.delegate = self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(startRefresh:)
//             forControlEvents:UIControlEventValueChanged];
//    [self.collectionView addSubview:refreshControl];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.chatData = [NSMutableArray new];
    [self loadChat];
    [self loadChatWithImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

#pragma mark -- TEXTFIELD DELEGATES
//-(IBAction) backgroundTap:(id) sender
//{
//    [self.textField resignFirstResponder];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"text entry: %@", textField.text);
    //[textField resignFirstResponder];

    if (textField.text.length > 0)
    {
        // updating the table immediately
        NSArray *keys = [NSArray arrayWithObjects:@"text", @"userName", @"date", nil];
        NSArray *objects = [NSArray arrayWithObjects:textField.text, self.currentUser, [NSDate date], nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [self.chatData addObject:dictionary];

        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [insertIndexPaths addObject:newPath];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        [self.tableView reloadData];

        // send message in Parse
        [self.messageManager sendMessage:self.currentUser toUser:self.recipient withText:textField.text];

        //reset textField
        textField.text = @"";
        return YES;
    }

    // reload the data
    [self loadChat];
    return NO;
}

#pragma mark -- TABLEVIEW DELEGATE
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier: @"Cell"];
    NSDictionary *chatText = [self.chatData objectAtIndex:indexPath.row];
    [self setupImageInCell:cell];
    NSUInteger row = [_chatData count]-[indexPath row]-1;
    User *user = [self.chatData objectAtIndex:indexPath.row];
    User *userObject = user[@"fromUser"];
    //incoming vs. outgoing
    if ([[User currentUser].objectId isEqualToString:userObject.objectId])
    {
        cell.imageView.image = [UIImage imageWithData:[self stringURLToData:self.lastObject[@"fromImage"]]];

        if (row < _chatData.count)
        {
            //NSString *chatText = [[_chatData objectAtIndex:indexPath.row] objectForKey:@"text"];

            if (chatText)
            {
                [self setupCellForText:cell andChat:chatText index:indexPath];
            }
            else
            {
                [cell removeFromSuperview];
            }
        }
    }
    else
    {
        NSLog(@"incoming message");
        NSLog(@"user objectID: %@", user[@"fromUser"]);
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        [self setupCellForText:cell andChat:chatText index:indexPath];
    }

    return cell;
}

-(void)doneLoadingCollectionViewData
{
    self.reloading = NO;
    //[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:chatTable];
}


//keyboard methods
-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];

    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height+TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];

    [UIView commitAnimations];

}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];

    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];

    [UIView commitAnimations];
}

#pragma mark -- HELPERS
-(void)loadChat
{
    [self.messageManager queryForChatTextAndTimeOnly:self.recipient andConvo:^(NSArray *result, NSError *error) {

        self.chatData = [NSMutableArray arrayWithArray:result];
        [self.tableView reloadData];
    }];
}

-(void)loadChatWithImage
{
    [self.messageManager queryForChat:self.recipient andConvo:^(NSArray *result, NSError *error) {

        self.lastObject = result.lastObject;
        self.navigationItem.title = self.lastObject[@"repName"];
        [self.tableView reloadData];
    }];
}

-(NSData *)stringURLToData:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];

    return data;
}

-(void)setupImageInCell:(UITableViewCell*)cell
{
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.layer.cornerRadius = 22.0 / 2.0f;
    cell.imageView.clipsToBounds = YES;
}

-(void)setupCellForText:(UITableViewCell*)cell andChat:(NSDictionary*)chatDict index:(NSIndexPath*)indexPath
{
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = CGSizeMake(10.0, 10.0);
    cell.textLabel.frame = CGRectMake(75, 14, size.width +20, size.height + 20);
    cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:14.0];
    cell.textLabel.text = chatDict[@"text"];
    [cell.textLabel sizeToFit];

    //NSDate *theDate = [[_chatData objectAtIndex:row] objectForKey:@"timestamp"];
    NSDate *theDate = [[self.chatData objectAtIndex:indexPath.row] objectForKey:@"timestamp"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm a"];
    NSString *timeString = [formatter stringFromDate:theDate];
    cell.detailTextLabel.text = timeString;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessagerProfileVC *mpvc = [segue destinationViewController];
    mpvc.messagingUser = self.recipient;
}
@end
//-(void)loadLocalChat
//{
//    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
//    //query to user and recipient specific
//    [query whereKey:@"recipientId" equalTo:self.currentUser];
//
//    // If no objects are loaded in memory, we look to the cache first to fill the table
//    // and then subsequently do a query against the network.
//    if ([_chatData count] == 0) {
//        NSLog(@"no chat data");
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//        [query orderByAscending:@"createdAt"];
//        NSLog(@"Trying to retrieve from cache");
//
//
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if (!error) {
//                // The find succeeded.
//                NSLog(@"Successfully retrieved %zd chats from cache.", objects.count);
//                [_chatData removeAllObjects];
//                [_chatData addObjectsFromArray:objects];
//                [self.tableView reloadData];
//            } else {
//                // Log details of the failure
//                NSLog(@"Error Above: %@ %@", error, [error userInfo]);
//            }
//        }];
//    }
//
//    PFQuery *query2 = [PFQuery queryWithClassName:@"Chat"];
//    [query2 whereKey:@"recipientId" equalTo:self.currentUser];
//    [query2 orderByDescending:@"createdAt"];
//
//    __block int totalNumberOfEntries = 0;
//    [query2 countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
//        if (!error) {
//            // The count request succeeded. Log the count
//            NSLog(@"There are currently %d entries", number);
//            totalNumberOfEntries = number;
//            if (totalNumberOfEntries > [_chatData count]) {
//                NSLog(@"Retrieving data");
//                long theLimit;
//
//                if (totalNumberOfEntries-[_chatData count]> 25)
//                {
//                    theLimit = 25;
//                }
//                else
//                {
//                    theLimit = (long)totalNumberOfEntries - [_chatData count];
//                }
//                query2.limit = (long)[NSNumber numberWithLong:theLimit];
//                [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                    if (!error) {
//                        // The find succeeded.
//                        NSLog(@"Successfully retrieved %zd chats.", objects.count);
//                        [_chatData addObjectsFromArray:objects];
//                        NSMutableArray *insertIndexPaths = [[NSMutableArray alloc] init];
//                        for (int ind = 0; ind < objects.count; ind++)
//                        {
//                            NSIndexPath *newPath = [NSIndexPath indexPathForRow:ind inSection:0];
//                            [insertIndexPaths addObject:newPath];
//                        }
//                        [self.tableView beginUpdates];
//                        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
//                        [self.tableView endUpdates];
//                        [self.tableView reloadData];
//                        [self.tableView scrollsToTop];
//                    } else
//                    {
//                        // Log details of the failure
//                        NSLog(@"Error below: %@ %@", error, [error userInfo]);
//                    }
//                }];
//            }
//
//        } else {
//            // The request failed, we'll keep the chatData count?
//            number = (int)[_chatData count];
//        }
//    }];
//
//}
//PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
//[query whereKey:@"recipientId" equalTo:self.currentUser];
//[query whereKey:@"recipientId" equalTo:self.recipient];
//[query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//    if (error) {
//        NSLog(@"error in VDL: %@", error);
//    }
//
//    if (objects.count == 0) {
//        NSLog(@"convo between %@ & %@ has no chats yet", userName, repName);
//    } else  {
//        PFUser *chat1 = [objects objectAtIndex:0];
//        NSString *text = [chat1 objectForKey:@"text"];
//
//        NSLog(@"convo between: %@ & %@ ID: %@\n chats:%@", userName, repName, self.recipient.objectId, text);
//    }
//}];
