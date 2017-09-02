//
//  FeedSharedCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 23..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedSharedCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_CoverTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SharedMessage;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UILabel *lb_QTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_QDiscrip;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Arrow;
@property (nonatomic, weak) IBOutlet UIButton *btn_Start;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_MessageHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ThumbWidth;
@property (nonatomic, weak) IBOutlet UIImageView *iv_PdfCover;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_PdfCorverHeight;
@end
