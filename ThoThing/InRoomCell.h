//
//  InRoomCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 13..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InRoomCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@end