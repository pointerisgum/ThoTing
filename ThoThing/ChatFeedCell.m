//
//  ChatFeedCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 23..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChatFeedCell.h"

@implementation ChatFeedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];

    self.iv_User.backgroundColor = [UIColor whiteColor];
    self.iv_User.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_User.clipsToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
    
    self.iv_User1.backgroundColor = [UIColor whiteColor];
    self.iv_User1.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_User1.clipsToBounds = YES;
    self.iv_User1.layer.cornerRadius = self.iv_User1.frame.size.width / 2;
    self.iv_User1.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iv_User1.layer.borderWidth = 1.f;

    self.iv_User2.backgroundColor = [UIColor whiteColor];
    self.iv_User2.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_User2.clipsToBounds = YES;
    self.iv_User2.layer.cornerRadius = self.iv_User2.frame.size.width / 2;
    self.iv_User2.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iv_User2.layer.borderWidth = 1.f;
    
    self.v_BadgeGuide.layer.cornerRadius = 8.f;
    
    self.btn_Type.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
