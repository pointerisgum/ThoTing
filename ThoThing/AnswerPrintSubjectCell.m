//
//  AnswerPrintSubjectCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "AnswerPrintSubjectCell.h"

@implementation AnswerPrintSubjectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.v_TitleContainer.layer.cornerRadius = 10;
    self.v_TitleContainer.layer.masksToBounds = YES;
    self.v_TitleContainer.layer.borderColor = kMainColor.CGColor;
    self.v_TitleContainer.layer.borderWidth = 2.0;

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
