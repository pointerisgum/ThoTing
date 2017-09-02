//
//  OtherDirectChatMsgCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 4. 21..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "OtherDirectChatMsgCell.h"

@implementation OtherDirectChatMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.v_MainBox.layer.borderWidth = 0.f;
    self.v_MainBox.layer.cornerRadius = 20.f;
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
    
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - 190;
    self.lb_Msg.preferredMaxLayoutWidth = self.frame.size.width - 190;
}

@end
