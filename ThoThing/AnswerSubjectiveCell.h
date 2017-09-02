//
//  AnswerSubjectiveCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 30..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerSubjectiveCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *v_Container;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_Back;
@property (nonatomic, weak) IBOutlet UITextField *tf_Answer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContainerLeading;
@end
