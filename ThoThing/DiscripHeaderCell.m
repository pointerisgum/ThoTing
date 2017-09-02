//
//  DiscripHeaderCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 3..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "DiscripHeaderCell.h"

@implementation DiscripHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.btn_Report.showsTouchWhenHighlighted = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
