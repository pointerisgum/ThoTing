//
//  KeyboardAccViewNonArrow.m
//  SkinFood
//
//  Created by KimYoung-Min on 2015. 2. 1..
//  Copyright (c) 2015년 woody.kim. All rights reserved.
//

#import "KeyboardAccViewNonArrow.h"

@implementation KeyboardAccViewNonArrow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)goDone:(id)sender
{
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    [keyWindow endEditing:YES];
}

@end
