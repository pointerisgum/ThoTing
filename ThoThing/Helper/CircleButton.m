//
//  CircleButton.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 1..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "CircleButton.h"

@implementation CircleButton

- (void)awakeFromNib
{
    [self layoutIfNeeded];
    
    self.layer.cornerRadius = self.frame.size.width/2;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
