//
//  SampleView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 25..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "SampleView.h"

@implementation SampleView

- (void)awakeFromNib
{
    self.btn_Play.layer.cornerRadius = 16.f;
    self.btn_Play.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Play.layer.borderWidth = 0.7f;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
