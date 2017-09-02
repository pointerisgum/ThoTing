//
//  ChannelReportDetailListCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 16..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelReportDetailListCell.h"

@implementation ChannelReportDetailListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
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
