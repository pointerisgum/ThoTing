//
//  QuestionViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 5. 17..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionViewController : UIViewController
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, strong) NSString *str_Title;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_StartIdx;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_SortType;
@property (nonatomic, assign) BOOL isPdf;
@property (nonatomic, assign) BOOL isNonPassMode;
@property (nonatomic, assign) NSInteger nStartPdfPage;
@property (nonatomic, strong) NSString *str_TesterId;
@end
