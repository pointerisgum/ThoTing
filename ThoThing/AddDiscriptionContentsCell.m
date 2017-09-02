//
//  AddDiscriptionContentsCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "AddDiscriptionContentsCell.h"

@implementation AddDiscriptionContentsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.iv_Play.layer.cornerRadius = 8.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
