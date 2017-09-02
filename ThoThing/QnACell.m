//
//  QnACell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 6..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QnACell.h"

@implementation QnACell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    [super awakeFromNib];
    
    self.v_TitleBg.layer.cornerRadius = 8.f;

    NSLayoutConstraint *c = self.iv_ChannelIcon.constraints[0];
    
    self.iv_ChannelIcon.layer.cornerRadius = c.constant / 2;
    self.iv_ChannelIcon.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_ChannelIcon.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
