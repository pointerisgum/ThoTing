//
//  CircleImageView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "CircleImageView.h"

@implementation CircleImageView

- (void)awakeFromNib
{
    NSLayoutConstraint *c = self.constraints[0];
    self.layer.cornerRadius = c.constant / 2;
//    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.layer.borderWidth = 1.0f;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
