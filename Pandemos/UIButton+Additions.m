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

+(UIButton*)roundButtonEdges:(UIButton *)button radius:(CGFloat)radius startAngle:(CGFloat)startAngle endEndle:(CGFloat)endAngle
{
//    CGPoint center = CGPointMake(button.frame.size.width/2, button.frame.size.height/2);
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:center];
//    [path addArcWithCenter:center radius:radius startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
//    [path closePath];
//
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.frame = button.bounds;
//    layer.path = path.CGPath;
//    //layer.fillColor = [UIColor color]
//    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0);
//
//    [layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIButton *outputButton = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
    button.clipsToBounds = YES;
    [button.layer setBorderWidth:1.0];
    [button.layer setBorderColor:[UIColor uclaBlue].CGColor];



    button = [UIButton buttonWithType:UIButtonTypeCustom];

    //[button setImage:[UIImage imageNamed:@"TimoonPumba.png"] forState:UIControlStateNormal];

    //[button addTarget:self action:@selector(roundButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];

    //width and height should be same value
    button.frame = CGRectMake(0, 0, ROUND_BUTTON_WIDTH_HEIGHT, ROUND_BUTTON_WIDTH_HEIGHT);

    //Clip/Clear the other pieces whichever outside the rounded corner
    button.clipsToBounds = YES;

    //half of the width
    button.layer.cornerRadius = ROUND_BUTTON_WIDTH_HEIGHT/2.0f;
    button.layer.borderColor=[UIColor redColor].CGColor;
    button.layer.borderWidth=2.0f;
    
    //[self.view addSubview:button];
    return button;
}

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
