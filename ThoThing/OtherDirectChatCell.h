//
//  OtherDirectChatCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 4. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherChatBasicCell.h"

@interface OtherDirectChatCell : OtherChatBasicCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Read;
@property (nonatomic, weak) IBOutlet UILabel *lb_QNum;
@end
