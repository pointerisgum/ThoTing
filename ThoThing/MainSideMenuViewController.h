//
//  MainSideMenuViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainSideMenuViewController : UIViewController
@property (nonatomic, assign) BOOL isChannelMode;
@property (nonatomic, strong) NSDictionary *dic_ChannelData;    //채널에서 마이를 눌렀을때 사용
@end
