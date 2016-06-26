//
//  MNCChatMessageCell.m
//  Pandemos
//
//  Created by Michael Sevy on 6/19/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MNCChatMessageCell.h"

@implementation MNCChatMessageCell

//-(instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        self.backgroundColor = [UIColor whiteColor];
//        self.contentView.backgroundColor = [UIColor whiteColor];
//        [self configureSubviewsForIncoming];
//    }
//    return self;
//}

//-(void)configureSubviewsForIncoming
//{
//    [self.contentView addSubview:self.textView];
//
//    CGFloat margin = 0;
//
//    NSDictionary *views = @{@"bodyLabel": self.textView};
//
//    NSDictionary *metrics = @{@"padding": @15,
//                              @"right": @12,
//                              @"left": @2,
//                              @"margin": [NSNumber numberWithFloat:margin],
//                              };
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bodyLabel(>=0@999)]-(>=62)-|" options:0 metrics:metrics views:views]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-left-[bodyLabel(>=0@200)]-left-|" options:0 metrics:metrics views:views]];
//}
//
//+ (CGFloat)defaultFontSize
//{
//    CGFloat pointSize = 18.0;
//
//    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
//    pointSize += [UILabel pointSizeDifferenceForCategory:contentSizeCategory];
//
//    return pointSize;
//}
//
//+(CGSize)sizeForMessage:(LYRMessage *)message withWidth:(CGFloat)width
//{
//    NSAttributedString *text = [self formatedTextFromMessage:message];
//
//    if (!text.string.length)
//    {
//        return CGSizeZero;
//    }
//
//    //Same as above
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width -62, CGFLOAT_MAX)];
//    textView.textContainerInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0);
//    [textView setAttributedText:text];
//    int rows = (textView.contentSize.height - textView.textContainerInset.top - textView.textContainerInset.bottom) / textView.font.lineHeight;
//
//    if (rows > 7)
//    {
//        rows = 7;
//    }
//    CGFloat height = MinimumHeight + (rows - 1) * 25;
//
//
//
//    //    NSLog(@"MESSAGE %@ ROWS %d HEIGHT %f",text.string,rows,height);
//
//    return CGSizeMake(width, height);
//}
//
//+ (CGFloat)defaultFontSize
//{
//    CGFloat pointSize = 18.0;
//
//    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
//    pointSize += [TextView pointSizeDifferenceForCategory:contentSizeCategory];
//
//    return pointSize;
//}
//
//+(NSAttributedString*)formatedTextFromMessage:(LYRMessage*)message
//{
//    LYRMessagePart *messagePart = message.parts[0];
//
//    NSMutableString *text = [[NSMutableString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
//
//    if ([text containsString:@"PUSH:"] && text.length >= 6)
//    {
//        [text replaceCharactersInRange:NSMakeRange(0, 6) withString:@""];
//    }
//
//    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] initWithString:text attributes:[self attributesForText:text]];
//    return newText;
//}
//
//+(NSDictionary*)attributesForText:(NSString*)text
//{
//    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    paragraphStyle.alignment = NSTextAlignmentLeft;
//
//    UIFont *bodyFont = [UIFont fontAvenirBookWithSize:[IncomingCell defaultFontSize]];
//
//    NSDictionary *attributes = @{NSFontAttributeName: bodyFont,
//                                 NSParagraphStyleAttributeName: paragraphStyle,
//                                 NSForegroundColorAttributeName: [UIColor benjiBrown]};
//    return attributes;
//}
@end
