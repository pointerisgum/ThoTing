//
//  Blue8RoundButton.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 25..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "Blue8RoundButton.h"

@implementation Blue8RoundButton

- (void)awakeFromNib
{
    self.layer.cornerRadius = 8.f;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = kMainColor.CGColor;
    self.layer.borderWidth = 1.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
