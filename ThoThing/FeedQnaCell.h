//
//  FeedQnaCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 24..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedQnaCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ImageX;
@end
