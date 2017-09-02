//
//  MyFollowingCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyFollowingCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn_Status;
@property (nonatomic, weak) IBOutlet UIButton *btn_Follow;
@end
