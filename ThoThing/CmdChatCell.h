//
//  CmdChatCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherChatBasicCell.h"

@interface CmdChatCell : OtherChatBasicCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Cmd;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIView *v_Bg;
@end
