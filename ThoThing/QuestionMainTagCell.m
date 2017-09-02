//
//  QuestionMainTagCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 12..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "QuestionMainTagCell.h"

@implementation QuestionMainTagCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.tv_Tag.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
