//
//  AddDiscriptionTextCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "AddDiscriptionTextCell.h"

@implementation AddDiscriptionTextCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
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
    
    self.lb_Text.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Text.frame);
}

@end
