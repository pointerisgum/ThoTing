//
//  KikMyCell.h
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 23..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KikMyCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Icon;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Arrow;
@property (nonatomic, weak) IBOutlet UIImageView *iv_TopLine;
@property (nonatomic, weak) IBOutlet UIImageView *iv_BottomLine;
@property (nonatomic, weak) IBOutlet UISwitch *sw;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_LineLeft;
@end
