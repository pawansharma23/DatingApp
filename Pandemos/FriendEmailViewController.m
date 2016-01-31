//
//  FriendEmailViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/21/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "FriendEmailViewController.h"
#import <Parse/Parse.h>

@interface FriendEmailViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation FriendEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.emailTextField.delegate = self;
    self.currentUser = [PFUser currentUser];

}


- (IBAction)onEmailTextField:(UITextField *)sender {

    //on Editing did end
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {

   NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([email length] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Make sure you enter a Username, Password, and Email Address" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];

    } else if (textField == self.emailTextField) {
        [textField resignFirstResponder];

        [self.currentUser setObject:self.emailTextField.text forKey:@"confidantEmail"];
        [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error) {

            NSLog(@"saved: %@ %s", self.emailTextField.text, succeeded ? "true" : "false");
            }else{
                NSLog(@"error: %@", error);
            }
        }];

        return NO;
    }
    NSLog(@"in YES: %@", textField);
    return YES;
}

@end
