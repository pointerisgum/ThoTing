//
//  ActionSheetBottomStarCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 2. 3..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarView.h"

@interface ActionSheetBottomStarCell : UITableViewCell
@property (nonatomic, weak) IBOutlet StarView *starView;
@property (nonatomic, weak) IBOutlet UILabel *lb_Discrip;
@property (nonatomic, weak) IBOutlet UILabel *lb_Score;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_StarLeading;
@end
