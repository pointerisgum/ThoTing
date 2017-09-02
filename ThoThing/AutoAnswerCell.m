//
//  AutoAnswerCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 8. 28..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "AutoAnswerCell.h"

@implementation AutoAnswerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.v_Bg.clipsToBounds = YES;
    self.v_Bg.layer.cornerRadius = 6.f;
    self.v_Bg.layer.borderColor = [UIColor colorWithRed:180.f/255.f green:180.f/255.f blue:180.f/255.f alpha:1].CGColor;
    self.v_Bg.layer.borderWidth = 0.5f;
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
    
    [self.v_Bg updateConstraintsIfNeeded];
    [self.v_Bg layoutIfNeeded];
    
    [self.lb_Title updateConstraintsIfNeeded];
    [self.lb_Title layoutIfNeeded];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    self.lb_Title.preferredMaxLayoutWidth = self.frame.size.width - 30;
}

@end
