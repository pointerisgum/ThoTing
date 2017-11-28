//
//  ChatIngUserCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 26..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ChatIngUserCell.h"

@implementation ChatIngUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = kRoundColor.CGColor;
    self.iv_User.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
