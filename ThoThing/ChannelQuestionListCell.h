//
//  ChannelQuestionListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelQuestionListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UILabel *lb_QuestionTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Grade;
@property (nonatomic, weak) IBOutlet UILabel *lb_Owner;
@property (nonatomic, weak) IBOutlet UILabel *lb_Shared;
@property (nonatomic, weak) IBOutlet UISwitch *sw_Shared;
@property (nonatomic, weak) IBOutlet UIButton *btn_Price;
@property (nonatomic, weak) IBOutlet UIView *v_Shared;
@end
