//
//  PinkRoundButton.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "PinkRoundButton.h"

@implementation PinkRoundButton

- (void)awakeFromNib
{
    NSLayoutConstraint *c = self.constraints[0];
    self.layer.cornerRadius = c.constant / 2;
//    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1].CGColor;
    self.layer.borderWidth = 2.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
