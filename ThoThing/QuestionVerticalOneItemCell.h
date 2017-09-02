//
//  QuestionVerticalOneItemCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 2. 3..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionVerticalOneItemCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *v_Item;
@property (nonatomic, weak) IBOutlet UIView *v_SubJectBg;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubjectName;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Owner;
@property (nonatomic, weak) IBOutlet UILabel *lb_Price;
@property (nonatomic, weak) IBOutlet UIButton *btn_Price;
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;
@property (nonatomic, weak) IBOutlet UIButton *btn_Select;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_Tail;
@end
