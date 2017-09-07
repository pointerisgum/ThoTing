//
//  OtherChatCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 27..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel.h>
#import "SWTableViewCell.h"

@interface OtherChatBasicCell : SWTableViewCell
@property (nonatomic, assign) NSInteger nUserId;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UIView *v_ContentsBg;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_Read;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_NameHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BottomHeight;
@end
