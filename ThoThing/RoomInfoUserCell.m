//
//  RoomInfoUserCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 1..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "RoomInfoUserCell.h"

@implementation RoomInfoUserCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.height / 2;
    
    self.iv_Reader.layer.cornerRadius = self.iv_Reader.frame.size.width / 2;
//    self.iv_Reader.layer.borderWidth = 1.f;
//    self.iv_Reader.layer.borderColor = [UIColor whiteColor].CGColor;
}

@end
