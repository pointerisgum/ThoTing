//
//  ChannelReportDetailListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 16..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelReportDetailListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_School;
@property (nonatomic, weak) IBOutlet UILabel *lb_Score;
@property (nonatomic, weak) IBOutlet UILabel *lb_DoneQCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_Ranking;
@end
