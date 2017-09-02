//
//  UIView+KeyboardDown.m
//  ASKing
//
//  Created by Kim Young-Min on 2013. 11. 11..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import "UIView+KeyboardDown.h"

@implementation UIView (KeyboardDown)
- (void)usingTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapRecognizer];
}

- (void)tapGesture:(UIGestureRecognizer *)gesture
{
    [self endEditing:YES];
}

@end
