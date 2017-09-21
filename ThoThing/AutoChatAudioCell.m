//
//  AutoChatAudioCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 8. 30..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "AutoChatAudioCell.h"

@implementation AutoChatAudioCell

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
