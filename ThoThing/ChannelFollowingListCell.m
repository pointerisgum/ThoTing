//
//  ChannelFollowingListCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelFollowingListCell.h"

@implementation ChannelFollowingListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    NSLayoutConstraint *c = self.iv_User.constraints[0];
    self.iv_User.layer.cornerRadius = c.constant / 2;

//    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
    
    self.btn_Add.layer.cornerRadius = 8.f;
    self.btn_Add.layer.borderWidth = 1.f;
    self.btn_Add.layer.borderColor = [UIColor clearColor].CGColor;
    self.btn_Add.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end