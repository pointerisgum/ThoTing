//
//  KikMyBotCollectionCell.m
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 27..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikMyBotCollectionCell.h"

@implementation KikMyBotCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
}

@end
