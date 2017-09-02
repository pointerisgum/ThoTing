//
//  ReportOtherCell.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 26..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ReportOtherCell.h"

@implementation ReportOtherCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.v_Progress.layer.cornerRadius = 2.f;
    self.iv_ProgressBg.layer.cornerRadius = 2.f;
    self.iv_Progress.layer.cornerRadius = 2.f;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
