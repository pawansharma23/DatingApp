//
//  MessageCell.h
//  Pandemos
//
//  Created by Michael Sevy on 5/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UILabel *incomingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *outgoingTimeLabel;

-(void)setCellForMessage:(NSString *)message;
+(CGSize)sizeForMessage:(NSString *)message withWidth:(CGFloat)width;
@end
