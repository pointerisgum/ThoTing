//
//  LibrarySubjectCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 7..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "LibrarySubjectCell.h"

@implementation LibrarySubjectCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.btn_Title.userInteractionEnabled = NO;
    [self.btn_Title.titleLabel setTextAlignment: NSTextAlignmentCenter];
}

@end
