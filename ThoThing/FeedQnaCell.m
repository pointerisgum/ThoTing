//
//  FeedQnaCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 24..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "FeedQnaCell.h"

@implementation FeedQnaCell

- (void)awakeFromNib
{
    // Initialization code
    
//    NSLayoutConstraint *c = self.iv_User.constraints[0];
//    self.iv_User.layer.cornerRadius = c.constant / 2;

    [super awakeFromNib];
    
    [self layoutIfNeeded];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
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
    
    //    self.lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Title.frame);
}

@end
