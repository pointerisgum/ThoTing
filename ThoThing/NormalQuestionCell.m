//
//  NormalQuestionCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 7. 19..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "NormalQuestionCell.h"

@implementation NormalQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.sv_Contents.backgroundColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1];
    self.sv_Contents.scrollEnabled = NO;
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_User.clipsToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end