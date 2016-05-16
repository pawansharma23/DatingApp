//
//  UIButton+Additions.h
//  Pandemos
//
//  Created by Michael Sevy on 3/14/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Additions)

+(void)setUpButton:(UIButton *)button;
+(void)roundButton:(UIButton *)button;
+(void)changeButtonState:(UIButton *)button;
+(void)changeOtherButton:(UIButton *)button;
+(void)acceptButton:(UIButton *)button;
+(void)denyButton:(UIButton *)button;
+(UIButton*)roundButtonEdges:(UIButton *)button radius:(CGFloat)radius startAngle:(CGFloat)startAngle endEndle:(CGFloat)endAngle;
@end
