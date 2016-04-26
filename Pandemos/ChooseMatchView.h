//
//  ChooseMatchView.h
//  Pandemos
//
//  Created by Michael Sevy on 4/25/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//

#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "User.h"

@interface ChooseMatchView : MDCSwipeToChooseView

@property (nonatomic, strong, readonly) User *user;

-(instancetype)initWithFrame:(CGRect)frame
                        user:(User*)user
                     options:(MDCSwipeToChooseViewOptions*)options;
@end
