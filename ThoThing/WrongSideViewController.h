//
//  WrongStarViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 3. 1..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kWrong,
    kStarQ,
} WrongListType;

typedef void (^SelectedCompletionBlock)(id completeResult);

@interface WrongSideViewController : UIViewController
@property (nonatomic, assign) WrongListType listType;
@property (nonatomic, assign) NSInteger nNowQuestionNum;
@property (nonatomic, strong) NSString *str_StartNo;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_TesterId;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_SchoolGrade;
@property (nonatomic, strong) NSString *str_SubjectName;
@property (nonatomic, copy) SelectedCompletionBlock completionBlock;
- (void)setCompletionBlock:(SelectedCompletionBlock)completionBlock;
- (void)closeMenu;
@end
