//
//  OtherDirectChatMsgCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 4. 21..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherDirectChatCell.h"

@interface OtherDirectChatMsgCell : OtherDirectChatCell
@property (nonatomic, weak) IBOutlet UIView *v_MainBox;
@property (nonatomic, weak) IBOutlet UILabel *lb_Msg;
@property (nonatomic, weak) IBOutlet UILabel *lb_QNum;
@end