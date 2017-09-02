//
//  MainSideMenuCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainSideMenuCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_TopLine;
@property (nonatomic, weak) IBOutlet UIImageView *iv_BottomLine;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Icon;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BottomLineX;
@end
