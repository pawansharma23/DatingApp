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
#import "IncomingCell.h"
#import "OutgoingCell.h"

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
@property (strong, nonatomic) NSMutableArray *incomingChatData;
@property (strong, nonatomic) NSMutableArray *outgoingChatData;
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
    self.incomingChatData = [NSMutableArray new];
    self.outgoingChatData = [NSMutableArray new];

    [self loadChatWithImage];
    [self loadRecipientUserData];
    [self loadIncomingMessages];
    [self loadOutgoingMessages];
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
        [self.outgoingChatData addObject:dictionary];

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
    [self loadOutgoingMessages];
    [self loadIncomingMessages];
    return NO;
}

#pragma mark -- TABLEVIEW DELEGATE
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.outgoingChatData.count;
}

-(IncomingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSUInteger inRow = [_incomingChatData count]-[indexPath row]-1;
    NSUInteger outRow = [_outgoingChatData count]-[indexPath row]-1;
    

    IncomingCell *inCell = (IncomingCell *)[tableView dequeueReusableCellWithIdentifier: @"Incoming"];

    if (self.incomingChatData.count > 0)
    {
        NSDictionary *inChatText = [self.incomingChatData objectAtIndex:indexPath.row];

        if (inRow < _incomingChatData.count)
        {
            inCell.textLabel.text = inChatText[@"text"];
            inCell.messageLabel.textAlignment = NSTextAlignmentLeft;
            inCell.timeLabel.textAlignment = NSTextAlignmentLeft;
            inCell.timeLabel.text = [NSString timeFromData:inChatText[@"timestamp"]];
        }
    }

    if (self.outgoingChatData.count > 0)
    {
        NSDictionary *outChatText = [self.outgoingChatData objectAtIndex:indexPath.row];
        NSString *text = outChatText[@"text"];

        if (outRow < _outgoingChatData.count)
        {

            inCell.timeLabel.textAlignment = NSTextAlignmentRight;
            inCell.messageLabel.textAlignment = NSTextAlignmentRight;
 //           inCell.messageLabel.layer.cornerRadius = 8;
//                inCell.messageLabel.backgroundColor = [UIColor unitedNationBlue];
            inCell.messageLabel.text = text;
            inCell.timeLabel.text = [NSString timeFromData:outChatText[@"timestamp"]];


        }
}

    return inCell;
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
-(void)loadIncomingMessages
{
    [self.messageManager queryForIncomingMessages:self.recipient withBlock:^(NSArray *result, NSError *error) {

        self.incomingChatData = [NSMutableArray arrayWithArray:result];
        [self.tableView reloadData];
    }];
}

-(void)loadOutgoingMessages
{
    [self.messageManager queryForOutgoingMessages:self.recipient withBlock:^(NSArray *result, NSError *error) {

        self.outgoingChatData = [NSMutableArray arrayWithArray:result];
        [self.tableView reloadData];
    }];
}

-(void)loadChatWithImage
{
    [self.messageManager queryForChattersImage:^(NSArray *result, NSError *error) {

        self.lastObject = result.lastObject;
        self.navigationItem.title = self.lastObject[@"repName"];
    }];
}

-(void)loadRecipientUserData
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
