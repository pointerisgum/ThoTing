//
//  FeedSharedCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 23..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "FeedSharedCell.h"

@implementation FeedSharedCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.iv_Thumb.backgroundColor = [UIColor blackColor];
    
    self.btn_Start.layer.cornerRadius = 5.f;
    self.btn_Start.layer.borderWidth = 1.f;
    self.btn_Start.layer.borderColor = kMainColor.CGColor;
    
    self.btn_Start.hidden = self.iv_Arrow.hidden = YES;
    
    self.btn_Start.userInteractionEnabled = NO;
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
    
    //    self.lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Title.frame);
}

@end
