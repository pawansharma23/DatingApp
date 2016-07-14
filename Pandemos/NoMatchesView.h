//
//  NoMatchesView.h
//  Pandemos
//
//  Created by Michael Sevy on 7/14/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoMatchesView : UIView
@property (strong, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

-(void)loadNoMatchesImage:(NSString*)imageURL;

@end
