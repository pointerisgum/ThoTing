//
//  MyChatCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "MyChatBasicCell.h"

@implementation MyChatBasicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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
    
    [self.v_ContentsBg updateConstraintsIfNeeded];
    [self.v_ContentsBg layoutIfNeeded];
    
    [self.lb_Contents updateConstraintsIfNeeded];
    [self.lb_Contents layoutIfNeeded];

    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - 135;
}

@end
