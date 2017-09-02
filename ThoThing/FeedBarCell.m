//
//  FeedBarCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "FeedBarCell.h"

@implementation FeedBarCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.btn_More.layer.cornerRadius = 8.0f;
    self.btn_More.layer.borderColor = kMainColor.CGColor;
    self.btn_More.layer.borderWidth = 1.f;
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
