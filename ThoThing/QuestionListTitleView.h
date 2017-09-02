//
//  QuestionListTitleView.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionListTitleView : UIView
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_Seper;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalCount;
@property (nonatomic, weak) IBOutlet UIButton *btn_Back;
@property (nonatomic, weak) IBOutlet UIButton *btn_Time;
@property (nonatomic, weak) IBOutlet UIButton *btn_SideMenu;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;
@property (nonatomic, weak) IBOutlet UIButton *btn_Check;
@property (nonatomic, weak) IBOutlet UIButton *btn_WrongTitle;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Count;
//@property (nonatomic, weak) IBOutlet UILabel *lb_Timer;
//@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BackWidth;
@end
 
