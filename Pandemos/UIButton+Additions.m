//
//  UIButton+Additions.m
//  Pandemos
//
//  Created by Michael Sevy on 3/14/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "UIButton+Additions.h"
#import "UIColor+Pandemos.h"
#import <QuartzCore/QuartzCore.h>

#define pi 3.14159265359
#define DEGREES_TO_RADIANS(degrees) ((pi * degrees) / 180)
#define ROUND_BUTTON_WIDTH_HEIGHT 11.0


@implementation UIButton (Additions)

+(UIButton*)circleButtonEdges:(UIButton *)button
{
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.frame.size.height *.5f;
    button.layer.cornerRadius = button.bounds.size.width *.5f;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor uclaBlue].CGColor];
    return button;
}

+(void)setUpButton:(UIButton *)button
{
    button.layer.cornerRadius = 7.5;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor blackColor].CGColor];
    [button setTitleColor:[UIColor facebookBlue] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
}

+(void)changeButtonState:(UIButton *)button
{
    [button setHighlighted:YES];
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor yellowGreen] forState:UIControlStateNormal];
}

+(void)changeButtonStateForSingleButton:(UIButton*)button
{
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

+(void)changeOtherButton:(UIButton *)button
{
    [button setHighlighted:NO];
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

+(void)acceptButton:(UIButton *)button
{
    button.transform = CGAffineTransformMakeRotation(M_PI / 180 * 10);
    button.layer.cornerRadius = 20;
}

+(void)denyButton:(UIButton *)button
{
    button.transform = CGAffineTransformMakeRotation(M_PI / 180 * -10);
    button.layer.cornerRadius = 20;
}
@end
