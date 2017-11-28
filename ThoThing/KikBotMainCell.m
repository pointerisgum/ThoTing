//
//  KikBotMainCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikBotMainCell.h"

@implementation KikBotMainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
