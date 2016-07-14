//
//  MatchAndChatView.m
//  Pandemos
//
//  Created by Michael Sevy on 7/13/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MatchAndChatView.h"
#import "AllyAdditions.h"
#import <Parse/Parse.h>

@implementation MatchAndChatView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        NSString *nibName = NSStringFromClass([self class]);
        UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        [self addSubview:self.container];
        self.backgroundImageView.backgroundColor = [UIColor blackColor];
        self.alpha = .7;

        UITapGestureRecognizer *tapElsewhere = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressElsewhere:)];

        [self.container addGestureRecognizer:tapElsewhere];

        self.userImageView.layer.masksToBounds = YES;
        self.userImageView.layer.cornerRadius = 60.0;
        self.matchImageView.layer.masksToBounds = YES;
        self.matchImageView.layer.cornerRadius = 60.0;
        self.chatButton.layer.masksToBounds = YES;
        self.chatButton.layer.borderWidth = 1.0;
        self.chatButton.layer.borderColor = [UIColor yellowGreen].CGColor;
        self.chatButton.layer.cornerRadius = 20.0;

        self.userImageView.backgroundColor = [UIColor greenColor];
        self.matchImageView.backgroundColor = [UIColor blueColor];

        [self.chatButton addTarget:self action:@selector(pressChat:) forControlEvents:UIControlEventTouchUpInside];

    }

    return self;
}

-(void)setMatchImages:(NSString *)recipient;
{
    PFFile *pf = [User currentUser].profileImages.firstObject;
    self.userImageView.image = [UIImage imageWithString:pf.url];;
    self.matchImageView.image = [UIImage imageWithString:recipient];
}

-(void)setLabelNames:(NSString*)matched
{
    self.username.text = [User currentUser].givenName;
    self.mathedName.text = matched;
}

-(void)pressElsewhere:(UITapGestureRecognizer*)recognizer
{
    [self.delegate didPressElsewhere];
}

-(void)pressChat:(UIButton*)button
{
    [self.delegate didPressToChat];
}
@end
