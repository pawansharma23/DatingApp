//
//  MessageTextView.m
//  Pandemos
//
//  Created by Michael Sevy on 5/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "MessageTextView.h"
#import "MessageTextView+Pandemos.h"
#import "AppConstants.h"

NSString * const MessageTextViewTextWillChangeNotification =            @"MessageTextViewTextWillChangeNotification";
NSString * const MessageTextViewContentSizeDidChangeNotification =      @"MessageTextViewContentSizeDidChangeNotification";
NSString * const MessageTextViewSelectedRangeDidChangeNotification =    @"MessageTextViewSelectedRangeDidChangeNotification";
NSString * const MessageTextViewDidPasteItemNotification =              @"MessageTextViewDidPasteItemNotification";
NSString * const MessageTextViewDidShakeNotification =                  @"MessageTextViewDidShakeNotification";
NSString * const MessageTextViewPastedItemContentType =                 @"MessageTextViewPastedItemContentType";
NSString * const MessageTextViewPastedItemMediaType =                   @"MessageTextViewPastedItemMediaType";
NSString * const MessageTextViewPastedItemData =                        @"MessageTextViewPastedItemData";

static NSString *const TextViewGenericFormattingSelectorPrefix = @"_format_";

@interface MessageTextView ()

// The label used as placeholder
@property (nonatomic, strong) UILabel *placeholderLabel;

// The initial font point size, used for dynamic type calculations
@property (nonatomic) CGFloat initialFontSize;

// The keyboard commands available for external keyboards
@property (nonatomic, strong) NSArray *keyboardCommands;

// Used for moving the caret up/down
@property (nonatomic) UITextLayoutDirection verticalMoveDirection;
@property (nonatomic) CGRect verticalMoveStartCaretRect;
@property (nonatomic) CGRect verticalMoveLastCaretRect;

// Used for detecting if the scroll indicator was previously flashed
@property (nonatomic) BOOL didFlashScrollIndicators;

@property (nonatomic, strong) NSMutableArray *registeredFormattingTitles;
@property (nonatomic, strong) NSMutableArray *registeredFormattingSymbols;
@property (nonatomic, getter=isFormatting) BOOL formatting;

@end

@implementation MessageTextView
@dynamic delegate;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    if (self = [super initWithFrame:frame textContainer:textContainer])
    {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        [self commonInit];
    }

    return self;
}

- (void)commonInit
{
    _pastableMediaTypes = PastableMediaTypeNone;
    _dynamicTypeEnabled = YES;
    self.undoManagerEnabled = YES;

    self.editable = YES;
    self.selectable = YES;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.directionalLockEnabled = YES;
    self.dataDetectorTypes = UIDataDetectorTypeNone;

   // [self registerNotifications];

    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:NULL];
}


#pragma mark - UIView Overrides

- (CGSize)intrinsicContentSize
{
    CGFloat height = self.font.lineHeight;
    height += self.textContainerInset.top + self.textContainerInset.bottom;

    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (void)layoutIfNeeded
{
    if (!self.window)
    {
        return;
    }

    [super layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.placeholderLabel.hidden = [self shouldHidePlaceholder];

    if (!self.placeholderLabel.hidden)
    {
        [UIView performWithoutAnimation:
         ^{
             self.placeholderLabel.frame = [self placeholderRectThatFits:self.bounds];
             [self sendSubviewToBack:self.placeholderLabel];
         }];
    }
}


#pragma mark - Getters

- (UILabel *)placeholderLabel
{
    if (!_placeholderLabel)
    {
        _placeholderLabel = [UILabel new];
        _placeholderLabel.clipsToBounds = NO;
        _placeholderLabel.autoresizesSubviews = NO;
        _placeholderLabel.numberOfLines = 1;
        _placeholderLabel.font = self.font;
        _placeholderLabel.backgroundColor = [UIColor clearColor];
        _placeholderLabel.textColor = [UIColor lightGrayColor];
        _placeholderLabel.hidden = YES;

        [self addSubview:_placeholderLabel];
    }

    return _placeholderLabel;
}

- (NSString *)placeholder
{
    return self.placeholderLabel.text;
}

- (UIColor *)placeholderColor
{
    return self.placeholderLabel.textColor;
}

- (NSUInteger)numberOfLines
{
    CGSize contentSize = self.contentSize;

    CGFloat contentHeight = contentSize.height;
    contentHeight -= self.textContainerInset.top + self.textContainerInset.bottom;

    NSUInteger lines = fabs(contentHeight/self.font.lineHeight);

    // This helps preventing the content's height to be larger that the bounds' height
    // Avoiding this way to have unnecessary scrolling in the text view when there is only 1 line of content
    if (lines == 1 && contentSize.height > self.bounds.size.height)
    {
        contentSize.height = self.bounds.size.height;
        self.contentSize = contentSize;
    }

    // Let's fallback to the minimum line count
    if (lines == 0)
    {
        lines = 1;
    }

    return lines;
}

- (NSUInteger)maxNumberOfLines
{
    NSUInteger numberOfLines = _maxNumberOfLines;

    if (IS_LANDSCAPE)
    {

        if ((IS_IPHONE4 || IS_IPHONE5))
        {
            numberOfLines = 2.0; // 2 lines max on smaller iPhones
        }
        else if (IS_IPHONE)
        {
            numberOfLines /= 2.0; // Half size on larger iPhone
        }
    }

    if (self.isDynamicTypeEnabled)
    {
        NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];
        CGFloat pointSizeDifference = [MessageTextView pointSizeDifferenceForCategory:contentSizeCategory];

        CGFloat factor = pointSizeDifference/self.initialFontSize;

        if (fabs(factor) > 0.75)
        {
            factor = 0.75;
        }

        numberOfLines -= floorf(numberOfLines * factor); // Calculates a dynamic number of lines depending of the user preferred font size
    }

    return numberOfLines;
}

- (BOOL)isTypingSuggestionEnabled
{
    return (self.autocorrectionType == UITextAutocorrectionTypeNo) ? NO : YES;
}

- (BOOL)isFormattingEnabled
{
    return (_registeredFormattingSymbols.count > 0) ? YES : NO;
}

// Returns only a supported pasted item
//- (id)pastedItem
//{
//    NSString *contentType = [self pasteboardContentType];
//    NSData *data = [[UIPasteboard generalPasteboard] dataForPasteboardType:contentType];
//
//    if (data && [data isKindOfClass:[NSData class]])
//    {
//        PastableMediaType mediaType = PastableMediaTypeFromNSString(contentType);
//
//        NSDictionary *userInfo = @{MessagePastedItemContentType: contentType,
//                                   MessagePastedItemMediaType: @(mediaType),
//                                   MessagePastedItemData: data};
//        return userInfo;
//    }
//
//    if ([[UIPasteboard generalPasteboard] URL])
//    {
//        return [[[UIPasteboard generalPasteboard] URL] absoluteString];
//    }
//
//    if ([[UIPasteboard generalPasteboard] string])
//    {
//        return [[UIPasteboard generalPasteboard] string];
//    }
//
//    return nil;
//}

// Checks if any supported media found in the general pasteboard
- (BOOL)isPasteboardItemSupported
{
    if ([self pasteboardContentType].length > 0)
    {
        return YES;
    }

    return NO;
}

- (NSString *)pasteboardContentType
{
    NSArray *pasteboardTypes = [[UIPasteboard generalPasteboard] pasteboardTypes];
    NSMutableArray *subpredicates = [NSMutableArray new];

    for (NSString *type in [self supportedMediaTypes])
    {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"SELF == %@", type]];
    }

    return [[pasteboardTypes filteredArrayUsingPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:subpredicates]] firstObject];
}

- (NSArray *)supportedMediaTypes
{
    if (self.pastableMediaTypes == PastableMediaTypeNone)
    {
        return nil;
    }

    NSMutableArray *types = [NSMutableArray new];

    if (self.pastableMediaTypes & PastableMediaTypePNG)
    {
        [types addObject:NSStringFromPastableMediaType(PastableMediaTypePNG)];
    }

    if (self.pastableMediaTypes & PastableMediaTypeJPEG)
    {
        [types addObject:NSStringFromPastableMediaType(PastableMediaTypeJPEG)];
    }

    if (self.pastableMediaTypes & PastableMediaTypeTIFF)
    {
        [types addObject:NSStringFromPastableMediaType(PastableMediaTypeTIFF)];
    }

    if (self.pastableMediaTypes & PastableMediaTypeGIF)
    {
        [types addObject:NSStringFromPastableMediaType(PastableMediaTypeGIF)];
    }

    if (self.pastableMediaTypes & PastableMediaTypeMOV)
    {
        [types addObject:NSStringFromPastableMediaType(PastableMediaTypeMOV)];
    }

    if (self.pastableMediaTypes & PastableMediaTypePassbook)
    {
        [types addObject:NSStringFromPastableMediaType(PastableMediaTypePassbook)];
    }

    if (self.pastableMediaTypes & PastableMediaTypeImages)
    {
        [types addObject:NSStringFromPastableMediaType(PastableMediaTypeImages)];
    }

    return types;
}

NSString *NSStringFromPastableMediaType(PastableMediaType type)
{
    if (type == PastableMediaTypePNG)
    {
        return @"public.png";
    }

    if (type == PastableMediaTypeJPEG)
    {
        return @"public.jpeg";
    }

    if (type == PastableMediaTypeTIFF)
    {
        return @"public.tiff";
    }

    if (type == PastableMediaTypeGIF)
    {
        return @"com.compuserve.gif";
    }

    if (type == PastableMediaTypeMOV)
    {
        return @"com.apple.quicktime";
    }

    if (type == PastableMediaTypePassbook)
    {
        return @"com.apple.pkpass";
    }

    if (type == PastableMediaTypeImages)
    {
        return @"com.apple.uikit.image";
    }

    return nil;
}

PastableMediaType PastableMediaTypeFromNSString(NSString *string)
{
    if ([string isEqualToString:NSStringFromPastableMediaType(PastableMediaTypePNG)])
    {
        return PastableMediaTypePNG;
    }

    if ([string isEqualToString:NSStringFromPastableMediaType(PastableMediaTypeJPEG)])
    {
        return PastableMediaTypeJPEG;
    }

    if ([string isEqualToString:NSStringFromPastableMediaType(PastableMediaTypeTIFF)])
    {
        return PastableMediaTypeTIFF;
    }

    if ([string isEqualToString:NSStringFromPastableMediaType(PastableMediaTypeGIF)])
    {
        return PastableMediaTypeGIF;
    }

    if ([string isEqualToString:NSStringFromPastableMediaType(PastableMediaTypeMOV)])
    {
        return PastableMediaTypeMOV;
    }

    if ([string isEqualToString:NSStringFromPastableMediaType(PastableMediaTypePassbook)])
    {
        return PastableMediaTypePassbook;
    }

    if ([string isEqualToString:NSStringFromPastableMediaType(PastableMediaTypeImages)])
    {
        return PastableMediaTypeImages;
    }

    return PastableMediaTypeNone;
}

- (BOOL)isExpanding
{
    if (self.numberOfLines >= self.maxNumberOfLines)
    {
        return YES;
    }

    return NO;
}

- (BOOL)shouldHidePlaceholder
{
    if (self.placeholder.length == 0 || self.text.length > 0)
    {
        return YES;
    }

    return NO;
}

- (CGRect)placeholderRectThatFits:(CGRect)bounds
{
    CGFloat padding = self.textContainer.lineFragmentPadding;
    CGRect rect = CGRectZero;
    rect.size.height = [self.placeholderLabel sizeThatFits:bounds.size].height;
    rect.size.width = self.textContainer.size.width - padding*2.0;
    rect.origin = UIEdgeInsetsInsetRect(bounds, self.textContainerInset).origin;
    rect.origin.x += padding;

    return rect;
}


#pragma mark - Setters

- (void)setPlaceholder:(NSString *)placeholder
{
    self.placeholderLabel.text = placeholder;
    self.accessibilityLabel = placeholder;

    [self setNeedsLayout];
}

- (void)setPlaceholderColor:(UIColor *)color
{
    self.placeholderLabel.textColor = color;
}

- (void)setUndoManagerEnabled:(BOOL)enabled
{
    if (self.undoManagerEnabled == enabled)
    {
        return;
    }

    self.undoManager.levelsOfUndo = 10;
    [self.undoManager removeAllActions];
    [self.undoManager setActionIsDiscardable:YES];

    _undoManagerEnabled = enabled;
}

- (void)setTypingSuggestionEnabled:(BOOL)enabled
{
    if (self.isTypingSuggestionEnabled == enabled)
    {
        return;
    }

    self.autocorrectionType = enabled ? UITextAutocorrectionTypeDefault : UITextAutocorrectionTypeNo;
    self.spellCheckingType = enabled ? UITextSpellCheckingTypeDefault : UITextSpellCheckingTypeNo;

    [self refreshFirstResponder];
}


#pragma mark - UITextView Overrides

- (void)setSelectedRange:(NSRange)selectedRange
{
    [super setSelectedRange:selectedRange];
}

//- (void)setSelectedTextRange:(UITextRange *)selectedTextRange
//{
//    [super setSelectedTextRange:selectedTextRange];
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:MessageSelectedRangeDidChangeNotification object:self userInfo:nil];
//}

- (void)setText:(NSString *)text
{
    // Registers for undo management
    [self prepareForUndo:@"Text Set"];

    [super setText:text];

    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    // Registers for undo management
    [self prepareForUndo:@"Attributed Text Set"];

    [super setAttributedText:attributedText];

    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
}

- (void)setFont:(UIFont *)font
{
    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];

    [self setFontName:font.fontName pointSize:font.pointSize withContentSizeCategory:contentSizeCategory];

    self.initialFontSize = font.pointSize;
}

- (void)setFontName:(NSString *)fontName pointSize:(CGFloat)pointSize withContentSizeCategory:(NSString *)contentSizeCategory
{
    if (self.isDynamicTypeEnabled)
    {
        pointSize += [MessageTextView pointSizeDifferenceForCategory:contentSizeCategory];
    }

    UIFont *dynamicFont = [UIFont fontWithName:fontName size:pointSize];

    [super setFont:dynamicFont];

    // Updates the placeholder font too
    self.placeholderLabel.font = dynamicFont;
}

- (void)setDynamicTypeEnabled:(BOOL)dynamicTypeEnabled
{
    if (self.isDynamicTypeEnabled == dynamicTypeEnabled)
    {
        return;
    }

    _dynamicTypeEnabled = dynamicTypeEnabled;

    NSString *contentSizeCategory = [[UIApplication sharedApplication] preferredContentSizeCategory];

    [self setFontName:self.font.fontName pointSize:self.initialFontSize withContentSizeCategory:contentSizeCategory];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];

    // Updates the placeholder text alignment too
    self.placeholderLabel.textAlignment = textAlignment;
}


#pragma mark - UITextInput Overrides

- (void)beginFloatingCursorAtPoint:(CGPoint)point
{
    [super beginFloatingCursorAtPoint:point];

    _trackpadEnabled = YES;
}

- (void)updateFloatingCursorAtPoint:(CGPoint)point
{
    [super updateFloatingCursorAtPoint:point];
}

//- (void)endFloatingCursor
//{
//    [super endFloatingCursor];
//
//    _trackpadEnabled = NO;
//
//    // We still need to notify a selection change in the textview after the trackpad is disabled
//    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
//    {
//        [self.delegate textViewDidChangeSelection:self];
//    }
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:MessageSelectedRangeDidChangeNotification object:self userInfo:nil];
//}


#pragma mark - UIResponder Overrides

- (BOOL)canBecomeFirstResponder
{
    [self addCustomMenuControllerItems];

    return [super canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [super becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    // Removes undo/redo items
    if (self.undoManagerEnabled)
    {
        [self.undoManager removeAllActions];
    }

    return [super canResignFirstResponder];
}

- (BOOL)resignFirstResponder
{
    return [super resignFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.isFormatting)
    {
        NSString *title = [self formattingTitleFromSelector:action];
        NSString *symbol = [self formattingSymbolWithTitle:title];

        if (symbol.length > 0)
        {

            if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldOfferFormattingForSymbol:)])
            {
                return [self.delegate textView:self shouldOfferFormattingForSymbol:symbol];
            }
            else
            {
                return YES;
            }
        }

        return NO;
    }

    if (action == @selector(delete:))
    {
        return NO;
    }

    if (action == @selector(presentFormattingMenu:))
    {
        return self.selectedRange.length > 0 ? YES : NO;
    }

    if (action == @selector(paste:) && [self isPasteboardItemSupported])
    {
        return YES;
    }

    if (action == @selector(paste:) && [self isPasteboardItemSupported])
    {
        return YES;
    }

    if (self.undoManagerEnabled)
    {

        if (action == @selector(undo:))
        {

            if (self.undoManager.undoActionIsDiscardable)
            {
                return NO;
            }

            return [self.undoManager canUndo];
        }
        if (action == @selector(redo:))
        {
            if (self.undoManager.redoActionIsDiscardable)
            {
                return NO;
            }

            return [self.undoManager canRedo];
        }
    }

    return [super canPerformAction:action withSender:sender];
}

//- (void)paste:(id)sender
//{
//    id pastedItem = [self pastedItem];
//
//    if ([pastedItem isKindOfClass:[NSDictionary class]])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:MessageDidPasteItemNotification object:nil userInfo:pastedItem];
//    }
//    else if ([pastedItem isKindOfClass:[NSString class]])
//    {
//        // Respect the delegate yo!
//        if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
//        {
//            if (![self.delegate textView:self shouldChangeTextInRange:self.selectedRange replacementText:pastedItem])
//            {
//                return;
//            }
//        }
//
//        // Inserting the text fixes a UITextView bug whitch automatically scrolls to the bottom
//        // and beyond scroll content size sometimes when the text is too long
//        [self insertTextAtCaretRange:pastedItem];
//    }
//}


#pragma mark - NSObject Overrides

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if ([super methodSignatureForSelector:sel])
    {
        return [super methodSignatureForSelector:sel];
    }

    return [super methodSignatureForSelector:@selector(format:)];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *title = [self formattingTitleFromSelector:[invocation selector]];

    if (title.length > 0)
    {
        [self format:title];
    }
    else
    {
        [super forwardInvocation:invocation];
    }
}


#pragma mark - Custom Actions

- (void)flashScrollIndicatorsIfNeeded
{
    if (self.numberOfLines == self.maxNumberOfLines+1)
    {
        if (!_didFlashScrollIndicators)
        {
            _didFlashScrollIndicators = YES;
            [super flashScrollIndicators];
        }
    }
    else if (_didFlashScrollIndicators)
    {
        _didFlashScrollIndicators = NO;
    }
}

- (void)refreshFirstResponder
{
    if (!self.isFirstResponder)
    {
        return;
    }

    _didNotResignFirstResponder = YES;
    [self resignFirstResponder];

    _didNotResignFirstResponder = NO;
    [self becomeFirstResponder];
}

- (void)refreshInputViews
{
    _didNotResignFirstResponder = YES;

    [super reloadInputViews];

    _didNotResignFirstResponder = NO;
}

- (void)addCustomMenuControllerItems
{
    UIMenuItem *undo = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Undo", nil) action:@selector(undo:)];
    UIMenuItem *redo = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Redo", nil) action:@selector(redo:)];
    UIMenuItem *format = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Format", nil) action:@selector(presentFormattingMenu:)];

    [[UIMenuController sharedMenuController] setMenuItems:@[undo, redo, format]];
}

- (void)undo:(id)sender
{
    [self.undoManager undo];
}

- (void)redo:(id)sender
{
    [self.undoManager redo];
}

- (void)presentFormattingMenu:(id)sender
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.registeredFormattingTitles.count];

    for (NSString *name in self.registeredFormattingTitles)
    {
        NSString *sel = [NSString stringWithFormat:@"%@%@", TextViewGenericFormattingSelectorPrefix, name];

        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:name action:NSSelectorFromString(sel)];
        [items addObject:item];
    }

    self.formatting = YES;

    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:items];

    NSLayoutManager *manager = self.layoutManager;
    CGRect targetRect = [manager boundingRectForGlyphRange:self.selectedRange inTextContainer:self.textContainer];

    [menu setTargetRect:targetRect inView:self];

    [menu setMenuVisible:YES animated:YES];
}

- (NSString *)formattingTitleFromSelector:(SEL)selector
{
    NSString *selectorString = NSStringFromSelector(selector);
    NSRange match = [selectorString rangeOfString:TextViewGenericFormattingSelectorPrefix];

    if (match.location != NSNotFound)
    {
        return [selectorString substringFromIndex:TextViewGenericFormattingSelectorPrefix.length];
    }

    return nil;
}

- (NSString *)formattingSymbolWithTitle:(NSString *)title
{
    NSUInteger idx = [self.registeredFormattingTitles indexOfObject:title];

    if (idx <= self.registeredFormattingSymbols.count -1)
    {
        return self.registeredFormattingSymbols[idx];
    }

    return nil;
}

- (void)format:(NSString *)titles
{
    NSString *symbol = [self formattingSymbolWithTitle:titles];

    if (symbol.length > 0)
    {
        NSRange selection = self.selectedRange;
        NSRange range = [self insertText:symbol inRange:NSMakeRange(selection.location, 0)];
        range.location += selection.length;
        range.length = 0;

        // The default behavior is to add a closure
        BOOL addClosure = YES;

        if (self.delegate && [self.delegate respondsToSelector:@selector(textView:shouldInsertSuffixForFormattingWithSymbol:prefixRange:)])
        {
            addClosure = [self.delegate textView:self shouldInsertSuffixForFormattingWithSymbol:symbol prefixRange:selection];
        }

        if (addClosure)
        {
            self.selectedRange = [self insertText:symbol inRange:range];
        }
    }
}


#pragma mark - Markdown Formatting

- (void)registerMarkdownFormattingSymbol:(NSString *)symbol withTitle:(NSString *)title
{
    if (!symbol || !title)
    {
        return;
    }

    if (!_registeredFormattingTitles)
    {
        _registeredFormattingTitles = [NSMutableArray new];
        _registeredFormattingSymbols = [NSMutableArray new];
    }

    // Adds the symbol if not contained already
    if (![self.registeredSymbols containsObject:symbol])
    {
        [self.registeredFormattingTitles addObject:title];
        [self.registeredFormattingSymbols addObject:symbol];
    }
}

- (NSArray *)registeredSymbols
{
    return self.registeredFormattingSymbols;
}


#pragma mark - Notification Events

- (void)didBeginEditing:(NSNotification *)notification
{
    if (![notification.object isEqual:self])
    {
        return;
    }

    // Do something
}

- (void)didChangeText:(NSNotification *)notification
{
    if (![notification.object isEqual:self])
    {
        return;
    }

    if (self.placeholderLabel.hidden != [self shouldHidePlaceholder])
    {
        [self setNeedsLayout];
    }

    [self flashScrollIndicatorsIfNeeded];
}

- (void)didEndEditing:(NSNotification *)notification
{
    if (![notification.object isEqual:self])
    {
        return;
    }

    // Do something
}

- (void)didChangeTextInputMode:(NSNotification *)notification
{
    // Do something
}

- (void)didChangeContentSizeCategory:(NSNotification *)notification
{
    if (!self.isDynamicTypeEnabled)
    {
        return;
    }

    NSString *contentSizeCategory = notification.userInfo[UIContentSizeCategoryNewValueKey];

    [self setFontName:self.font.fontName pointSize:self.initialFontSize withContentSizeCategory:contentSizeCategory];

    NSString *text = [self.text copy];

    // Reloads the content size of the text view
    [self setText:@" "];
    [self setText:text];
}

- (void)willShowMenuController:(NSNotification *)notification
{

}

- (void)didHideMenuController:(NSNotification *)notification
{
    self.formatting = NO;

    [self addCustomMenuControllerItems];
}


#pragma mark - KVO Listener

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([object isEqual:self] && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))])
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:MessageContentSizeDidChangeNotification object:self userInfo:nil];
//    }
//    else
//    {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
//}


#pragma mark - Motion Events

//- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
//{
//    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake)
//    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:MessageDidShakeNotification object:self];
//    }
//}


#pragma mark - External Keyboard Support

- (NSArray *)keyCommands
{
    if (_keyboardCommands)
    {
        return _keyboardCommands;
    }

    _keyboardCommands = @[
                          // Return
                          [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:UIKeyModifierShift action:@selector(didPressLineBreakKeys:)],
                          [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:UIKeyModifierAlternate action:@selector(didPressLineBreakKeys:)],
                          [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:UIKeyModifierControl action:@selector(didPressLineBreakKeys:)],

                          // Undo/Redo
                          [UIKeyCommand keyCommandWithInput:@"z" modifierFlags:UIKeyModifierCommand action:@selector(didPressCommandZKeys:)],
                          [UIKeyCommand keyCommandWithInput:@"z" modifierFlags:UIKeyModifierShift|UIKeyModifierCommand action:@selector(didPressCommandZKeys:)],
                          ];

    return _keyboardCommands;
}


#pragma mark Line Break

- (void)didPressLineBreakKeys:(id)sender
{
    [self insertNewLineBreak];
}


#pragma mark Undo/Redo Text

- (void)didPressCommandZKeys:(id)sender
{
    if (!self.undoManagerEnabled)
    {
        return;
    }

    UIKeyCommand *keyCommand = (UIKeyCommand *)sender;

    if ((keyCommand.modifierFlags & UIKeyModifierShift) > 0)
    {

        if ([self.undoManager canRedo])
        {
            [self.undoManager redo];
        }
    }
    else
    {
        if ([self.undoManager canUndo])
        {
            [self.undoManager undo];
        }
    }
}

#pragma mark Up/Down Cursor Movement

- (void)didPressAnyArrowKey:(id)sender
{
    if (self.text.length == 0 || self.numberOfLines < 2)
    {
        return;
    }

    UIKeyCommand *keyCommand = (UIKeyCommand *)sender;

    if ([keyCommand.input isEqualToString:UIKeyInputUpArrow])
    {
        [self moveCursorToDirection:UITextLayoutDirectionUp];
    }
    else if ([keyCommand.input isEqualToString:UIKeyInputDownArrow])
    {
        [self moveCursorToDirection:UITextLayoutDirectionDown];
    }
}

- (void)moveCursorToDirection:(UITextLayoutDirection)direction
{
    UITextPosition *start = (direction == UITextLayoutDirectionUp) ? self.selectedTextRange.start : self.selectedTextRange.end;

    if ([self isNewVerticalMovementForPosition:start inDirection:direction])
    {
        self.verticalMoveDirection = direction;
        self.verticalMoveStartCaretRect = [self caretRectForPosition:start];
    }

    if (start)
    {
        UITextPosition *end = [self closestPositionToPosition:start inDirection:direction];

        if (end)
        {
            self.verticalMoveLastCaretRect = [self caretRectForPosition:end];
            self.selectedTextRange = [self textRangeFromPosition:end toPosition:end];

            [self scrollToCaretPositonAnimated:NO];
        }
    }
}

// Based on code from Ruben Cabaco
// https://gist.github.com/rcabaco/6765778

- (UITextPosition *)closestPositionToPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    // Only up/down are implemented. No real need for left/right since that is native to UITextInput.
    NSParameterAssert(direction == UITextLayoutDirectionUp || direction == UITextLayoutDirectionDown);

    // Translate the vertical direction to a horizontal direction.
    UITextLayoutDirection lookupDirection = (direction == UITextLayoutDirectionUp) ? UITextLayoutDirectionLeft : UITextLayoutDirectionRight;

    // Walk one character at a time in `lookupDirection` until the next line is reached.
    UITextPosition *checkPosition = position;
    UITextPosition *closestPosition = position;
    CGRect startingCaretRect = [self caretRectForPosition:position];
    CGRect nextLineCaretRect = CGRectZero;
    BOOL isInNextLine = NO;

    while (YES)
    {
        UITextPosition *nextPosition = [self positionFromPosition:checkPosition inDirection:lookupDirection offset:1];

        // End of line.
        if (!nextPosition || [self comparePosition:checkPosition toPosition:nextPosition] == NSOrderedSame)
        {
            break;
        }

        checkPosition = nextPosition;
        CGRect checkRect = [self caretRectForPosition:checkPosition];
        if (CGRectGetMidY(startingCaretRect) != CGRectGetMidY(checkRect))
        {

            // While on the next line stop just above/below the starting position.
            if (lookupDirection == UITextLayoutDirectionLeft && CGRectGetMidX(checkRect) <= CGRectGetMidX(self.verticalMoveStartCaretRect))
            {
                closestPosition = checkPosition;
                break;
            }

            if (lookupDirection == UITextLayoutDirectionRight && CGRectGetMidX(checkRect) >= CGRectGetMidX(self.verticalMoveStartCaretRect))
            {
                closestPosition = checkPosition;
                break;
            }

            // But don't skip lines.
            if (isInNextLine && CGRectGetMidY(checkRect) != CGRectGetMidY(nextLineCaretRect))
            {
                break;
            }

            isInNextLine = YES;
            nextLineCaretRect = checkRect;
            closestPosition = checkPosition;
        }
    }

    return closestPosition;
}

- (BOOL)isNewVerticalMovementForPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    CGRect caretRect = [self caretRectForPosition:position];
    BOOL noPreviousStartPosition = CGRectEqualToRect(self.verticalMoveStartCaretRect, CGRectZero);
    BOOL caretMovedSinceLastPosition = !CGRectEqualToRect(caretRect, self.verticalMoveLastCaretRect);
    BOOL directionChanged = self.verticalMoveDirection != direction;
    BOOL newMovement = noPreviousStartPosition || caretMovedSinceLastPosition || directionChanged;

    return newMovement;
}


#pragma mark - NSNotificationCenter register/unregister

//- (void)registerNotifications
//{
//    [self unregisterNotifications];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeText:) name:UITextViewTextDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeTextInputMode:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeContentSizeCategory:) name:UIContentSizeCategoryDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowMenuController:) name:UIMenuControllerWillShowMenuNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideMenuController:) name:UIMenuControllerDidHideMenuNotification object:nil];
//}

//- (void)unregisterNotifications
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextInputCurrentInputModeDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
//}


#pragma mark - Lifeterm

//- (void)dealloc
//{
//    [self unregisterNotifications];
//    
//    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
//    
//    _placeholderLabel = nil;
//}

@end
