//
//  ImageLabelViews.h
//  Pandemos
//
//  Created by Michael Sevy on 4/25/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageLabelViews : UIView

-(instancetype)initWithFrame:(CGRect)frame
                       image:(UIImage*)image
                        text:(NSString*)text;
@end
