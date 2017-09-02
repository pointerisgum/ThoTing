//
//  AllRoundButton.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 5. 11..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "AllRoundButton.h"

@implementation AllRoundButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 6.f;
}

@end
