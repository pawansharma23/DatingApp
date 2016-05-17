//
//  UIButton+Additions.h
//  Pandemos
//
//  Created by Michael Sevy on 3/14/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Additions)

+(UIButton*)circleButtonEdges:(UIButton *)button;
+(void)setUpButton:(UIButton *)button;
+(void)changeButtonState:(UIButton *)button;
+(void)changeOtherButton:(UIButton *)button;
+(void)acceptButton:(UIButton *)button;
+(void)denyButton:(UIButton *)button;
@end
