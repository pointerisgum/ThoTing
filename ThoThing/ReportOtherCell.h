//
//  ReportOtherCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 26..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportOtherCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Cover;
@property (nonatomic, weak) IBOutlet UILabel *lb_CorverTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Owner;
@property (nonatomic, weak) IBOutlet UILabel *lb_Counting;
@property (nonatomic, weak) IBOutlet UIButton *btn_Star;
@property (nonatomic, weak) IBOutlet UIButton *btn_Comment;
@property (nonatomic, weak) IBOutlet UIView *v_Progress;
@property (nonatomic, weak) IBOutlet UIImageView *iv_ProgressBg;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Progress;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ProgressWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ProgressBgWidth;
@end
