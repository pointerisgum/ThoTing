//
//  SizeFitButton.m
//  PB
//
//  Created by KimYoung-Min on 2014. 12. 15..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import "SizeFitButton.h"

@implementation SizeFitButton
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
}
@end
