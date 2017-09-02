//
//  AnswerPrintSubjectCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerPrintSubjectCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *v_TitleContainer;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_MyAnswer;
@property (nonatomic, weak) IBOutlet UIButton *btn_Answer;
@end
