//
//  OtherCmdFollowingCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 6..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "OtherCmdFollowingCell.h"

@implementation OtherCmdFollowingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.v_Bg.layer.cornerRadius = 10.f;
    self.v_Bg.layer.borderColor = [UIColor colorWithHexString:@"4FB826"].CGColor;
    self.v_Bg.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
