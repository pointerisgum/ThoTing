//
//  ReportSubjectListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YmExtendButton.h"

@interface ReportSubjectListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_QCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_Score;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalAvgScore;
@property (nonatomic, weak) IBOutlet UILabel *lb_MyRanking;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalUserCount;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_GridWidth;
@property (nonatomic, weak) IBOutlet YmExtendButton *btn_Select;
@property (nonatomic, weak) IBOutlet YmExtendButton *btn_Grid;
@property (nonatomic, weak) IBOutlet YmExtendButton *btn_Ranking;
@end
