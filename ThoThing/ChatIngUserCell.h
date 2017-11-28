//
//  ChatIngUserCell.h
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 26..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatIngUserCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_NinkName;
@property (nonatomic, weak) IBOutlet UILabel *lb_Count;
@property (nonatomic, weak) IBOutlet UIButton *btn_Check;
@end
