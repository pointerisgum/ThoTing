//
//  ChatReportCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 10..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatReportCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_School;
@property (nonatomic, weak) IBOutlet UILabel *lb_Score;
@property (nonatomic, weak) IBOutlet UILabel *lb_SolveCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_Ranking;
@end
