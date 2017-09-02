//
//  OptionListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 19..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Status;
@property (nonatomic, weak) IBOutlet UISwitch *sw;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SwWidth;
@property (nonatomic, weak) IBOutlet UIImageView *iv_TopLine;
@property (nonatomic, weak) IBOutlet UIImageView *iv_BottomLine;
@end
