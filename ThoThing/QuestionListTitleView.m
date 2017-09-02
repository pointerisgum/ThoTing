//
//  QuestionListTitleView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionListTitleView.h"

@implementation QuestionListTitleView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self layoutIfNeeded];
    
    
    self.btn_Time.layer.cornerRadius = 18.f;
    self.btn_Time.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Time.layer.borderWidth = 1.f;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    [self updateConstraintsIfNeeded];
//    [self layoutIfNeeded];
//    
//    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
