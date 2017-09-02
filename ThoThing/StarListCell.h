//
//  StarListCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 8..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn_Star;
@end
