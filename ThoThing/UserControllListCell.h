//
//  UserControllListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 31..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserControllListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_School;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UILabel *lb_Discrip;
@property (nonatomic, weak) IBOutlet UISwitch *sw;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SwTail;
@end
