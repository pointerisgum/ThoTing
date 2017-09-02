//
//  NormalQuestionCell.h
//  ThoThing
//
//  Created by macpro15 on 2017. 7. 19..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NormalQuestionCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_Origin;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@end
