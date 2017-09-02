//
//  ChannelFollowingListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelFollowingListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Grade;
@property (nonatomic, weak) IBOutlet UIButton *btn_Add;
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CloseWidth;
@end
