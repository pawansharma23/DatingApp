//
//  MessageTableView.m
//  Pandemos
//
//  Created by Michael Sevy on 5/31/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//
#import "MessageTableView.h"
#import "UIColor+Pandemos.h"
#import "MessageTextView.h"
#import "MessageCell.h"

@implementation MessageTableView

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor whiteColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollsToTop = YES;
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
    //[self registerReuseIdentifiers];
}

//- (void)registerReuseIdentifiers
//{
//    [self registerClass:[MessageCell class] forCellWithReuseIdentifier:IncomingCellIdentifier];
//
//    //[self registerClass:[TodayTimeFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:TodayTimeIdentifier];
//
//}

@end
