//
//	ReaderViewController.h
//	Reader v2.8.6
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2015 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <UIKit/UIKit.h>

#import "ReaderDocument.h"
#import "QuestionContainerViewController.h"

@class ReaderViewController;

@protocol ReaderViewControllerDelegate <NSObject>

@optional // Delegate protocols

- (void)dismissReaderViewController:(ReaderViewController *)viewController;
- (void)crop:(NSInteger)nPage;

@end

@interface ReaderViewController : UIViewController

typedef void (^CompleteBlock)(id completeResult);

@property (nonatomic, copy) CompleteBlock completeBlock;
@property (nonatomic, weak, readwrite) id <ReaderViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (nonatomic, strong) NSMutableArray *ar_Question;
@property (nonatomic, assign) BOOL isViewMode;
@property (nonatomic, weak) QuestionContainerViewController *vc_Parent;
@property (nonatomic, strong) NSDictionary *dic_ExamUserInfo;
@property (nonatomic, strong) NSString *str_QTitle;
@property (nonatomic, strong) NSMutableDictionary *dicM_Parameter;


@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_StartIdx;
@property (nonatomic, strong) NSString *str_Title;
@property (nonatomic, strong) NSString *str_SubTitle;
@property (nonatomic, strong) NSString *str_ChannelId;

@property (nonatomic, strong) NSDictionary *dic_School;
@property (nonatomic, assign) NSInteger nSchoolLevel;

@property (nonatomic, assign) NSInteger nSchoolIdx; //메인에서 들어왔을때 씀

@property (nonatomic, strong) NSString *str_Url;
@property (nonatomic, strong) NSString *str_Prefix;
@property (nonatomic, assign) NSInteger nStartPdfPage;


//오답, 별표
@property (nonatomic, strong) NSString *str_SubjectName;
@property (nonatomic, assign) BOOL isWrong;
@property (nonatomic, assign) BOOL isStar;
@property (nonatomic, strong) NSString *str_WrongTitle;
@property (nonatomic, strong) NSDictionary *dic_Resulte;
@property (nonatomic, strong) UIButton *btn_WrongCheck;
@property (nonatomic, strong) NSString *str_SubjectTotalCount;

//출처
@property (nonatomic, assign) BOOL isOwerMode;
@property (nonatomic, strong) NSString *str_BeforeIdx;
@property (nonatomic, assign) BOOL isBeforeWrong;
@property (nonatomic, assign) BOOL isBeforeStar;


//PDF에 진입하자마자 문제 점프시 사용
@property (nonatomic, strong) NSString *str_PdfPage;
@property (nonatomic, strong) NSString *str_PdfNo;

@property (nonatomic, strong) NSString *str_SortType;

- (instancetype)initWithReaderDocument:(ReaderDocument *)object;
- (void)setDocument:(ReaderDocument *)object;

@end
