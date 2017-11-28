//
//  OtherImageCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 29..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "OtherImageCell.h"

@implementation OtherImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.v_Video.userInteractionEnabled = NO;
    
    self.iv_User.clipsToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
    
    self.btn_Play.userInteractionEnabled = NO;
    
    self.iv_Contents.layer.cornerRadius = 15.f;
    self.iv_ContentsBg.layer.cornerRadius = 15.f;
    self.iv_Contents.contentMode = UIViewContentModeScaleToFill;
    
    //피터님이 2017.11.10 이미지에 뿌옇게 올린거 빼달라고 함
    self.iv_ContentsBg.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
