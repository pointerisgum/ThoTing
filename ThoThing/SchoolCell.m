//
//  SchoolCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 24..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "SchoolCell.h"

@implementation SchoolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.btn_Title.layer.cornerRadius = 8.f;
    self.btn_Title.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Title.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
