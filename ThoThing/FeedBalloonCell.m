//
//  FeedBalloonCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "FeedBalloonCell.h"

@implementation FeedBalloonCell

- (void)awakeFromNib
{
    // Initialization code
    
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
    self.lb_Discription.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Discription.frame);
}

@end
