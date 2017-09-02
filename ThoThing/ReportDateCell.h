//
//  ReportDateCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 8..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtendLabel.h"
#import "YmExtendButton.h"

@interface ReportDateCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Subject;
@property (nonatomic, weak) IBOutlet UILabel *lb_Score;
@property (nonatomic, weak) IBOutlet ExtendLabel *lb_ScoreCount;

@property (nonatomic, weak) IBOutlet UILabel *lb_SubjectName;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalQuestionCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_AvgScore;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalCount;

@property (nonatomic, weak) IBOutlet YmExtendButton *btn_Ranking;

@end
 
