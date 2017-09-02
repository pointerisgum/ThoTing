//
//  MyDirectChatMsgCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 4. 21..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MyDirectChatMsgCell.h"

@implementation MyDirectChatMsgCell

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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - 100;
    self.lb_Msg.preferredMaxLayoutWidth = self.frame.size.width - 100;
}

@end
