//
//  NoMatchesView.m
//  Pandemos
//
//  Created by Michael Sevy on 7/14/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import "NoMatchesView.h"
#import "AllyAdditions.h"

@implementation NoMatchesView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        NSString *nibName = NSStringFromClass([self class]);
        UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
        [nib instantiateWithOwner:self options:nil];
        self.mainImage.backgroundColor = [UIColor blueColor];
        self.container.backgroundColor = [UIColor greenColor];

        [self addSubview:self.container];
    }
    
    return self;
}

-(void)loadNoMatchesImage:(NSString*)imageURL
{
    self.mainImage.image = [UIImage imageNamed:imageURL];
}
@end
