//
//  BlueRoundButton.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "BlueRoundButton.h"

@implementation BlueRoundButton

- (void)awakeFromNib
{
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = kMainColor.CGColor;
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
