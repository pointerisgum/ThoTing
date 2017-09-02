//
//  QuestionStartViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 2..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionStartViewController : UIViewController

@property (nonatomic, assign) BOOL isPdf;

@property (nonatomic, strong) NSString *str_Title;
@property (nonatomic, strong) NSString *str_UserIdx;
@property (nonatomic, strong) NSString *str_ChannelId;

@property (nonatomic, assign) NSInteger nTime;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_StartIdx;


@end
