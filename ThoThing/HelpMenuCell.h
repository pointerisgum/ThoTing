//
//  HelpMenuCell.h
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpMenuCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Arrow;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_LineLeft;
@end
