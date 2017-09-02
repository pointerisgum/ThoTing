//
//  DiscripHeaderCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 3..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscripHeaderCell : UITableViewCell
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ImageX;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UILabel *lb_Time;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UIButton *btn_Report;
@end
