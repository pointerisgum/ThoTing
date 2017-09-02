//
//  UIColor+Place.m
//  lifeOfFood
//
//  Created by 안창범 on 13. 2. 19..
//  Copyright (c) 2013년 NKsolution. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor*)colorWithRGB:(unsigned int)rgb {
    return [UIColor colorWithRed:(rgb >> 16) / 255.f
                           green:(rgb >> 8 & 0xff) / 255.f
                            blue:(rgb & 0xff) / 255.f
                           alpha:1];
}

@end
