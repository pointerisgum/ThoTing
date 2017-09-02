//
//  OtherShareExamCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherChatBasicCell.h"

@interface OtherShareExamCell : OtherChatBasicCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Msg;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubjectName;
@property (nonatomic, weak) IBOutlet UIView *v_Bg;
@property (nonatomic, weak) IBOutlet UIButton *btn_Result;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ResultWidth;
@end
