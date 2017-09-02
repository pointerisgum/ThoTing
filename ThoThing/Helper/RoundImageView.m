//
//  RoundImageView.m
//  Pari
//
//  Created by KimYoung-Min on 2014. 12. 20..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import "RoundImageView.h"

@implementation RoundImageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSLayoutConstraint *c = self.constraints[0];
    self.layer.cornerRadius = c.constant / 2;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.masksToBounds = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
