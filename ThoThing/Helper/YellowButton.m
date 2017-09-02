//
//  YellowButton.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 10. 25..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "YellowButton.h"

@implementation YellowButton

- (void)awakeFromNib
{
    [super awakeFromNib];

//    NSLayoutConstraint *c = self.constraints[0];
//    self.layer.cornerRadius = c.constant / 2;
    
    [self layoutIfNeeded];

    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
    self.layer.borderWidth = 2.f;
//
    [self setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateSelected];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
