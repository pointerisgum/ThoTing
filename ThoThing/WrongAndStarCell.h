//
//  WrongAndStarCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 2. 24..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WrongAndStarCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Count;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Arrow;
@end
