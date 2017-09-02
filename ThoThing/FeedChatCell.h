//
//  FeedChatCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 19..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>

@interface FeedChatCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_Join;
@end
