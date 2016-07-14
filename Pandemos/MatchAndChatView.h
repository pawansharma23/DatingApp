//
//  MatchAndChatView.h
//  Pandemos
//
//  Created by Michael Sevy on 7/13/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol MatchAndChatDelegate <NSObject>

-(void)didPressToChat;
-(void)didPressElsewhere;
@end

@interface MatchAndChatView : UIView

@property (nonatomic, weak) id<MatchAndChatDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *matchImageView;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *mathedName;

-(void)setMatchImages:(NSString *)recipient;
-(void)setLabelNames:(NSString*)matched;
@end
