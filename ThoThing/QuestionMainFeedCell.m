//
//  QuestionMainFeedCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 12..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "QuestionMainFeedCell.h"

@implementation QuestionMainFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.iv_Icon.clipsToBounds = YES;
    self.iv_Icon.layer.cornerRadius = self.iv_Icon.frame.size.width / 2;
    self.iv_Icon.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    self.iv_Icon.layer.borderWidth = 0.5f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
