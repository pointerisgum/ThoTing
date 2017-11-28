//
//  KikMyCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 23..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikMyCell.h"

@implementation KikMyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.iv_Icon.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
