//
//  FeedBarCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedBarCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_More;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_MoreWidth;
@end
