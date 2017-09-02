//
//  ChannelSelectCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 30..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelSelectCell.h"

@implementation ChannelSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self layoutIfNeeded];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderWidth = 1.f;
    self.iv_User.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
