//
//  SideMenuCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 31..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Number;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star;
@property (nonatomic, weak) IBOutlet UIImageView *iv_RedLine;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_NumberWidth;
@end
