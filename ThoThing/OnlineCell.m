//
//  OnlineCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 5..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "OnlineCell.h"

@implementation OnlineCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
}

@end
