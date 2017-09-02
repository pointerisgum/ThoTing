//
//  MyQuestionListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyQuestionListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_QuestionTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Grade;
@property (nonatomic, weak) IBOutlet UILabel *lb_Owner;
@property (nonatomic, weak) IBOutlet UIImageView *iv_ProgressBg;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Progress;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ProgressWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ProgressBgWidth;
@property (nonatomic, weak) IBOutlet UIButton *btn_Group;   //단원보기
@property (nonatomic, weak) IBOutlet UIButton *btn_Result;
@property (nonatomic, weak) IBOutlet UIButton *btn_Paid;  //다른사람 페이지 볼때 사용
@property (nonatomic, weak) IBOutlet UIView *v_Progess;
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;
@property (nonatomic, weak) IBOutlet UIView *v_Star;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star1;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star2;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star3;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star4;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star5;
@property (nonatomic, weak) IBOutlet UIView *v_Base;
@end
