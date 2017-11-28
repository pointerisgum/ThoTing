//
//  TwoAutoChatAudioCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 17..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "TwoAutoChatAudioCell.h"

@implementation TwoAutoChatAudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_User.clipsToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;

    self.v_ContentsBg2.layer.cornerRadius = 20.f;
    self.v_ContentsBg2.clipsToBounds = YES;
    
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.lb_Contents2 updateConstraintsIfNeeded];
    [self.lb_Contents2 layoutIfNeeded];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
    //    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - 180;
    
    self.lb_Contents2.preferredMaxLayoutWidth = self.frame.size.width - kChatMargin;
    [self.lb_Contents2 setNeedsUpdateConstraints];
}

@end
