//
//  QuestionIngStarNaviView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 7..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionIngStarNaviView.h"

@implementation QuestionIngStarNaviView

- (void)awakeFromNib
{
    self.btn_Count.layer.cornerRadius = 15.f;
    self.btn_Count.layer.borderColor = kMainColor.CGColor;
    self.btn_Count.layer.borderWidth = 1.0f;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
