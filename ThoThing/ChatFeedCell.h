//
//  ChatFeedCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 23..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface ChatFeedCell : SWTableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Disc1;
@property (nonatomic, weak) IBOutlet UILabel *lb_Disc2;
@property (nonatomic, weak) IBOutlet UIButton *btn_Type;
//@property (nonatomic, weak) IBOutlet UIImageView *iv_Icon;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UILabel *lb_Badge;
@property (nonatomic, weak) IBOutlet UIView *v_BadgeGuide;
@property (nonatomic, weak) IBOutlet UILabel *lb_GroupCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalUser;
@end
