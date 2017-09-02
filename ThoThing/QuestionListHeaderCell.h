//
//  QuestionListHeaderCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionListHeaderCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_ViewCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_StarCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_CommentCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_Play;
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UIView *v_PlayContainer;
@property (nonatomic, weak) IBOutlet UILabel *lb_Play;
//@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UIButton *btn_QnaCnt;
- (void)setLabelColor:(UIColor *)color;
@end
