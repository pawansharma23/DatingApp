//
//  MessageTextView+Pandemos.h
//  Pandemos
//
//  Created by Michael Sevy on 5/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//
#import "MessageTextView.h"

@interface MessageTextView (Additions)
/**
 Clears the text.

 @param clearUndo YES if clearing the text should also clear the undo manager (if enabled).
 */
- (void)clearText:(BOOL)clearUndo;

/**
 Scrolls to the very end of the content size, animated.

 @param animated YES if the scrolling should be animated.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 Scrolls to the caret position, animated.

 @param animated YES if the scrolling should be animated.
 */
- (void)scrollToCaretPositonAnimated:(BOOL)animated;

/**
 Inserts a line break at the caret's position.
 */
- (void)insertNewLineBreak;

/**
 Inserts a string at the caret's position.

 @param text The string to be appended to the current text.
 */
- (void)insertTextAtCaretRange:(NSString *)text;

/**
 Adds a string to a specific range.

 @param text The string to be appended to the current text.
 @param range The range where to insert text.

 @return The range of the newly inserted text.
 */
- (NSRange)insertText:(NSString *)text inRange:(NSRange)range;

/**
 Finds the word close to the caret's position, if any.

 @param range Returns the range of the found word.
 @returns The found word.
 */
- (NSString *)wordAtCaretRange:(NSRangePointer)range;
/**
 Finds the word close to specific range.

 @param range The range to be used for searching the word.
 @param rangePointer Returns the range of the found word.
 @returns The found word.
 */
- (NSString *)wordAtRange:(NSRange)range rangeInText:(NSRangePointer)rangePointer;
/**
 Registers the current text for future undo actions.

 @param description A simple description associated with the Undo or Redo command.
 */
- (void)prepareForUndo:(NSString *)description;
/**
 Returns a constant font size difference reflecting the current accessibility settings.

 @param category A content size category constant string.
 @returns A float constant font size difference.
 */
+ (CGFloat)pointSizeDifferenceForCategory:(NSString *)category;

@end
