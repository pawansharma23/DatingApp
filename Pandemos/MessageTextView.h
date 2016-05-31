//
//  MessageTextView.h
//  Pandemos
//
//  Created by Michael Sevy on 1/7/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//


#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const MessageTextViewTextWillChangeNotification;
UIKIT_EXTERN NSString * const MessageContentSizeDidChangeNotification;
UIKIT_EXTERN NSString * const MessageSelectedRangeDidChangeNotification;
UIKIT_EXTERN NSString * const MessageDidPasteItemNotification;
UIKIT_EXTERN NSString * const MessageDidShakeNotification;

UIKIT_EXTERN NSString * const MessagePastedItemContentType;
UIKIT_EXTERN NSString * const MessagePastedItemMediaType;
UIKIT_EXTERN NSString * const MessagePastedItemData;

typedef NS_OPTIONS(NSUInteger, PastableMediaType) {
    PastableMediaTypeNone        = 0,
    PastableMediaTypePNG         = 1 << 0,
    PastableMediaTypeJPEG        = 1 << 1,
    PastableMediaTypeTIFF        = 1 << 2,
    PastableMediaTypeGIF         = 1 << 3,
    PastableMediaTypeMOV         = 1 << 4,
    PastableMediaTypePassbook    = 1 << 5,
    PastableMediaTypeImages      = PastableMediaTypePNG|PastableMediaTypeJPEG|PastableMediaTypeTIFF|PastableMediaTypeGIF,
    PastableMediaTypeVideos      = PastableMediaTypeMOV,
    PastableMediaTypeAll         = PastableMediaTypeImages|PastableMediaTypeMOV
};

@protocol MessageTextViewDelegate;

/** @name A custom text input view. */
@interface MessageTextView : UITextView

@property (nonatomic, weak) id<MessageTextViewDelegate,UITextViewDelegate>delegate;

/** The placeholder text string. Default is nil. */
@property (nonatomic, copy) NSString *placeholder;

/** The placeholder color. Default is lightGrayColor. */
@property (nonatomic, copy) UIColor *placeholderColor;

/** The maximum number of lines before enabling scrolling. Default is 0 wich means limitless.
 If dynamic type is enabled, the maximum number of lines will be calculated proportionally to the user preferred font size. */
@property (nonatomic, readwrite) NSUInteger maxNumberOfLines;

/** The current displayed number of lines. */
@property (nonatomic, readonly) NSUInteger numberOfLines;

/** The supported media types allowed to be pasted in the text view, such as images or videos. Default is None. */
@property (nonatomic) PastableMediaType pastableMediaTypes;

/** YES if the text view is and can still expand it self, depending if the maximum number of lines are reached. */
@property (nonatomic, readonly) BOOL isExpanding;

/** YES if quickly refreshed the textview without the intension to dismiss the keyboard. @view -disableQuicktypeBar: for more details. */
@property (nonatomic, readwrite) BOOL didNotResignFirstResponder;

/** YES if the magnifying glass is visible.
 This feature is deprecated since there are no legit alternatives to detect the magnifying glass.
 Open Radar: http://openradar.appspot.com/radar?id=5021485877952512
 */
@property (nonatomic, getter=isLoupeVisible) BOOL loupeVisible DEPRECATED_ATTRIBUTE;

/** YES if the keyboard track pad has been recognized. iOS 9 only. */
@property (nonatomic, readonly, getter=isTrackpadEnabled) BOOL trackpadEnabled;

/** YES if autocorrection and spell checking are enabled. On iOS8, this property also controls the predictive QuickType bar from being visible. Default is YES. */
@property (nonatomic, getter=isTypingSuggestionEnabled) BOOL typingSuggestionEnabled;

/** YES if the text view supports undoing, either using UIMenuController, or with ctrl+z when using an external keyboard. Default is YES. */
@property (nonatomic, readwrite) BOOL undoManagerEnabled;

/** YES if the font size should dynamically adapt based on the font sizing option preferred by the user. Default is YES. */
@property (nonatomic, getter=isDynamicTypeEnabled) BOOL dynamicTypeEnabled;

/**
 Some text view properties don't update when it's already firstResponder (auto-correction, spelling-check, etc.)
 To be able to update the text view while still being first responder, requieres to switch quickly from -resignFirstResponder to -becomeFirstResponder.
 When doing so, the flag 'didNotResignFirstResponder' is momentarly set to YES before it goes back to -isFirstResponder, to be able to prevent some tasks to be excuted because of UIKeyboard notifications.

 You can also use this method to confirm an auto-correction programatically, before the text view resigns first responder.
 */
- (void)refreshFirstResponder;
- (void)refreshInputViews;

/**
 Notifies the text view that the user pressed any arrow key. This is used to move the cursor up and down while having multiple lines.
 */
- (void)didPressAnyArrowKey:(id)sender;


#pragma mark - Markdown Formatting

/** YES if the a markdown closure symbol should be added automatically after double spacebar tap, just like the native gesture to add a sentence period. Default is YES.
 This will always be NO if there isn't any registered formatting symbols.
 */
@property (nonatomic, readonly, getter=isFormattingEnabled) BOOL formattingEnabled;

/** An array of the registered formatting symbols. */
@property (nonatomic, readonly) NSArray *registeredSymbols;

/**
 Registers any string markdown symbol for formatting tooltip, presented after selecting some text.
 The symbol must be valid string (i.e: '*', '~', '_', and so on). This also checks if no repeated symbols are inserted, and respects the ordering for the tooltip.

 @param symbol A markdown symbol to be prefixed and sufixed to a text selection.
 @param title The tooltip item title for this formatting.
 */
- (void)registerMarkdownFormattingSymbol:(NSString *)symbol withTitle:(NSString *)title;

@end


@protocol MessageTextViewDelegate <UITextViewDelegate>
@optional

/**
 Asks the delegate whether the specified formatting symbol should be displayed in the tooltip.
 This is useful to remove some tooltip options when they no longer apply in some context.
 For example, Blockquotes formatting requires the symbol to be prefixed at the begining of a paragraph.

 @param textView The text view containing the changes.
 @param symbol The formatting symbol to be verified.
 @return YES if the formatting symbol should be displayed in the tooltip. Default is YES.
 */
- (BOOL)textView:(MessageTextView *)textView shouldOfferFormattingForSymbol:(NSString *)symbol;

/**
 Asks the delegate whether the specified formatting symbol should be suffixed, to close the formatting wrap.
 @para  The prefix range
 */
- (BOOL)textView:(MessageTextView *)textView shouldInsertSuffixForFormattingWithSymbol:(NSString *)symbol prefixRange:(NSRange)prefixRange;


@end
