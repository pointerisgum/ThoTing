//
//  QuestionListHeaderCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionListHeaderCell.h"

@implementation QuestionListHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.v_PlayContainer.layer.cornerRadius = 17.f;
    self.v_PlayContainer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.v_PlayContainer.layer.borderWidth = 0.7f;

    [self.btn_Info setImage:BundleImage(@"sidemenu_black.png") forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLabelColor:(UIColor *)color
{
    self.lb_Play.textColor = color;
    self.v_PlayContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.btn_ViewCnt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_StarCnt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_CommentCnt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_Play setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

}

@end
