//
//  MessageCell.m
//  Pandemos
//
//  Created by Michael Sevy on 5/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessageCell.h"
#import "MessageTextView+Pandemos.h"
#import "MessageTextView.h"

static CGFloat MinimumHeight = 45.0;

@implementation MessageCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];

        [self configureSubviewsForIncoming];
    }
    return self;
}

-(void)configureSubviewsForIncoming
{
    [self.contentView addSubview:self.textView];

    CGFloat margin = 0;

    NSDictionary *views = @{@"bodyLabel": self.textView};

    NSDictionary *metrics = @{@"padding": @15,
                              @"right": @12,
                              @"left": @2,
                              @"margin": [NSNumber numberWithFloat:margin],
                              };
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bodyLabel(>=0@999)]-(>=62)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-left-[bodyLabel(>=0@200)]-left-|" options:0 metrics:metrics views:views]];

}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont fontWithName:@"GeezaPro" size:14.0];
    self.textView.text = @"";
    self.textView.backgroundColor = [UIColor redColor];
}

-(void)setCellForMessage:(NSString *)message
{
    self.textView.text = message;

//    if (message.isUnread)
//    {
//        NSError *error;
//        BOOL success = [message markAsRead:&error];
//        if (success)
//        {
//            // NSLog(@"Incoming Message marked as read %@", self.textView.text);
//        }
//        else
//        {
//            //NSLog(@"FAILED to mark as read %@", self.textView.text);
//        }
//    }

    
    //called when you re draw a UI feature ie. CGRect
    //[self setNeedsDisplay];
}


+ (CGFloat)defaultFontSize
{
    CGFloat pointSize = 16.0;

    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
    pointSize += [MessageTextView pointSizeDifferenceForCategory:contentSizeCategory];

    return pointSize;
}

+(CGSize)sizeForMessage:(NSString *)message withWidth:(CGFloat)width
{

    if (!message.length)
    {
        return CGSizeZero;
    }

    //Same as above
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width -62, CGFLOAT_MAX)];
    textView.textContainerInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
//    [textView setAttributedText:text];
    int rows = (textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / textView.font.lineHeight;

    CGFloat height = MinimumHeight + (rows - 1) * 25;

    //    NSLog(@"MESSAGE %@ ROWS %d HEIGHT %f",text.string,rows,height);

    return CGSizeMake(width, height);
}

+(NSDictionary*)attributesForText:(NSString*)text
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;

    UIFont *bodyFont = [UIFont fontWithName:@"GeezaPro" size:16.0];

    NSDictionary *attributes = @{NSFontAttributeName: bodyFont,
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 NSForegroundColorAttributeName: [UIColor redColor]};
    return attributes;
}

-(UITextView *)textView
{
    if (!_textView)
    {
        _textView = [UITextView new];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.userInteractionEnabled = YES;
        _textView.textColor = [UIColor blackColor];
        _textView.font = [UIFont fontWithName:@"GeezaPro" size:16.0];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.dataDetectorTypes = UIDataDetectorTypeAll;
        _textView.linkTextAttributes = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]};
        _textView.scrollEnabled = NO;
        _textView.selectable = YES;
        _textView.editable = NO;
        _textView.layer.cornerRadius = 10;
        _textView.layer.masksToBounds = YES;
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.textContainerInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
    }
    return _textView;
}
@end
