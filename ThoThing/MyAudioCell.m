//
//  MyAudioCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 14..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MyAudioCell.h"

@implementation MyAudioCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.v_Bg.layer.cornerRadius = self.v_Bg.frame.size.height / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
