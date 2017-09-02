//
//  OtherShareExamCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "OtherShareExamCell.h"

@implementation OtherShareExamCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
//    self.v_Bg.layer.cornerRadius = 5.f;
    
    self.btn_Result.layer.cornerRadius = 5.f;
    self.btn_Result.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btn_Result.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
//        self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);

//    self.lb_Msg.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Msg.frame);
    self.lb_Msg.preferredMaxLayoutWidth = self.frame.size.width - 111;
    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - 190;
}

@end
