//
//  MessageManager.m
//  Pandemos
//
//  Created by Michael Sevy on 4/28/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessageManager.h"
#import "User.h"
#import <Parse/Parse.h>
#import "UserBuilder.h"

@implementation MessageManager

-(void)launchApp
{
    if ([User currentUser])
    {
        if (!self.layerClient.isConnected)
        {
            [self.layerClient connectWithCompletion:^(BOOL success, NSError *error)
             {
                 if (!success)
                 {
                     NSLog(@"failed to launch with Layer Code");
                     //[self launchCompleted:LAUNCH_STATUS_LOGIN_FAILURE withError:error];
                 }
                 else
                 {
                     NSLog(@"sent to layer authenticate");
                     [self authenticateUserForLayer];
                 }
             }];
        }
    }
    else
    {
        NSLog(@"send to PFacebook login page");
    }
}

- (void)authenticateUserForLayer
{
    if (self.layerClient.authenticatedUser)
    {
        NSLog(@"SIGNED IN WITH LAYER");
        //[self launchCompleted:LAUNCH_STATUS_LOGIN_SUCCESS withError:nil];
    }
    else
    {
        [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error)
         {
             // Upon reciept of nonce, post to your backend and acquire a Layer identityToken
             if (nonce)
             {
                 User *user = [User currentUser];
                 NSString *userID  = user.objectId;
                 [PFCloud callFunctionInBackground:@"generateToken"
                                    withParameters:@{@"nonce" : nonce,
                                                     @"userID" : userID}
                                             block:^(NSString *token, NSError *error)
                  {
                      if (!error)
                      {
                          // Send the Identity Token to Layer to authenticate the user
                          [self.layerClient authenticateWithIdentityToken:token completion:^(LYRIdentity * _Nullable authenticatedUser, NSError * _Nullable error) {

                              if (!error)
                              {
                                  NSLog(@"Parse User authenticated with Layer Identity Token auth user: %@", authenticatedUser);
                                  //[self launchCompleted:LAUNCH_STATUS_LOGIN_SUCCESS withError:nil];
                              }
                              else
                              {
                                  NSLog(@"Parse User authenticated failed");

                              }
                          }];
                      }
                  }];
             }
         }];
    }
}

-(void)sendInitialMessage:(LYRConversation *)conversation withText:(NSString*)text withCompletion:(resultBlockWithSuccess)success
{
    NSString *messageText = [NSString stringWithFormat:@"%@", text];
    NSData *messageData = [messageText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithMIMEType:@"text/plain" data:messageData];
    LYRMessage *message = [self.layerClient newMessageWithParts:@[messagePart] options:nil error:&error];

    BOOL successful = [conversation sendMessage:message error:&error];

    if (successful)
    {
        NSLog(@"sent message");
        success(successful, nil);
    }
    else
    {
        NSLog(@"delivery failed: %@", error);
        success(successful,nil);
    }
}

-(void)deleteConversation:(LYRConversation*)conversation withResult:(resultBlockWithSuccess)result
{
    
}

-(void)sendMessage:(User*)user toUser:(User*)recipient withText:(NSString*)text
{
    PFObject *newMessage = [PFObject objectWithClassName:@"Chat"];
    [newMessage setObject:recipient forKey:@"recipientId"];
    //[newMessage setObject:recipient.givenName forKey:@"repName"];
    //[newMessage setObject:recipient.profileImages.firstObject forKey:@"repImage"];
    [newMessage setObject:user forKey:@"fromUser"];
    //[newMessage setObject:user.givenName forKey:@"senderName"];
    //[newMessage setObject:user.profileImages.firstObject forKey:@"senderImage"];
    [newMessage setObject:text forKey:@"text"];
    [newMessage setObject:[NSDate date] forKey:@"timestamp"];
    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"error saving message: %@", error);
        }
        else
        {
            NSLog(@"saved message: %s", succeeded ? "true" : "false");
        }
    }];
}

-(void)queryForChats:(User*)currentUser withResult:(resultBlockWithConversations)conversations
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    
//    [query whereKey:@"recipientId" equalTo:currentUser];
    //for testing
    [query whereKey:@"fromUser" equalTo:currentUser];

        NSLog(@"no chat data");
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByAscending:@"createdAt"];
        NSLog(@"Trying to retrieve from cache");

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (!error)
            {
                conversations(objects, nil);
            }
            else
            {
                NSLog(@"Error Above: %@ %@", error, [error userInfo]);
            }
        }];
}

-(void)queryForMatches:(User*)currentUser withResult:(resultBlockWithResult)result
{
    PFRelation *relation = [currentUser objectForKey:@"match"];
    PFQuery *query = [relation query];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"error: %@", error);
        }
        else
        {
            self.matches = objects;
            NSArray *userObjects = [UserBuilder parsedUserData:objects withError:error];
            result(userObjects, nil);
        }
    }];
}
@end



//-(void)createConversationWithUsers:(NSArray*)users withCompletion:(resultBlockWithConversation)result
//{
//    NSError *error = nil;
//
//    if (users.count == 1)
//    {
//        User *userObjectId = users.lastObject;
//        BOOL deliveryReceiptsEnabled = false;
//        BOOL uniqueConvoBetweenParticipants = YES;
//        NSDictionary *dict = @{LYRConversationOptionsDeliveryReceiptsEnabledKey: @(deliveryReceiptsEnabled),
//                               LYRConversationOptionsDeliveryReceiptsEnabledKey: @(uniqueConvoBetweenParticipants)};
////        LYRConversation *newConvo = [self.layerClient newConversationWithParticipants:[NSSet setWithObjects:userObjectId, nil] options:dict error:&error];
//
//        if (!error)
//        {
//            //failing here not being sent a valid newConvo object
//            [self sendInitialMessage:newConvo withText:@"Hello" withCompletion:^(BOOL success, NSError *error) {
//
//                if (success)
//                {
//                    NSLog(@"layer sent message");
//                }
//                else
//                {
//                    NSLog(@"no message sent %@", error);
//                }
//            }];
//
//            result(newConvo,nil);
//        }
//        else
//        {
//            result(nil, error);
//            NSLog(@"error: %@", error);
//        }
//    }
//    else if (users.count > 1)
//    {
//        NSMutableSet *set = [NSMutableSet new];
//        for (User *user in users)
//        {
//            [set addObject:user.objectId];
//        }
//        BOOL deliveryReceiptsEnabled = NO;
//        LYRConversation *newConvo = [self.layerClient newConversationWithParticipants:set options:@{LYRConversationOptionsDeliveryReceiptsEnabledKey: @(deliveryReceiptsEnabled) } error:&error];
//
//        if (!error)
//        {
//            result(newConvo,nil);
//        }
//        else
//        {
//            result(nil, error);
//        }
//    }
//}

