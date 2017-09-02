//
//  ActionSheetBottomCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionSheetBottomCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;
@property (nonatomic, weak) IBOutlet UISwitch *sw;
@end
