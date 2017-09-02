//
//  PauseViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PauseViewController : UIViewController
@property (nonatomic, strong) NSString *str_Title;
@property (nonatomic, strong) NSString *str_StartCnt;
@property (nonatomic, strong) NSString *str_TotalCnt;
@property (nonatomic, strong) NSString *str_Time;

- (void)updateDataWithTitle:(NSString *)aTitle withStartCnt:(NSString *)aStartCnt withTotalCnt:(NSString *)aTotalCnt withTime:(NSString *)aTime;

@end
