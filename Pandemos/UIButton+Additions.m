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

@implementation UIButton (Additions)

+(void)setUpButton:(UIButton *)button
{
    button.layer.cornerRadius = 16.0 / 2.0;
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor uclaBlue].CGColor];
}

+(void)roundButton:(UIButton *)button;
{
    button.layer.cornerRadius = button.bounds.size.width / 2;
    button.clipsToBounds = YES;
    [button.layer setBorderColor:[UIColor whiteColor].CGColor];

}

+(void)changeButtonState:(UIButton *)button
{
    [button setHighlighted:YES];
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor yellowGreen] forState:UIControlStateNormal];
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
