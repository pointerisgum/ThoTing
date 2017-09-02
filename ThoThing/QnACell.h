//
//  QnACell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 6..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QnACell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_ChannelIcon;
@property (nonatomic, weak) IBOutlet UIView *v_TitleBg;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_PeopleCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;
@end
