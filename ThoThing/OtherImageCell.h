//
//  OtherImageCell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 29..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherChatBasicCell.h"

@interface OtherImageCell : OtherChatBasicCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_Contents;
@property (nonatomic, weak) IBOutlet UIView *v_Video;
@property (nonatomic, weak) IBOutlet UIButton *btn_Play;
@property (nonatomic, weak) IBOutlet UIButton *btn_Origin;  //출처
@end
