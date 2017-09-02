//
//  MainDefaultCheckCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 5..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MainDefaultCheckCell.h"

@implementation MainDefaultCheckCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btn_Title.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
