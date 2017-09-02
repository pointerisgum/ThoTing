//
//  OnlineCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 5..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnlineCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Count;
@end
