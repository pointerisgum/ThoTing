//
//  QuestionVerticalOneItemCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 2. 3..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "QuestionVerticalOneItemCell.h"

@implementation QuestionVerticalOneItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btn_Price.layer.cornerRadius = 5.f;
    self.btn_Price.layer.borderColor = kMainColor.CGColor;
    self.btn_Price.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
