//
//  ChattingCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 7..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChattingCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Ballon;
@property (nonatomic, weak) IBOutlet UILabel *lb_UserName;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_Reply;
@end
