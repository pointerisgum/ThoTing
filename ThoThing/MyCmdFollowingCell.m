//
//  MyCmdFollowingCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 6..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MyCmdFollowingCell.h"

@implementation MyCmdFollowingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.v_Bg.layer.cornerRadius = 10.f;
    self.v_Bg.layer.borderColor = [UIColor colorWithHexString:@"3CC2DA"].CGColor;
    self.v_Bg.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
