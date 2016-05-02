//
//  MessageManager.h
//  Pandemos
//
//  Created by Michael Sevy on 4/28/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <LayerKit/LayerKit.h>

typedef void (^resultBlockWithMessage) (LYRMessage *message, NSError *error);
typedef void (^resultBlockWithSuccess)(BOOL success, NSError *error);
typedef void (^resultBlockWithResult)(NSArray *result, NSError *error);
typedef void (^resultBlockWithConversations)(NSArray *result, NSError *error);

@interface MessageManager : NSObject

@property(nonatomic, strong)NSArray *matches;
@property(nonatomic, strong)LYRClient *layerClient;

-(void)launchApp;
-(void)sendMessage:(User*)user toUser:(User*)recipient withText:(NSString*)text;
-(void)deleteConversation:(LYRConversation*)conversation withResult:(resultBlockWithSuccess)result;
-(void)queryForChats:(User*)currentUser withResult:(resultBlockWithConversations)conversations;
-(void)queryForMatches:(User*)currentUser withResult:(resultBlockWithResult)result;
@end
