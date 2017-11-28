//
//  KikAddMemberAccCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 26..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikAddMemberAccCell.h"

@implementation KikAddMemberAccCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = kRoundColor.CGColor;
    self.iv_User.layer.borderWidth = 1.0f;

}

@end
