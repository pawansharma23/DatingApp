//
//  MessageDetailViewCon.m
//  Pandemos
//
//  Created by Michael Sevy on 1/13/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessageDetailViewCon.h"
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
#import "MatchView.h"
#import "NSString+Additions.h"
#import "MessageCell.h"

#define TABBAR_HEIGHT 49.0f
#define TEXTFIELD_HEIGHT 70.0f
#define MAX_ENTRIES_LOADED 50

@interface MessageDetailViewCon ()<UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate,
MatchViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backToMessaging;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardToUserDetail;

@property BOOL reloading;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) NSDictionary *lastObject;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) MessageManager *messageManager;

@property (strong, nonatomic) NSString *userImage;
@property (strong, nonatomic) NSString *userGiven;
@property (strong, nonatomic) NSString *user;


@end

@implementation MessageDetailViewCon

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];
    self.messageManager = [MessageManager new];
    self.lastObject = [NSDictionary new];
    self.chatData = [NSMutableArray new];

    self.navigationController.navigationBar.barTintColor = [UIColor yellowGreen];
    //self.forwardToUserDetail.tintColor = [UIColor mikeGray];
    //self.forwardToUserDetail.image = [UIImage imageWithImage:[UIImage imageNamed:@"Forward"] scaledToSize:CGSizeMake(25.0, 25.0)];
    self.backToMessaging.image = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];
    self.backToMessaging.tintColor = [UIColor mikeGray];

    _textField.delegate = self;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.chatData = [NSMutableArray new];
    [self loadChat];
    [self loadChatWithImage];
    [self loadUserData];
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

    if (textField.text.length > 0)
    {
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

        [self.messageManager sendMessage:self.currentUser toUser:self.recipient withText:textField.text];

        //reset textField
        textField.text = @"";
        [textField resignFirstResponder];
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

-(MessageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier: @"Cell"];
    NSDictionary *chatText = [self.chatData objectAtIndex:indexPath.row];

    NSUInteger row = [_chatData count]-[indexPath row]-1;
    User *fromUser = chatText[@"fromUser"];
    User *toUser = chatText[@"toUser"];

        if (row < _chatData.count)
        {
            if (chatText && [fromUser.objectId isEqualToString:[User currentUser].objectId])
            {
                [self outgoingCellForText:cell andChat:chatText index:indexPath];
            }
            else if(chatText && [toUser.objectId isEqualToString:self.recipient.objectId])
            {
                [self incomingCellForText:cell andChat:chatText index:indexPath];
            }
            else
            {
                [cell removeFromSuperview];
            }
        }



    return cell;
}

-(void)doneLoadingCollectionViewData
{
    self.reloading = NO;
    //[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:chatTable];
}


#pragma mark -- KEYBOARD DELEGATES
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
    [self.messageManager queryForChatTextAndTime:self.recipient andConvo:^(NSArray *result, NSError *error) {

        self.chatData = [NSMutableArray arrayWithArray:result];
        [self.tableView reloadData];
    }];
}

-(void)loadChatWithImage
{
    [self.messageManager queryForChats:^(NSArray *result, NSError *error) {

        self.lastObject = result.lastObject;
        self.navigationItem.title = self.lastObject[@"repName"];
        [self.tableView reloadData];
    }];
}

-(void)loadUserData
{
    UserManager *userManager = [UserManager new];
    [userManager queryForUserData:self.recipient.objectId withUser:^(User *users, NSError *error) {

        NSDictionary *userDict = users;
        self.userGiven = userDict[@"givenName"];
        NSArray *array = userDict[@"profileImages"];
        self.userImage = array.firstObject;

        [self loadMatchView];
    }];
}

-(void)loadMatchView
{
    MatchView *matchView = [[MatchView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.navigationItem.titleView = matchView;
    matchView.delegate = self;
    [matchView setMatchViewWithChatter:self.userGiven];
    [matchView setMatchViewWithChatterDetailImage:self.userImage];
}

-(void)outgoingCellForText:(MessageCell*)cell andChat:(NSDictionary*)chatDict index:(NSIndexPath*)indexPath
{
    NSString *text = chatDict[@"text"];

    if (text.length == 0)
    {
        [_chatData removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
    else
    {
        //cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//        cell.textLabel.textAlignment = NSTextAlignmentRight;
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        CGSize size = CGSizeMake(10.0, 10.0);
//        cell.textLabel.frame = CGRectMake(175, 14, size.width +20, size.height + 20);
//        cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:14.0];
//        cell.textLabel.text = chatDict[@"text"];
//        [cell.textLabel sizeToFit];

//        cell.textView.text = chatDict[@"text"];
//        CGSize textViewSize = CGSizeMake(cell.textView.contentSize.width, cell.textView.contentSize.height);
//        [cell addSubview:textViewSize];

        [cell setCellForMessage:text];
        cell.indexPath = indexPath;
        cell.transform = self.tableView.transform;

        //[self formatDate:cell atIndexPath:indexPath];
        //cell.detailTextLabel.text = [NSString timeFromData:[[self.chatData objectAtIndex:indexPath.row] objectForKey:@"timestamp"]];

//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 100, 30)];
//        label.textAlignment = NSTextAlignmentRight;
//        label.lineBreakMode = NSLineBreakByWordWrapping;
//        [label sizeToFit];
//        label.backgroundColor = [UIColor purpleColor];
//        label.textColor = [UIColor blackColor];



//        cell.outgoingTimeLabel.text = [NSString timeFromData:[[self.chatData objectAtIndex:indexPath.row] objectForKey:@"timestamp"]];
//        cell.incomingTimeLabel.hidden = YES;

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [indexPath row] * 20;
}


-(void)incomingCellForText:(UITableViewCell*)cell andChat:(NSDictionary*)chatDict index:(NSIndexPath*)indexPath
{
    NSString *text = chatDict[@"text"];

    if (text.length == 0)
    {
        [_chatData removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
    else
    {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = CGSizeMake(10.0, 10.0);
        cell.textLabel.frame = CGRectMake(75, 14, size.width +20, size.height + 20);
        cell.textLabel.font = [UIFont fontWithName:@"Avenir" size:14.0];
        cell.textLabel.text = chatDict[@"text"];
        [cell.textLabel sizeToFit];

        //[self formatDate:cell atIndexPath:indexPath];
    }
}

#pragma mark -- MATCHVIEW DELEGATE
-(void)didPressMatchView
{
    [self performSegueWithIdentifier:@"toUserDetail" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toUserDetail"])
    {
        MessagerProfileVC *mpvc = [segue destinationViewController];
        mpvc.messagingUser = self.recipient;
    }
}

- (IBAction)onBackToMessaging:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
