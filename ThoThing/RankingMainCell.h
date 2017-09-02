//
//  RankingMainCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 25..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankingMainCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UILabel *lb_Ranking;
@end
