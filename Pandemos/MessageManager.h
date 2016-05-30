//
//  MessageManager.h
//  Pandemos
//
//  Created by Michael Sevy on 4/28/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef void (^resultBlockWithSuccess)(BOOL success, NSError *error);
typedef void (^resultBlockWithResult)(NSArray *result, NSError *error);
typedef void (^resultBlockWithConversations)(NSArray *result, NSError *error);
typedef void (^resultBlockWithMatches)(NSArray *result, NSError *error);

@interface MessageManager : NSObject

@property(nonatomic, strong)NSArray *matches;

-(void)sendInitialMessage:(User*)recipient;
-(void)sendMessage:(User*)user toUser:(User*)recipient withText:(NSString*)text;
-(void)queryIfChatExists:(User*)recipient currentUser:(User*)user withSuccess:(resultBlockWithSuccess)success;
-(void)queryForChats:(resultBlockWithConversations)conversations;
-(void)queryForMatches:(resultBlockWithMatches)matches;
-(void)queryForChattersImage:(resultBlockWithConversations)conversation;
-(void)queryForChatTextAndTime:(User*)recipient andConvo:(resultBlockWithConversations)conversation;
@end