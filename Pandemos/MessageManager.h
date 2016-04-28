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

typedef void (^resultBlockWithConversation)(LYRConversation *conversation, NSError *error);
typedef void (^resultBlockWithMessage) (LYRMessage *message, NSError *error);
typedef void (^resultBlockWithSuccess)(BOOL success, NSError *error);

@interface MessageManager : NSObject

@property(nonatomic, strong)LYRClient *layerClient;

-(void)launchApp;
-(void)createConversationWithUsers:(NSArray*)users withCompletion:(resultBlockWithConversation)result;
-(void)deleteConversation:(LYRConversation*)conversation withResult:(resultBlockWithSuccess)result;
@end
