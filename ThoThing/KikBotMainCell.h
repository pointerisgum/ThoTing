//
//  KikBotMainCell.h
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StarView.h"

@interface KikBotMainCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Titile;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tags;
@property (nonatomic, weak) IBOutlet UILabel *lb_Count;
@property (nonatomic, weak) IBOutlet UILabel *lb_MemberCount;
@property (nonatomic, weak) IBOutlet StarView *v_Star;
@end
