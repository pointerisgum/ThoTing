//
//  MyQuestionListCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "MyQuestionListCell.h"

@implementation MyQuestionListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btn_Group.layer.cornerRadius = 8.f;
    self.btn_Group.layer.borderColor = kMainColor.CGColor;
    self.btn_Group.layer.borderWidth = 1.0f;
    
    self.btn_Result.layer.cornerRadius = 8.f;
    self.btn_Result.layer.borderColor = kMainRedColor.CGColor;
    self.btn_Result.layer.borderWidth = 1.0f;
    
    self.iv_ProgressBg.layer.cornerRadius = 2.f;
    self.iv_Progress.layer.cornerRadius = 2.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
