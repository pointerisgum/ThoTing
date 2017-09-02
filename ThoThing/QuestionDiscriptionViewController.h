//
//  QuestionDiscriptionViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 29..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionDiscriptionViewController : UIViewController
@property (nonatomic, assign) BOOL isQuestion;
@property (nonatomic, strong) NSArray *ar_Info;
//@property (nonatomic, strong) NSString *str_ImagePreFix;
@property (nonatomic, strong) NSString *str_QuestionId;
@property (nonatomic, strong) NSString *str_ExamId;
@end
