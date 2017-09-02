//
//  ReportViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 30..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController
@property (nonatomic, assign) BOOL isGroupYn;
@property (nonatomic, assign) BOOL isResultYn;
@property (nonatomic, strong) NSString *str_Title;
@property (nonatomic, strong) NSString *str_UserIdx;
@property (nonatomic, strong) NSString *str_ExamId;
@end
