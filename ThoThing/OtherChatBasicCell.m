//
//  OtherChatCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "OtherChatBasicCell.h"

@implementation OtherChatBasicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_User.clipsToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;

    self.v_ContentsBg.layer.cornerRadius = 20.f;
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
    
    [self.lb_Contents updateConstraintsIfNeeded];
    [self.lb_Contents layoutIfNeeded];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
//    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
//    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - 180;
    
    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - kChatMargin;
    [self.lb_Contents setNeedsUpdateConstraints];
}

@end
