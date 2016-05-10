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
//
//-(void)sendInitialMessage:(LYRConversation *)conversation withText:(NSString*)text withCompletion:(resultBlockWithSuccess)success
//{
//    NSString *messageText = [NSString stringWithFormat:@"%@", text];
//    NSData *messageData = [messageText dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error = nil;
//    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithMIMEType:@"text/plain" data:messageData];
//    LYRMessage *message = [self.layerClient newMessageWithParts:@[messagePart] options:nil error:&error];
//
//    BOOL successful = [conversation sendMessage:message error:&error];
//
//    if (successful)
//    {
//        NSLog(@"sent message");
//        success(successful, nil);
//    }
//    else
//    {
//        NSLog(@"delivery failed: %@", error);
//        success(successful,nil);
//    }
//}

-(void)sendInitialMessage:(User*)recipient
{
    PFObject *initialMessage = [PFObject objectWithClassName:@"Chat"];
    [initialMessage setObject:recipient forKey:@"toUser"];
    [initialMessage setObject:recipient.givenName forKey:@"repName"];
    [initialMessage setObject:recipient.profileImages.firstObject forKey:@"repImage"];
    [initialMessage setObject:[User currentUser] forKey:@"fromUser"];
    [initialMessage setObject:[User currentUser].givenName forKey:@"fromName"];
    [initialMessage setObject:[User currentUser].profileImages.firstObject forKey:@"fromImage"];
    [initialMessage setObject:@"" forKey:@"text"];
    [initialMessage setObject:[NSDate date] forKey:@"timestamp"];

    [initialMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"error saving message: %@", error);
        }
        else
        {
            NSLog(@"initial message sent: %s", succeeded ? "true" : "false");
        }
    }];
}

-(void)deleteConversation:(LYRConversation*)conversation withResult:(resultBlockWithSuccess)result
{
    
}

-(void)sendMessage:(User*)user toUser:(User*)recipient withText:(NSString*)text
{

    PFObject *newMessage = [PFObject objectWithClassName:@"Chat"];

    //add the from user to the currentUsers friends
    //PFRelation *chatRelation = [user relationForKey:@"chatter"];
    //[chatRelation addObject:recipient];

    [newMessage setObject:recipient forKey:@"toUser"];
    [newMessage setObject:user forKey:@"fromUser"];
    [newMessage setObject:text forKey:@"text"];
    [newMessage setObject:[NSDate date] forKey:@"timestamp"];

    [newMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"error saving message: %@", error);
        }
        else
        {
            NSLog(@"sent message: %s", succeeded ? "true" : "false");
        }
    }];
}

-(void)chatExists:(User*)recipient withSuccess:(resultBlockWithSuccess)success
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"toUser" equalTo:recipient];
    [query whereKey:@"fromUser" equalTo:[User currentUser]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (objects.count > 0)
        {
            NSLog(@"chats: %d", (int)objects.count);
            success(YES, nil);

        }
        else
        {
            NSLog(@"no record of convo object with these two users");
            success(NO, nil);
        }
    }];
}

-(void)queryForChats:(resultBlockWithConversations)conversations
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"fromUser" equalTo:[User currentUser]];
    [query whereKeyExists:@"toUser"];
    [query whereKeyExists:@"repImage"];
    [query orderByDescending:@"updatedAt"];

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

-(void)queryForChat:(User*)recipient andConvo:(resultBlockWithConversations)conversation
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"fromUser" equalTo:[User currentUser]];
    [query whereKey:@"toUser" equalTo:recipient];
    [query whereKeyExists:@"repImage"];
    [query orderByDescending:@"updatedAt"];

    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByAscending:@"createdAt"];
    NSLog(@"Trying to retrieve from cache");

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error)
        {
            conversation(objects, nil);
        }
        else
        {
            NSLog(@"chat error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)queryForChatTextAndTimeOnly:(User*)recipient andConvo:(resultBlockWithConversations)conversation
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"fromUser" equalTo:[User currentUser]];
    [query whereKey:@"toUser" equalTo:recipient];
    [query orderByDescending:@"updatedAt"];

    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByAscending:@"createdAt"];
    NSLog(@"Trying to retrieve from cache");

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error)
        {
            conversation(objects, nil);
        }
        else
        {
            NSLog(@"chat error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)queryForMatches:(resultBlockWithMatches)matches
{
    PFRelation *relation = [[User currentUser] relationForKey:@"match"];
    PFQuery *query = [relation query];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"error: %@", error);
        }
        else
        {
            NSArray *userObjects = [UserBuilder parsedUserData:objects withError:error];
            matches(userObjects, nil);
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

