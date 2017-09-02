//
//  ChannelQuestionListCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelQuestionListCell.h"

@implementation ChannelQuestionListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btn_Price.layer.cornerRadius = 8.f;
    self.btn_Price.layer.borderColor = kMainColor.CGColor;
    self.btn_Price.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
