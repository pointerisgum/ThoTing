//
//  RoundingView.m
//  OrangeMT
//
//  Created by KimYoung-Min on 2016. 6. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "RoundingView.h"

@implementation RoundingView

- (void)awakeFromNib
{
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5.0f, 5.0f)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = self.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.layer.mask = maskLayer;

    self.layer.cornerRadius = 5.0;
    self.layer.masksToBounds = YES;
//    self.layer.borderColor = [UIColor colorWithRed:208.0f/255.0f green:180.0f/255.0f blue:216.0f/255.0f alpha:1].CGColor;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.0;

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
