//
//  TwoOtherChatCell.h
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 17..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherChatBasicCell.h"

@interface TwoOtherChatCell : OtherChatBasicCell
@property (nonatomic, weak) IBOutlet UIView *v_ContentsBg2;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *lb_Contents2;
@property (nonatomic, weak) IBOutlet UIButton *btn_BotName;
@end