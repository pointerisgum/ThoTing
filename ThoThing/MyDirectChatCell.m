//
//  MyDirectChatCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 4. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MyDirectChatCell.h"

@implementation MyDirectChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];

    self.v_ContentsBg.layer.borderWidth = 2.f;
    self.v_ContentsBg.layer.borderColor = [UIColor colorWithHexString:@"3CC2DA"].CGColor;
    self.v_ContentsBg.layer.cornerRadius = 20.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
//    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - 100;
    self.lb_Contents.preferredMaxLayoutWidth = self.frame.size.width - kChatMargin;
}

@end
