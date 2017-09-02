//
//  StarListDetailViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 8..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarListDetailViewController : UIViewController
@property (nonatomic, strong) NSString *str_SchoolGrade;
@property (nonatomic, strong) NSString *str_PersonGrade;
@property (nonatomic, strong) NSString *str_SubjectName;
@property (nonatomic, assign) NSInteger nPage;
@property (nonatomic, assign) NSInteger nTotalPage;

@property (nonatomic, strong) NSString *str_SortType;

@property (nonatomic, assign) BOOL Prev;    //콜 모드가 이전 화면인지 여부. NO면 next

@end
