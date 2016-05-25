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

-(void)queryIfChatExists:(User*)recipient currentUser:(User*)user withSuccess:(resultBlockWithSuccess)success
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"toUser" equalTo:recipient];
    [query whereKey:@"fromUser" equalTo:user];

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
    [query whereKeyExists:@"text"];
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

-(void)queryForChattersImage:(resultBlockWithConversations)conversation
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

    [query whereKey:@"objectId" notEqualTo:[User currentUser].objectId];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (error)
        {
            NSLog(@"error: %@", error);
        }
        else
        {
            //NSArray *userObjects = [UserBuilder parsedUserData:objects withError:error];
            matches(objects, nil);
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

