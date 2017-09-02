//
//  ActionSheetBottomStarCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 2. 3..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ActionSheetBottomStarCell.h"

@implementation ActionSheetBottomStarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if( ([UIScreen mainScreen].applicationFrame.size.width == 320) )
    {
        self.lc_StarLeading.constant = 25.f;
    }
    else if( ([UIScreen mainScreen].applicationFrame.size.width == 375) )
    {
        self.lc_StarLeading.constant = 60.f;
    }
    else if( ([UIScreen mainScreen].applicationFrame.size.width > 375) )
    {
        self.lc_StarLeading.constant = 90.f;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
