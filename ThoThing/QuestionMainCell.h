//
//  QuestionMainCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionItemView.h"

@interface QuestionMainCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_More;
@property (nonatomic, weak) IBOutlet UIButton *btn_Setting;
@property (nonatomic, weak) IBOutlet QuestionItemView *v_Item1;
@property (nonatomic, weak) IBOutlet QuestionItemView *v_Item2;
@property (nonatomic, weak) IBOutlet QuestionItemView *v_Item3;
@end
