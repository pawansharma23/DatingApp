//
//  MessageTextView+Pandemos.m
//  Pandemos
//
//  Created by Michael Sevy on 5/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessageTextView+Pandemos.h"

@implementation MessageTextView (Additions)

- (void)clearText:(BOOL)clearUndo
{
    // Important to call self implementation, as TextView overrides setText: to add additional features.
    [self setText:nil];

    if (self.undoManagerEnabled && clearUndo) {
        [self.undoManager removeAllActions];
    }
}

- (void)scrollToCaretPositonAnimated:(BOOL)animated
{
    if (animated) {
        [self scrollRangeToVisible:self.selectedRange];
    }
    else {
        [UIView performWithoutAnimation:^{
            [self scrollRangeToVisible:self.selectedRange];
        }];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    CGRect rect = [self caretRectForPosition:self.selectedTextRange.end];
    rect.size.height += self.textContainerInset.bottom;

    if (animated) {
        [self scrollRectToVisible:rect animated:animated];
    }
    else {
        [UIView performWithoutAnimation:^{
            [self scrollRectToVisible:rect animated:NO];
        }];
    }
}

- (void)insertNewLineBreak
{
    [self insertTextAtCaretRange:@"\n"];

    // if the text view cannot expand anymore, scrolling to bottom are not animated to fix a UITextView issue scrolling twice.
    BOOL animated = !self.isExpanding;

    //Detected break. Should scroll to bottom if needed.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0125 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottomAnimated:animated];
    });
}

- (void)insertTextAtCaretRange:(NSString *)text
{
    NSRange range = [self insertText:text inRange:self.selectedRange];
    self.selectedRange = NSMakeRange(range.location, 0);
}

- (NSRange)insertText:(NSString *)text inRange:(NSRange)range
{
    // Skip if the text is empty
    if (text.length == 0) {
        return NSMakeRange(0, 0);
    }

    // Registers for undo management
    [self prepareForUndo:@"Text appending"];

    // Append the new string at the caret position
    if (range.length == 0)
    {
        NSString *leftString = [self.text substringToIndex:range.location];
        NSString *rightString = [self.text substringFromIndex: range.location];

        self.text = [NSString stringWithFormat:@"%@%@%@", leftString, text, rightString];

        range.location += text.length;

        return range;
    }
    // Some text is selected, so we replace it with the new text
    else if (range.location != NSNotFound && range.length > 0)
    {
        self.text = [self.text stringByReplacingCharactersInRange:range withString:text];

        range.location += text.length;

        return range;
    }

    // No text has been inserted, but still return the caret range
    return self.selectedRange;
}

- (NSString *)wordAtCaretRange:(NSRangePointer)range
{
    return [self wordAtRange:self.selectedRange rangeInText:range];
}

- (NSString *)wordAtRange:(NSRange)range rangeInText:(NSRangePointer)rangePointer
{
    NSString *text = self.text;
    NSInteger location = range.location;

    // Aborts in case minimum requieres are not fufilled
    if (text.length == 0 || location < 0 || (range.location+range.length) > text.length) {
        *rangePointer = NSMakeRange(0, 0);
        return nil;
    }

    NSString *leftPortion = [text substringToIndex:location];
    NSArray *leftComponents = [leftPortion componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *leftWordPart = [leftComponents lastObject];

    NSString *rightPortion = [text substringFromIndex:location];
    NSArray *rightComponents = [rightPortion componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rightPart = [rightComponents firstObject];

    if (location > 0) {
        NSString *characterBeforeCursor = [text substringWithRange:NSMakeRange(location-1, 1)];

        if ([characterBeforeCursor isEqualToString:@" "]) {
            // At the start of a word, just use the word behind the cursor for the current word
            *rangePointer = NSMakeRange(location, rightPart.length);

            return rightPart;
        }
    }

    // In the middle of a word, so combine the part of the word before the cursor, and after the cursor to get the current word
    *rangePointer = NSMakeRange(location-leftWordPart.length, leftWordPart.length+rightPart.length);
    NSString *word = [leftWordPart stringByAppendingString:rightPart];

    // If a break is detected, return the last component of the string
    if ([word rangeOfString:@"\n"].location != NSNotFound) {
        *rangePointer = [text rangeOfString:word];
        word = [[word componentsSeparatedByString:@"\n"] lastObject];
    }

    return word;
}

- (void)prepareForUndo:(NSString *)description
{
    if (!self.undoManagerEnabled) {
        return;
    }

    MessageTextView *prepareInvocation = [self.undoManager prepareWithInvocationTarget:self];
    [prepareInvocation setText:self.text];
    [self.undoManager setActionName:description];
}

+ (CGFloat)pointSizeDifferenceForCategory:(NSString *)category
{
    if ([category isEqualToString:UIContentSizeCategoryExtraSmall])                         return -3.0;
    if ([category isEqualToString:UIContentSizeCategorySmall])                              return -2.0;
    if ([category isEqualToString:UIContentSizeCategoryMedium])                             return -1.0;
    if ([category isEqualToString:UIContentSizeCategoryLarge])                              return 0.0;
    if ([category isEqualToString:UIContentSizeCategoryExtraLarge])                         return 2.0;
    if ([category isEqualToString:UIContentSizeCategoryExtraExtraLarge])                    return 4.0;
    if ([category isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge])               return 6.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityMedium])                return 8.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityLarge])                 return 10.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityExtraLarge])            return 11.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraLarge])       return 12.0;
    if ([category isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge])  return 13.0;
    return 0;
}

@end
