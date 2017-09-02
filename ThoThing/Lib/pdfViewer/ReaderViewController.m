//
//	ReaderViewController.m
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

#import "ReaderConstants.h"
#import "ReaderViewController.h"
#import "ThumbsViewController.h"
#import "ReaderMainToolbar.h"
#import "ReaderMainPagebar.h"
#import "ReaderContentView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbQueue.h"
//#import "QuestionTypeViewController.h"
#import "UIImage+PDF.h"
#import "AwesomeMenu.h"
#import "SideMenuViewController.h"
#import "WrongSideViewController.h"

#import <MessageUI/MessageUI.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AudioView.h"
#import "PageControllerView2.h"
#import "QuestionDiscriptionViewController.h"

#import "QuestionBottomView.h"
#import "AddDiscripViewController.h"
#import "InvitationViewController.h"
#import "SharedViewController.h"
#import "QuestionListSwipeViewController.h"

#import "ReportDetailViewController.h"
#import "QuestionBottomViewController.h"
#import "ChatFeedViewController.h"

static CGFloat fBtnWidth = 35.f;
static CGFloat fBtnHeight = 35.f;
static CGFloat fLbWidth = 80.f;
static CGFloat fLbHeight = 30.f;

@interface ReaderViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate,
ReaderMainToolbarDelegate, ReaderMainPagebarDelegate, ReaderContentViewDelegate, ThumbsViewControllerDelegate, AwesomeMenuDelegate>
{
    CGFloat fOldScale;
    CGFloat fOriginalScale;
    
    NSInteger nQnaCount;  //질문 갯수
    NSInteger correctAnswerCount;   //답 갯수
    NSInteger itemCount;
    BOOL isNumberQuestion;  //객관식 여부 (객관식이면 Y, 주관식이면 N)
    NSMutableString *str_MyCorrect;    //내가 선택 또는 입력한 답
    NSInteger nTotalQCnt;   //전체 문제 수
    
    CGFloat fKeyboardHeight;
//    BOOL isAnswerNonNumberFinish;
    
    BOOL isOwerModeTmp;
    BOOL isOwerModeTmp2;
    BOOL isMoveQuestion;

}
@property (nonatomic, strong) ReaderContentView *readerVc;
@property (nonatomic, strong) AwesomeMenuItem *awesomeView;
@property (nonatomic, strong) NSDictionary *dic_CurrentQuestion;
@property (nonatomic, strong) NSDictionary *dic_CurrentPdf;
@property (nonatomic, assign) NSInteger nCurrentIdx;
@property (nonatomic, strong) NSDictionary *dic_AudioInfo;
@property (nonatomic, strong) UIView *v_Number;
@property (nonatomic, strong) SideMenuViewController *vc_SideMenuViewController;
@property (nonatomic, strong) NSDictionary *dic_ExamInfo;
//네비
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_PauseTop;
@property (nonatomic, weak) IBOutlet UIView *v_Timer;
@property (nonatomic, weak) IBOutlet UILabel *lb_QCurrentCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_QTotalCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_QTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn_Time;
@property (nonatomic, weak) IBOutlet UIButton *btn_SideMenu;
@property (nonatomic, weak) IBOutlet UILabel *lb_PauseQCurrentCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_PauseQTotalCnt;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_NaviHieght;
@property (nonatomic, weak) IBOutlet UIView *v_Navi;
@property (nonatomic, weak) IBOutlet UIImageView *iv_NaviBg;
@property (nonatomic, weak) IBOutlet UIImageView *iv_NumberBg;
@property (nonatomic, weak) IBOutlet UIImageView *iv_NumberBlackBg;
//
@property (nonatomic, weak) IBOutlet QuestionBottomView *v_Bottom;
@property (nonatomic, weak) IBOutlet UIButton *btn_Menu;
@property (nonatomic, weak) IBOutlet UIButton *btn_Star;
@property (nonatomic, weak) IBOutlet UIButton *btn_Comment;
@property (nonatomic, weak) IBOutlet UIButton *btn_Share;
@property (nonatomic, weak) IBOutlet UIButton *btn_ZoomOut;
@property (nonatomic, weak) IBOutlet UIView *v_Answer;
@property (nonatomic, weak) IBOutlet UIView *v_AnswerNonNumber;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerNonNumberBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerNonNumberCheckWidth1;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AnswerNonNumberCheckWidth2;
@property (nonatomic, weak) IBOutlet UIButton *btn_Correct;
@property (nonatomic, weak) IBOutlet UIButton *btn_MyCorrect;
@property (nonatomic, weak) IBOutlet UIView *v_Correct;
@property (nonatomic, weak) IBOutlet UIView *v_NonNumberCorrect;
@property (nonatomic, weak) IBOutlet UIView *v_Pause;
@property (nonatomic, weak) IBOutlet UIView *v_PauseTime;
@property (nonatomic, weak) IBOutlet UIButton *btn_PauseTime;
@property (nonatomic, weak) IBOutlet UILabel *lb_MultiAnswer;

@property (nonatomic, weak) IBOutlet UIView *v_AudioContainer;
@property (nonatomic, strong) AudioView *v_Audio;

@property (nonatomic, weak) IBOutlet UIImageView *iv_Star;
@property (nonatomic, weak) IBOutlet PageControllerView4 *v_PageControllerView4;
@property (nonatomic, weak) IBOutlet PageControllerView2 *v_PageControllerView2;

//주관식
@property (nonatomic, weak) IBOutlet UITextField *tf_NonNumberAnswer1;
@property (nonatomic, weak) IBOutlet UITextField *tf_NonNumberAnswer2;
@property (nonatomic, weak) IBOutlet UIImageView *iv_NonNumberStatus;
@property (nonatomic, weak) IBOutlet UILabel *lb_StringMyCorrent;
@property (nonatomic, weak) IBOutlet UILabel *lb_StringCorrent;

//오답, 별표
@property (nonatomic, strong) NSString *str_ExamId;
@property (nonatomic, strong) NSString *str_ExamTitle;
@property (nonatomic, strong) NSString *str_ExamNo;
@property (nonatomic, strong) NSString *str_ExamPage;
@property (nonatomic, weak) IBOutlet UIButton *btn_WrongTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn_Check;

//@property (nonatomic, weak) IBOutlet UIButton *btn_Letf;
//@property (nonatomic, weak) IBOutlet UIButton *btn_Right;

@property (nonatomic, strong) NSTimer *tm_Arrow;
@property (nonatomic, weak) IBOutlet UIView *v_Left;
@property (nonatomic, weak) IBOutlet UIView *v_Right;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_LeftArrowLeading;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_RightArrowTail;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TitleTail;

@property (nonatomic, weak) IBOutlet UIButton *btn_PdfNext;
@end

@implementation ReaderViewController
{
    ReaderDocument *document;
    
    UIScrollView *theScrollView;
    
    ReaderMainToolbar *mainToolbar;
    
    ReaderMainPagebar *mainPagebar;
    
    NSMutableDictionary *contentViews;
    
    UIUserInterfaceIdiom userInterfaceIdiom;
    
    NSInteger minimumPage, maximumPage;
    
    UIDocumentInteractionController *documentInteraction;
    
    UIPrintInteractionController *printInteraction;
    
    CGFloat scrollViewOutset;
    
    CGSize lastAppearSize;
    
    NSDate *lastHideTime;
    
    BOOL ignoreDidScroll;
}

#pragma mark - Constants

#define STATUS_HEIGHT 20.0f

#define TOOLBAR_HEIGHT 44.0f
#define PAGEBAR_HEIGHT 48.0f

#define SCROLLVIEW_OUTSET_SMALL 4.0f
#define SCROLLVIEW_OUTSET_LARGE 8.0f

#define TAP_AREA_SIZE 48.0f

#pragma mark - Properties

@synthesize delegate;

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationLandscapeLeft];
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - ReaderViewController methods

- (void)updateContentSize:(UIScrollView *)scrollView
{
    CGFloat contentHeight = scrollView.bounds.size.height;
    if( self.isWrong || self.isStar )
    {
        contentHeight = scrollView.bounds.size.height; // Height
        theScrollView.pagingEnabled = NO;
    }
    
    CGFloat contentWidth = (scrollView.bounds.size.width * maximumPage);
    
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    
    if( self.isWrong || self.isStar )
    {
        theScrollView.contentSize = scrollView.contentSize;
    }
}

- (void)updateContentViews:(UIScrollView *)scrollView
{
    [self updateContentSize:scrollView]; // Update content size first
    
    [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
     ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
     {
         NSInteger page = [key integerValue]; // Page number value
         
         CGRect viewRect = CGRectZero;
         viewRect.size = scrollView.bounds.size;
         
         viewRect.origin.x = (viewRect.size.width * (page - 1)); // Update X
         
         contentView.frame = CGRectInset(viewRect, scrollViewOutset, 0.0f);
     }];
    
    NSInteger page = self.currentPage; // Update scroll view offset to current page
    
    CGPoint contentOffset = CGPointMake((scrollView.bounds.size.width * (page - 1)), 0.0f);
    
    if (CGPointEqualToPoint(scrollView.contentOffset, contentOffset) == false) // Update
    {
        scrollView.contentOffset = contentOffset; // Update content offset
    }
    
    [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
    
    [mainPagebar updatePagebar]; // Update page bar
}

- (void)addContentView:(UIScrollView *)scrollView page:(NSInteger)page
{
    CGRect viewRect = CGRectZero; viewRect.size = scrollView.bounds.size;
    
    viewRect.origin.x = (viewRect.size.width * (page - 1)); viewRect = CGRectInset(viewRect, scrollViewOutset, 0.0f);
    
    NSURL *fileURL = document.fileURL; NSString *phrase = document.password; NSString *guid = document.guid; // Document properties
    //file:///Users/kimyoung-min/Library/Developer/CoreSimulator/Devices/F5EE3602-31F1-4212-9E11-E95617768402/data/Containers/Data/Application/00ED4BA8-0061-4119-B016-B4CF1E065E14/Documents/Inbox/pdf_test1-15.pdf
    
    //    NSString *str_Path = [[NSUserDefaults standardUserDefaults] objectForKey:@"pdfUrl"];
    //    document.fileURL = [NSURL URLWithString:str_Path];
    
    self.readerVc = [[ReaderContentView alloc] initWithFrame:viewRect fileURL:fileURL page:page password:phrase]; // ReaderContentView
    self.readerVc.message = self;
    [contentViews setObject:self.readerVc forKey:[NSNumber numberWithInteger:page]]; [scrollView addSubview:self.readerVc];
    
    [self.readerVc showPageThumb:fileURL page:page password:phrase guid:guid]; // Request page preview thumb
    
    //    if( self.dic_Info && self.isViewMode )
    //    {
    //        [self.readerVc updatePdfView:self.dic_Info];
    //    }
    
}

- (void)layoutContentViews:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // View width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger pageB = ((contentOffsetX + viewWidth - 1.0f) / viewWidth); // Pages
    
    NSInteger pageA = (contentOffsetX / viewWidth); pageB += 2; // Add extra pages
    
    if (pageA < minimumPage) pageA = minimumPage; if (pageB > maximumPage) pageB = maximumPage;
    
    NSRange pageRange = NSMakeRange(pageA, (pageB - pageA + 1)); // Make page range (A to B)
    
    NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];
    
    for (NSNumber *key in [contentViews allKeys]) // Enumerate content views
    {
        NSInteger page = [key integerValue]; // Page number value
        
        if ([pageSet containsIndex:page] == NO) // Remove content view
        {
            ReaderContentView *contentView = [contentViews objectForKey:key];
            
            [contentView removeFromSuperview]; [contentViews removeObjectForKey:key];
        }
        else // Visible content view - so remove it from page set
        {
            [pageSet removeIndex:page];
        }
    }
    
    NSInteger pages = pageSet.count;
    
    if (pages > 0) // We have pages to add
    {
        NSEnumerationOptions options = 0; // Default
        
        if (pages == 2) // Handle case of only two content views
        {
            if ((maximumPage > 2) && ([pageSet lastIndex] == maximumPage)) options = NSEnumerationReverse;
        }
        else if (pages == 3) // Handle three content views - show the middle one first
        {
            NSMutableIndexSet *workSet = [pageSet mutableCopy]; options = NSEnumerationReverse;
            
            [workSet removeIndex:[pageSet firstIndex]]; [workSet removeIndex:[pageSet lastIndex]];
            
            NSInteger page = [workSet firstIndex]; [pageSet removeIndex:page];
            
            [self addContentView:scrollView page:page];
        }
        
        [pageSet enumerateIndexesWithOptions:options usingBlock: // Enumerate page set
         ^(NSUInteger page, BOOL *stop)
         {
             [self addContentView:scrollView page:page];
         }];
    }
}

- (void)handleScrollViewDidEnd:(UIScrollView *)scrollView
{
    CGFloat viewWidth = scrollView.bounds.size.width; // Scroll view width
    
    CGFloat contentOffsetX = scrollView.contentOffset.x; // Content offset X
    
    NSInteger page = (contentOffsetX / viewWidth); page++; // Page number
    
    if (page != self.currentPage) // Only if on different page
    {
        self.v_AudioContainer.hidden = YES;
        self.btn_PdfNext.hidden = YES;
        
        NSNumber *key = [NSNumber numberWithInteger:self.currentPage];
        ReaderContentView *targetView = [contentViews objectForKey:key];
        UIImageView *iv_Guide = (UIImageView *)[targetView viewWithTag:2222];
        if( iv_Guide )
        {
            [iv_Guide removeFromSuperview];
        }

        self.currentPage = page;
        document.pageNumber = [NSNumber numberWithInteger:page];

        [self answerViewDown];
        [self localDataLoad];
        
        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }];
        
        [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
}

- (void)answerViewDown
{
    [self goAnswerClose:nil];
}

- (void)showDocumentPage:(NSInteger)page
{
    NSLog(@"self.currentPage: %ld", self.currentPage);
    
    if (page != self.currentPage) // Only if on different page
    {
        if ((page < minimumPage) || (page > maximumPage))
        {
            return;
        }
        
        self.currentPage = page;
        document.pageNumber = [NSNumber numberWithInteger:page];
        
        CGPoint contentOffset = CGPointMake((theScrollView.bounds.size.width * (page - 1)), 0.0f);
        
        if (CGPointEqualToPoint(theScrollView.contentOffset, contentOffset) == true)
        {
            [self layoutContentViews:theScrollView];
        }
        else
        {
            [theScrollView setContentOffset:contentOffset];
        }
        
        [self answerViewDown];
        [self localDataLoad];

        [contentViews enumerateKeysAndObjectsUsingBlock: // Enumerate content views
         ^(NSNumber *key, ReaderContentView *contentView, BOOL *stop)
         {
             if ([key integerValue] != page) [contentView zoomResetAnimated:NO];
         }
         ];
        
        [mainToolbar setBookmarkState:[document.bookmarks containsIndex:page]];
        
        [mainPagebar updatePagebar]; // Update page bar
    }
    
    NSNumber *key = [NSNumber numberWithInteger:self.currentPage];
    ReaderContentView *targetView = [contentViews objectForKey:key];
    targetView.isWrong = (self.isWrong || self.isStar );
    targetView.message = self;
    fOriginalScale = targetView.zoomScale;
    
    if( self.isWrong || self.isStar )
    {
        if( self.dic_AudioInfo )
        {
            targetView.isAudio = YES;
            [targetView setAudioFrame];
            [self updateQuestionStatusWithUpdateCount:NO];
            [targetView updatePdfScroll];
        }
    }
    
    NSLog(@"pdf load finish");
}

- (void)localDataLoad
{
    NSString *str_NormalQKey = [NSString stringWithFormat:@"PdfQuestion_%@",
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    
    NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
    NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
    
    NSString *str_Key = [NSString stringWithFormat:@"%ld_%ld",
                         [[self.dicM_Parameter objectForKey:@"examId"] integerValue],
                         self.currentPage];
    NSDictionary *resulte = [dicM_NormalQ objectForKey:str_Key];
    
    if( resulte )
    {
        NSString *str_NormalQKey = [NSString stringWithFormat:@"PdfQuestion_%@",
                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        
        NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
        NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
        [dicM_NormalQ setObject:resulte forKey:str_Key];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM_NormalQ];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        self.dic_ExamInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examPackageInfo"]];
        NSDictionary *dic_ExamPackageInfo = [resulte objectForKey:@"examPackageInfo"];
        nTotalQCnt = [[dic_ExamPackageInfo objectForKey:@"questionCount"] integerValue];
        self.ar_Question = [resulte objectForKey:@"questionInfos"];
        [self updateQuestionStatusWithUpdateCount:YES];
        
        if( self.ar_Question.count > 0 )
        {
            NSDictionary *dic = [self.ar_Question firstObject];
            NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
            if( ar_Tmp.count > 0 )
            {
                NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                
                CGFloat fWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
                CGFloat fScale = (self.view.bounds.size.width) / fWidth;
                CGFloat fStartX = [[dic_PdfInfo objectForKey:@"startX"] floatValue];
                NSLog(@"fStartX :%f, scale: %f", fStartX, fScale);
                
                CGFloat fOriginalStartx = fStartX * fScale;
                CGFloat fPdfWidth = [[dic_PdfInfo objectForKey:@"pdfWidth"] floatValue];
                
                //                                                    CGFloat fXper = (fPdfWidth / fOriginalStartx) * 0.01;
                CGFloat fXper = fOriginalStartx/ fPdfWidth;
                
                
                NSNumber *key = [NSNumber numberWithInteger:self.currentPage]; // Page number key
                
                ReaderContentView *targetView = [contentViews objectForKey:key]; // View
                
                [UIView animateWithDuration:0.3f animations:^{
                    
                    targetView.zoomScale = targetView.minimumZoomScale + (targetView.minimumZoomScale * (fXper * 2));
                }];
            }
        }
        
        if( self.dic_CurrentQuestion )
        {
            for( NSInteger i = 0; i < self.ar_Question.count; i++ )
            {
                NSInteger nNowId = [[self.dic_CurrentQuestion objectForKey:@"questionId"] integerValue];
                NSDictionary *dic = self.ar_Question[i];
                NSInteger nId = [[dic objectForKey:@"questionId"] integerValue];
                
                if( nNowId == nId )
                {
                    self.dic_CurrentQuestion = [NSDictionary dictionaryWithDictionary:dic];
                }
            }
        }
        
        if( isOwerModeTmp )
        {
            isOwerModeTmp = NO;
            for( NSInteger i = 0; i < self.ar_Question.count; i++ )
            {
                NSDictionary *dic = [self.ar_Question objectAtIndex:i];
                NSInteger nExamNoTmp = [[dic objectForKey:@"examNo"] integerValue];
                if( nExamNoTmp == [self.str_StartIdx integerValue] )
                {
                    self.dic_CurrentQuestion = [NSDictionary dictionaryWithDictionary:dic];
                    NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
                    //                                                        if( ar_Tmp.count <= 0 ) return;
                    NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                    [self showZoom:self.dic_CurrentQuestion withPdfInfo:dic_PdfInfo];
                    break;
                }
            }
        }
        
//        if( isMoveQuestion )
//        {
//            //화살표로 다음 문제 넘어갈때
//            isMoveQuestion = NO;
//            
//            NSDictionary *dic = [self.ar_Question firstObject];
//            NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
//            NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
//            [self showZoom:self.dic_CurrentQuestion withPdfInfo:dic_PdfInfo];
//        }
    }
    else
    {
        [self updateListWithFit:YES];
    }
}

- (void)onMoveToQuestion
{
    [self.readerVc updatePdfView:self.dic_Info];
}

- (void)showDocument
{
    [self updateContentSize:theScrollView]; // Update content size first
    
    if( self.dic_Info )
    {
        NSInteger nPage = [[self.dic_Info objectForKey:@"questionPage"] integerValue];
        [self showDocumentPage:nPage]; // Show page
    }
    else if( self.nStartPdfPage > 0 )
    {
        [self showDocumentPage:self.nStartPdfPage]; // Show page
    }
    else if( self.isOwerMode )
    {
        NSInteger nPage = [self.str_ExamPage integerValue];
//        self.currentPage = nPage;
        [self showDocumentPage:nPage];
    }
    else
    {
        [self showDocumentPage:[document.pageNumber integerValue]]; // Show page
    }
    
    
    document.lastOpen = [NSDate date]; // Update document last opened date
}

- (void)closeDocument
{
    if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    [document archiveDocumentProperties]; // Save any ReaderDocument changes
    
    [[ReaderThumbQueue sharedInstance] cancelOperationsWithGUID:document.guid];
    
    [[ReaderThumbCache sharedInstance] removeAllObjects]; // Empty the thumb cache
    
    if ([delegate respondsToSelector:@selector(dismissReaderViewController:)] == YES)
    {
        [delegate dismissReaderViewController:self]; // Dismiss the ReaderViewController
    }
    else // We have a "Delegate must respond to -dismissReaderViewController:" error
    {
        NSAssert(NO, @"Delegate must respond to -dismissReaderViewController:");
    }
}

#pragma mark - UIViewController methods

- (instancetype)initWithReaderDocument:(ReaderDocument *)object
{
    if ((self = [super initWithNibName:nil bundle:nil])) // Initialize superclass
    {
        if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]])) // Valid object
        {
            userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];
            
            [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
            
            scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);
            
            [object updateDocumentProperties]; document = object; // Retain the supplied ReaderDocument object for our use
            
            [ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
        }
        else // Invalid ReaderDocument object
        {
            self = nil;
        }
    }
    
    return self;
}

- (void)setDocument:(ReaderDocument *)object
{
    if ((object != nil) && ([object isKindOfClass:[ReaderDocument class]])) // Valid object
    {
        userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom; // User interface idiom
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter]; // Default notification center
        
        [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillTerminateNotification object:nil];
        
        [notificationCenter addObserver:self selector:@selector(applicationWillResign:) name:UIApplicationWillResignActiveNotification object:nil];
        
        scrollViewOutset = ((userInterfaceIdiom == UIUserInterfaceIdiomPad) ? SCROLLVIEW_OUTSET_LARGE : SCROLLVIEW_OUTSET_SMALL);
        
        [object updateDocumentProperties]; document = object; // Retain the supplied ReaderDocument object for our use
        
        [ReaderThumbCache touchThumbCacheWithGUID:object.guid]; // Touch the document thumb cache directory
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onAddQuestion:(UIButton *)btn
{
    NSString *str_Path = [[NSUserDefaults standardUserDefaults] objectForKey:@"pdfUrl"];
    
    ReaderDocument *document = [ReaderDocument withDocumentFilePath:str_Path password:nil withLocalPdf:YES];
    if( [str_Path hasPrefix:@"http"] == NO )
    {
        document.isLocalPDf = YES;
    }
    
    ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
    
    readerViewController.delegate = self; // Set the ReaderViewController delegate to self
    
    readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:readerViewController animated:YES completion:NULL];
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)onHideArrow
{
    [self.tm_Arrow invalidate];
    self.tm_Arrow = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.lc_LeftArrowLeading.constant = -60.f;
        self.lc_RightArrowTail.constant = -60.f;
        [self.view layoutIfNeeded];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [MBProgressHUD hide];
    
    NSLog(@"start page : %ld", self.nStartPdfPage);

    //기본 로딩바랑 겹쳐서 안이뻐 보여서 빼버림
//    if( self.isWrong == NO && self.isStar == NO )
//    {
//        [SVProgressHUD showWithStatus:@"PDF 로드중..."];
//    }

    
    isOwerModeTmp = self.isOwerMode;
    isOwerModeTmp2 = self.isOwerMode;

    if( self.isWrong || self.isStar )
    {
        self.btn_PdfNext.hidden = YES;
        
        NSArray *ar_Tmp = [self.dic_Resulte objectForKey:@"questionInfos"];
        if( ar_Tmp.count > 0 )
        {
            NSDictionary *dic_Tmp = [ar_Tmp objectAtIndex:0];
            self.str_ExamId = [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"examId"]];
            self.str_ExamTitle = [dic_Tmp objectForKey_YM:@"examTitle"];
            self.str_ExamNo = [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"examNo"]];
            self.str_ExamPage = [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"questionPage"]];
        }

        
        self.v_Timer.hidden = YES;
        self.lb_QTitle.hidden = YES;
        self.btn_Check.hidden = YES;
        self.btn_WrongTitle.hidden = NO;
        self.v_Left.hidden = self.v_Right.hidden = NO;
        self.v_Left.layer.cornerRadius = self.v_Right.layer.cornerRadius = 8.f;

        [self.btn_WrongTitle setTitle:self.str_WrongTitle forState:UIControlStateNormal];
        self.btn_WrongTitle.userInteractionEnabled = YES;
        
        self.tm_Arrow = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(onHideArrow) userInfo:nil repeats:NO];

        if( self.isWrong )
        {
            [self.btn_WrongTitle setTitle:@" 오답 리스트에서 삭제" forState:UIControlStateNormal];
            [self.btn_WrongTitle setTitle:@" 오답 리스트에서 삭제됨" forState:UIControlStateSelected];
            
//            [self.btn_Check setImage:BundleImage(@"wrong_check_no_select.png") forState:UIControlStateNormal];
//            [self.btn_Check setImage:BundleImage(@"wrong_check_select.png") forState:UIControlStateSelected];
        }
        else
        {
            [self.btn_WrongTitle setTitle:@" 별표 리스트에서 삭제" forState:UIControlStateNormal];
            [self.btn_WrongTitle setTitle:@" 별표 리스트에서 삭제됨" forState:UIControlStateSelected];

//            [self.btn_Check setImage:BundleImage(@"star_fill.png") forState:UIControlStateNormal];
//            [self.btn_Check setImage:BundleImage(@"star_empty.png") forState:UIControlStateSelected];
        }
    }
    else if( self.isOwerMode )
    {
        self.btn_PdfNext.hidden = NO;

        self.lc_TitleTail.constant = (self.view.bounds.size.width - 250) * -1;
        self.v_Timer.hidden = YES;
        self.btn_Time.hidden = YES;
        self.btn_Check.hidden = YES;
        self.v_Left.hidden = self.v_Right.hidden = YES;
//        self.lb_QTitle.backgroundColor = [UIColor redColor];
    }
    else
    {
        self.btn_PdfNext.hidden = NO;
        
        self.lc_TitleTail.constant = 10;
        self.v_Timer.hidden = NO;
        self.btn_Time.hidden = NO;

        self.v_Left.hidden = self.v_Right.hidden = YES;
        self.btn_WrongTitle.hidden = self.btn_Check.hidden = YES;
    }
    
    
    if( self.isViewMode )
    {
        [self initNaviWithTitle:@"문제풀기" withLeftItem:[self leftBackMenuBarButtonItem] withRightItem:[self addQuestion]];
        //        [self initNaviWithTitle:@"문제풀기" withLeftItem:[self leftBackMenuBarButtonItem] withRightItem:nil];
        self.navigationController.navigationBarHidden = NO;
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
    }
    
//    self.btn_MyCorrect.layer.borderColor = [UIColor blackColor].CGColor;
//    self.btn_MyCorrect.layer.borderWidth = 1.f;
//    [self.btn_MyCorrect setBackgroundColor:[UIColor redColor]];
//    [self.btn_MyCorrect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.tf_NonNumberAnswer1.layer.cornerRadius = self.tf_NonNumberAnswer2.layer.cornerRadius = 5.f;
    self.tf_NonNumberAnswer1.layer.borderWidth = self.tf_NonNumberAnswer2.layer.borderWidth = 1.f;
    self.tf_NonNumberAnswer1.layer.borderColor = self.tf_NonNumberAnswer2.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
    
    [self.tf_NonNumberAnswer1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.tf_NonNumberAnswer2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.tf_NonNumberAnswer1 setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_NonNumberAnswer1.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_NonNumberAnswer1.frame.size.height)];

    [self.tf_NonNumberAnswer2 setLeftViewMode:UITextFieldViewModeAlways];
    self.tf_NonNumberAnswer2.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, self.tf_NonNumberAnswer2.frame.size.height)];

    self.iv_NonNumberStatus.layer.cornerRadius = 4.f;
    self.iv_NonNumberStatus.layer.borderWidth = 1.f;
    self.iv_NonNumberStatus.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.lc_AnswerNonNumberBottom.constant = -164.f;
    self.lc_AnswerBottom.constant = -164.f;
    
    assert(document != nil); // Must have a valid ReaderDocument
    
    self.lb_QTitle.text = self.str_QTitle;
    self.lb_QCurrentCnt.text = self.lb_PauseQCurrentCnt.text = @"0";
    self.lb_QTotalCnt.text = self.lb_PauseQTotalCnt.text = @"0";
    
    self.view.backgroundColor = [UIColor grayColor]; // Neutral gray
    
    UIView *fakeStatusBar = nil; CGRect viewRect = self.view.bounds; // View bounds
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) // iOS 7+
    {
        if ([self prefersStatusBarHidden] == NO) // Visible status bar
        {
            CGRect statusBarRect = viewRect; statusBarRect.size.height = STATUS_HEIGHT;
            fakeStatusBar = [[UIView alloc] initWithFrame:statusBarRect]; // UIView
            fakeStatusBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            fakeStatusBar.backgroundColor = [UIColor blackColor];
            fakeStatusBar.contentMode = UIViewContentModeRedraw;
            fakeStatusBar.userInteractionEnabled = NO;
            
            viewRect.origin.y += STATUS_HEIGHT; viewRect.size.height -= STATUS_HEIGHT;
        }
    }
    
    //	CGRect scrollViewRect = CGRectInset(viewRect, -scrollViewOutset, 0.0f);
    if( self.isWrong || self.isStar )
    {
        theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 164)]; // All
        theScrollView.clipsToBounds = NO;
        theScrollView.autoresizesSubviews = NO;
        theScrollView.contentMode = UIViewContentModeRedraw;
        theScrollView.showsHorizontalScrollIndicator = NO;
        theScrollView.showsVerticalScrollIndicator = NO;
        theScrollView.scrollsToTop = YES;
        theScrollView.delaysContentTouches = NO;
        theScrollView.pagingEnabled = NO;
        theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        theScrollView.backgroundColor = [UIColor clearColor];
        theScrollView.delegate = self;
    }
    else
    {
        theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)]; // All
        theScrollView.autoresizesSubviews = NO;
        theScrollView.contentMode = UIViewContentModeRedraw;
        theScrollView.showsHorizontalScrollIndicator = NO;
        theScrollView.showsVerticalScrollIndicator = NO;
        theScrollView.scrollsToTop = NO;
        theScrollView.delaysContentTouches = NO;
        theScrollView.pagingEnabled = YES;
        theScrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        theScrollView.backgroundColor = [UIColor clearColor];
        theScrollView.delegate = self;
    }
    
    [self.view addSubview:theScrollView];
    //    theScrollView.backgroundColor = [UIColor redColor];
    
    //	CGRect toolbarRect = viewRect; toolbarRect.size.height = TOOLBAR_HEIGHT;
    //	mainToolbar = [[ReaderMainToolbar alloc] initWithFrame:toolbarRect document:document]; // ReaderMainToolbar
    //	mainToolbar.delegate = self; // ReaderMainToolbarDelegate
    //
    //    if( self.isViewMode == NO )
    //    {
    //        [self.view addSubview:mainToolbar];
    //    }
    
    CGRect pagebarRect = self.view.bounds; pagebarRect.size.height = PAGEBAR_HEIGHT;
    pagebarRect.origin.y = (self.view.bounds.size.height - pagebarRect.size.height);
    mainPagebar = [[ReaderMainPagebar alloc] initWithFrame:pagebarRect document:document]; // ReaderMainPagebar
    mainPagebar.delegate = self; // ReaderMainPagebarDelegate
    if( self.isViewMode == NO )
    {
        [self.view addSubview:mainPagebar];
    }
    
    if (fakeStatusBar != nil) [self.view addSubview:fakeStatusBar]; // Add status bar background view
    
    UITapGestureRecognizer *singleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapOne.numberOfTouchesRequired = 1; singleTapOne.numberOfTapsRequired = 1; singleTapOne.delegate = self;
    [self.view addGestureRecognizer:singleTapOne];
    
    UITapGestureRecognizer *doubleTapOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapOne.numberOfTouchesRequired = 1; doubleTapOne.numberOfTapsRequired = 2; doubleTapOne.delegate = self;
    [self.view addGestureRecognizer:doubleTapOne];
    
    UITapGestureRecognizer *doubleTapTwo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapTwo.numberOfTouchesRequired = 2; doubleTapTwo.numberOfTapsRequired = 2; doubleTapTwo.delegate = self;
    [self.view addGestureRecognizer:doubleTapTwo];
    
    [singleTapOne requireGestureRecognizerToFail:doubleTapOne]; // Single tap requires double tap to fail
    
    contentViews = [NSMutableDictionary new]; lastHideTime = [NSDate date];
    
    minimumPage = 1; maximumPage = [document.pageCount integerValue];
    
    self.v_Bottom.alpha = self.v_Answer.alpha = self.v_AnswerNonNumber.alpha = self.v_AudioContainer.alpha = NO;
    self.v_Bottom.str_ChannelId = self.str_ChannelId;
    self.v_Bottom.str_ExamId = self.str_Idx;
    
    [self.v_Bottom setUpdateCountBlock:^(id completeResult) {
        
//        [self.btn_Comment setTitle:[NSString stringWithFormat:@"질문 %@", completeResult] forState:UIControlStateNormal];
        NSString *str_DCount = [completeResult objectForKey:@"dCount"];
        NSString *str_QCount = [completeResult objectForKey:@"qCount"];
        nQnaCount = [str_DCount integerValue] + [str_QCount integerValue];
        [self.btn_Comment setTitle:[NSString stringWithFormat:@"풀이 %ld", nQnaCount] forState:UIControlStateNormal];
    }];
    [self.v_Bottom setAddCompletionBlock:^(id completeResult) {
       
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
        [vc setDismissBlock:^(id completeResult) {
           
            self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
            [self.v_Bottom updateDList];
            [self.v_Bottom updateQList];
        }];
        vc.str_Idx = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [self.v_Bottom setCompletionBlock:^(id completeResult) {

        CGFloat fAlpha = [[completeResult objectForKey:@"alpha"] floatValue];
        self.btn_Menu.alpha = fAlpha;
        self.btn_Star.alpha = fAlpha;
        self.btn_Share.alpha = fAlpha;
        self.btn_ZoomOut.alpha = fAlpha;
        self.btn_PdfNext.alpha = fAlpha;
        
        id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
        NSString *str_UserCorrect = [self.dic_CurrentQuestion objectForKey_YM:@"user_correct"];
        if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
        {
            //안푼문제
            if( [[completeResult objectForKey:@"IsTop"] boolValue] == NO )
            {
                if( isNumberQuestion )
                {
                    self.v_Correct.hidden = NO;
                    self.v_NonNumberCorrect.hidden = YES;
//                    self.lb_StringCorrent.hidden = YES;
                    self.btn_MyCorrect.hidden = YES;
                    [self.btn_Correct setTitle:[self.dic_CurrentQuestion objectForKey:@"correctAnswer"] forState:UIControlStateNormal];
                    
                    self.v_Correct.alpha = 1 - fAlpha;
                }
                else
                {
                    self.v_Correct.hidden = YES;
                    self.v_NonNumberCorrect.hidden = NO;
//                    self.lb_StringCorrent.hidden = NO;
//                    self.lb_StringMyCorrent.hidden = YES;
//                    self.lb_StringCorrent.alpha = 1 - fAlpha;
//                    self.lb_StringMyCorrent.alpha = 1 - fAlpha;
                    
                    self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                }
            }
        }
        else
        {
            //푼 문제
            if( isNumberQuestion )
            {
                self.v_Correct.hidden = NO;
                self.v_NonNumberCorrect.hidden = YES;
//                self.lb_StringCorrent.hidden = NO;
//                self.lb_StringMyCorrent.hidden = NO;
                //            self.btn_MyCorrect.hidden = YES;
                [self.btn_Correct setTitle:[self.dic_CurrentQuestion objectForKey:@"correctAnswer"] forState:UIControlStateNormal];
                [self.btn_MyCorrect setTitle:[self.dic_CurrentQuestion objectForKey:@"user_correct"] forState:UIControlStateNormal];
            }
            else
            {
                self.v_Correct.hidden = YES;
                self.v_NonNumberCorrect.hidden = NO;
                
                self.lb_StringCorrent.hidden = NO;
                self.lb_StringMyCorrent.hidden = NO;
                
                self.lb_StringCorrent.text = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                self.lb_StringMyCorrent.text = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                
                if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
                {
                    //맞은 문제는 내 정답 표시하지 않는다
//                    self.lb_StringMyCorrent.text = @"";
                }
            }
        }
        
        if( [[completeResult objectForKey:@"IsTop"] boolValue] == YES )
        {
            self.v_Correct.hidden = YES;
            self.v_NonNumberCorrect.hidden = YES;
//            self.lb_StringCorrent.hidden = YES;
//            self.lb_StringMyCorrent.hidden = YES;
        }
//        else
//        {
//            self.v_Correct.alpha = fAlpha;
//            self.lb_StringCorrent.alpha = fAlpha;
//            self.lb_StringMyCorrent.alpha = fAlpha;
//        }
        
        //안푼 문제
//        NSLog(@"%@", completeResult);
//        self.completionBlock(@{@"point" : [NSNumber numberWithFloat:self.frame.origin.y], @"animation" : @YES});

    }];
    [self.view endEditing:YES];
    [self stopAudio];
    
    self.v_Timer.layer.cornerRadius = 20.f;
    self.v_Timer.layer.borderWidth = 1.f;
    self.v_Timer.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContentsDidScroll:) name:@"contentsDidScroll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTimer:) name:@"updateTimer" object:nil];
    [self.btn_Time setTitle:@"00:00" forState:UIControlStateNormal];
    [self.btn_PauseTime setTitle:@"00:00" forState:UIControlStateNormal];
    
    self.btn_Correct.layer.cornerRadius = self.btn_Correct.frame.size.width / 2;
    self.btn_Correct.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    self.btn_Correct.layer.borderWidth = 1.f;
    
    [self.btn_Correct setBackgroundColor:[UIColor whiteColor]];
    [self.btn_Correct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.btn_MyCorrect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
    self.btn_MyCorrect.layer.cornerRadius = self.btn_MyCorrect.frame.size.width / 2;
    self.btn_MyCorrect.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btn_MyCorrect.layer.borderWidth = 1.f;
    
    self.v_PauseTime.layer.cornerRadius = 20.f;
    self.v_PauseTime.layer.borderWidth = 1.f;
    self.v_PauseTime.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.lb_StringCorrent.layer.borderWidth = 1.f;
    self.lb_StringCorrent.layer.borderColor = [UIColor lightGrayColor].CGColor;

    self.lb_StringCorrent.layer.borderWidth = 1.f;
    self.lb_StringMyCorrent.layer.borderColor = [UIColor whiteColor].CGColor;

    if( self.str_PdfPage && self.str_PdfNo )
    {
        //문제 공유시 해당 문제로 이동하는 코드
//        [MBProgressHUD show];
        MBProgressHUD * hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeYM;
        hud.labelText = @"문제로 이동중...";
//        [MBProgressHUD hideHUDForView:self.view animated:YES];

        [self performSelector:@selector(onShareMoveToQuestion) withObject:nil afterDelay:2.0f];
    }
}

- (IBAction)goShowComment2:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Question" bundle:nil];
    
    QuestionBottomViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionBottomViewController"];
    vc.str_QId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = self.str_ExamId;
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }
    vc.str_ChannelId = self.str_ChannelId;
    vc.nTotalCount = nQnaCount;
    
    [vc setUpdateCountBlock:^(id completeResult) {
        
        //        [self.btn_Comment setTitle:[NSString stringWithFormat:@"풀이와 질문 %@", completeResult] forState:UIControlStateNormal];
        
        NSString *str_DCount = [completeResult objectForKey:@"dCount"];
        NSString *str_QCount = [completeResult objectForKey:@"qCount"];
        nQnaCount = [str_DCount integerValue] + [str_QCount integerValue];
        [self.btn_Comment setTitle:[NSString stringWithFormat:@"풀이 %ld", nQnaCount] forState:UIControlStateNormal];
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
        self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1;
    }];
}

- (void)onShareMoveToQuestion
{
//    NSInteger nExamNo = [[dic objectForKey:@"examNo"] integerValue];
//    NSInteger nPdfPage = [[completeResult objectForKey:@"pdfPage"] integerValue];
    NSInteger nExamNo = [self.str_PdfNo integerValue];
    NSInteger nPdfPage = [self.str_PdfPage integerValue];
    
    [self showDocumentPage:nPdfPage];
    
    [self.dicM_Parameter setObject:[NSString stringWithFormat:@"%ld", self.currentPage] forKey:@"pdfPage"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                        param:self.dicM_Parameter
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        
                                        if( resulte )
                                        {
                                            self.ar_Question = [resulte objectForKey:@"questionInfos"];
                                            [self updateQuestionStatusWithUpdateCount:NO];
                                            
                                            for( NSInteger i = 0; i < self.ar_Question.count; i++ )
                                            {
                                                NSDictionary *dic_Sub = self.ar_Question[i];
                                                NSInteger nCurrentExamNo = [[dic_Sub objectForKey:@"examNo"] integerValue];
                                                
                                                NSArray *ar_Tmp = [dic_Sub objectForKey:@"examQuestionInfos"];
                                                if( ar_Tmp.count <= 0 ) return;
                                                
                                                NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                                                if( nExamNo == nCurrentExamNo )
                                                {
                                                    [self performSelector:@selector(onShowZoomInterval:) withObject:@{@"dic_Sub":dic_Sub, @"dic_PdfInfo":dic_PdfInfo} afterDelay:0.3f];
                                                    break;
                                                }
                                            }
                                        }
                                    }];
}

//- (void)viewDidLayoutSubviews
//{
//    CGRect frame = self.btn_Correct.frame;
//    frame.origin.x = -20;
//    frame.size.width = 50;
//    self.btn_Correct.frame = frame;
//
//    frame = self.btn_MyCorrect.frame;
//    frame.origin.x = 15;
//    frame.size.width = 50;
//    self.btn_MyCorrect.frame = frame;
//}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    if( isAnswerNonNumberFinish )
//    {
//        return NO;
//    }
//    
//    return YES;
//}

- (void)textFieldDidChange:(UITextField *)tf
{
    if( tf.text.length > 0 )
    {
        self.lc_AnswerNonNumberCheckWidth1.constant = 63.f;
        self.iv_NonNumberStatus.backgroundColor = [UIColor darkGrayColor];
    }
    else
    {
        self.lc_AnswerNonNumberCheckWidth1.constant = 0.f;
        self.iv_NonNumberStatus.backgroundColor = [UIColor whiteColor];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField.text.length > 0 )
    {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];

        if( self.isWrong || self.isStar )
        {
            [self onShowResult:dic];
        }
        else
        {
            [self sendCorrect:dic];
        }
    }
    
    return YES;
}



#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    fKeyboardHeight = keyboardBounds.size.height;
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            if( self.btn_Star.alpha == YES )
            {
                self.lc_AnswerNonNumberBottom.constant = keyboardBounds.size.height;
            }
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            if( self.btn_Star.alpha == YES )
            {
                self.lc_AnswerNonNumberBottom.constant = -164.f;
            }
        }
    }completion:^(BOOL finished) {
        
    }];
}

- (void)updateQuestionStatusWithUpdateCount:(BOOL)isUpdate
{
    if( self.ar_Question.count >= 2 && isUpdate )
    {
        NSDictionary *dic_First = [self.ar_Question firstObject];
        NSDictionary *dic_Last = [self.ar_Question lastObject];
        
        if( self.isWrong == NO && self.isStar == NO )
        {
            self.lb_QCurrentCnt.text = self.lb_PauseQCurrentCnt.text = [NSString stringWithFormat:@"%@ ~ %@", [dic_First objectForKey:@"examNo"], [dic_Last objectForKey:@"examNo"]];
            self.lb_QTotalCnt.text = self.lb_PauseQTotalCnt.text = [NSString stringWithFormat:@"%ld", nTotalQCnt];
        }
    }
    
//    CGFloat fBtnWidth = 35.f;
//    CGFloat fBtnHeight = 35.f;
    
    //맞은문제, 틀린문제, 별표한문제 표현
    for( NSInteger i = 0; i < self.ar_Question.count; i++ )
    {
        NSDictionary *dic = self.ar_Question[i];
        
        
        NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
        if( ar_Tmp.count <= 0 ) continue;
        
        NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
        
        NSNumber *key = [NSNumber numberWithInteger:self.currentPage];
        ReaderContentView *targetView = [contentViews objectForKey:key];
        targetView.isWrong = (self.isWrong || self.isStar );

        CGFloat fWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
        CGFloat fHeight = [[dic_PdfInfo objectForKey:@"height"] floatValue];
        
        CGFloat fStartX = [[dic_PdfInfo objectForKey:@"startX"] floatValue];
        CGFloat fStartY = [[dic_PdfInfo objectForKey:@"startY"] floatValue];
        
        if( self.isWrong || self.isStar )
        {
            CGFloat fStartX2 = 180;//[[dic_PdfInfo objectForKey:@"startX"] floatValue];
            CGFloat fStartY2 = 47;//[[dic_PdfInfo objectForKey:@"startY"] floatValue];
            
            if( self.dic_AudioInfo )
            {
                fStartY2 = 47 + 60;
            }
            
            UIButton *tmp = (UIButton *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 1111];
            UIButton *btn_Owner = nil;
            if( tmp == nil )
            {
                CGFloat fBtnWidth = 300.f;
                
                btn_Owner = [UIButton buttonWithType:UIButtonTypeCustom];
                btn_Owner.userInteractionEnabled = YES;
//                btn_Owner.backgroundColor = [UIColor redColor];
//                btn_Owner.frame = CGRectMake(150, 150, 300, 50);
                btn_Owner.frame = CGRectMake( 0,
//                btn_Owner.frame = CGRectMake( 0,
                                             (fStartY2 * targetView.zoomScale) + (fHeight * targetView.zoomScale) - ((fBtnHeight + 16) * targetView.zoomScale),
//                                             fBtnWidth * targetView.zoomScale,
                                             targetView.frame.size.width,
                                             fBtnHeight * targetView.zoomScale);
                [btn_Owner.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12.f * (btn_Owner.frame.size.width / fBtnWidth)]];
                [btn_Owner setTitleColor:kMainColor forState:UIControlStateNormal];
                btn_Owner.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                btn_Owner.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                
                NSString *str_Title = [NSString stringWithFormat:@"출처:%@(%@번)", self.str_ExamTitle, self.str_ExamNo];
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str_Title];
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 3)];
                [attributedString addAttribute:NSForegroundColorAttributeName value:kMainColor range:NSMakeRange(3, str_Title.length - 3)];
                [btn_Owner setAttributedTitle:attributedString forState:UIControlStateNormal];
                [btn_Owner addTarget:self action:@selector(onOwerTouch:) forControlEvents:UIControlEventTouchUpInside];
                
//                [btn_Owner setBackgroundColor:[UIColor redColor]];
//                btn_Owner.layer.cornerRadius = btn_Owner.frame.size.width/2;
//                btn_Owner.layer.borderColor = [UIColor redColor].CGColor;
//                btn_Owner.layer.borderWidth = 1.f;
            }
            else
            {
                btn_Owner = tmp;
            }
            
            btn_Owner.alpha = NO;

            btn_Owner.tag = [[dic objectForKey:@"questionId"] integerValue] + 1111;
            [targetView addSubview:btn_Owner];

            targetView.ar_Guide = self.ar_Question;
            
            [UIView animateWithDuration:0.7f animations:^{
                btn_Owner.alpha = YES;
            }completion:^(BOOL finished) {
                
            }];
            
            continue;
        }

        id userCorrect = [dic objectForKey:@"user_correct"];
        NSString *str_UserCorrect = [dic objectForKey_YM:@"user_correct"];
        if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
        {
            //안푼문제
            continue;
        }
        else
        {
            //푼 문제
            NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_correct"]];
            
            //정답
            NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
            str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            BOOL isNumberQustion = [[dic objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
            if( isNumberQustion == NO )
            {
//                CGFloat fLbWidth = 80.f;
//                CGFloat fLbHeight = 30.f;

                //정답표현
                UILabel *tmp = (UILabel *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 900];
                UILabel *lb_SubCorrect = nil;
                if( tmp == nil )
                {
                    lb_SubCorrect = [[UILabel alloc] init];
                    lb_SubCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fLbWidth + 24) * targetView.zoomScale) ,
                                                     (fStartY * targetView.zoomScale) + (fHeight * targetView.zoomScale) - ((fLbHeight + 6) * targetView.zoomScale),
                                                     fLbWidth * targetView.zoomScale,
                                                     fLbHeight * targetView.zoomScale);
                    lb_SubCorrect.textAlignment = NSTextAlignmentCenter;
                    lb_SubCorrect.textColor = [UIColor blackColor];
                    lb_SubCorrect.backgroundColor = [UIColor whiteColor];
                    lb_SubCorrect.text = str_Correct;
                    
                }
                else
                {
                    lb_SubCorrect = tmp;
                }
                
                lb_SubCorrect.layer.borderColor = [UIColor lightGrayColor].CGColor;
                lb_SubCorrect.layer.borderWidth = 1.f;

                lb_SubCorrect.tag = [[dic objectForKey:@"questionId"] integerValue] + 900;
                [targetView addSubview:lb_SubCorrect];

                if( [str_UserCorrect isEqualToString:str_Correct] )
                {
                    //맞은 문제
                    UILabel *tmp = (UILabel *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 9000];
                    UILabel *lb_SubMyCorrect = nil;
                    if( tmp == nil )
                    {
                        lb_SubMyCorrect = [[UILabel alloc] init];
                        lb_SubMyCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fLbWidth + 24) * targetView.zoomScale) ,
                                                           lb_SubCorrect.frame.origin.y - (fLbHeight * targetView.zoomScale),
                                                           fLbWidth * targetView.zoomScale,
                                                           fLbHeight * targetView.zoomScale);
                        lb_SubMyCorrect.font = [UIFont fontWithName:@"Helvetica" size:14];
                        lb_SubMyCorrect.numberOfLines = 2;
                        lb_SubMyCorrect.textAlignment = NSTextAlignmentCenter;
                        lb_SubMyCorrect.textColor = [UIColor whiteColor];
                        lb_SubMyCorrect.text = str_UserCorrect;
                    }
                    else
                    {
                        lb_SubMyCorrect = tmp;
                    }
                    
//                    lb_SubMyCorrect.layer.borderColor = [UIColor whiteColor].CGColor;
//                    lb_SubMyCorrect.layer.borderWidth = 1.f;
                    lb_SubMyCorrect.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
                    
                    lb_SubMyCorrect.tag = [[dic objectForKey:@"questionId"] integerValue] + 9000;
                    [targetView addSubview:lb_SubMyCorrect];
                }
                else
                {
                    //틀린문제
                    UILabel *tmp = (UILabel *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 9000];
                    UILabel *lb_SubMyCorrect = nil;
                    if( tmp == nil )
                    {
                        lb_SubMyCorrect = [[UILabel alloc] init];
                        lb_SubMyCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fLbWidth + 24) * targetView.zoomScale) ,
                                                           lb_SubCorrect.frame.origin.y - (fLbHeight * targetView.zoomScale),
                                                           fLbWidth * targetView.zoomScale,
                                                           fLbHeight * targetView.zoomScale);
                        lb_SubMyCorrect.font = [UIFont fontWithName:@"Helvetica" size:14];
                        lb_SubMyCorrect.numberOfLines = 2;
                        lb_SubMyCorrect.textAlignment = NSTextAlignmentCenter;
                        lb_SubMyCorrect.textColor = [UIColor whiteColor];
                        lb_SubMyCorrect.text = str_UserCorrect;
                    }
                    else
                    {
                        lb_SubMyCorrect = tmp;
                    }
                    
                    lb_SubMyCorrect.layer.borderColor = [UIColor whiteColor].CGColor;
                    lb_SubMyCorrect.layer.borderWidth = 1.f;
                    lb_SubMyCorrect.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];

                    lb_SubMyCorrect.tag = [[dic objectForKey:@"questionId"] integerValue] + 9000;
                    [targetView addSubview:lb_SubMyCorrect];
                }
            }
            else
            {
                //정답표현
                UIButton *tmp = (UIButton *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 100];
                UIButton *btn_SubCorrect = nil;
                if( tmp == nil )
                {
                    str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                    
                    btn_SubCorrect = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn_SubCorrect.userInteractionEnabled = NO;
                    btn_SubCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fBtnWidth + 24) * targetView.zoomScale) - ((fBtnWidth / 1.5) * targetView.zoomScale) ,
                                                      //                    btn_SubCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fBtnWidth + 24) * targetView.zoomScale) ,
                                                      (fStartY * targetView.zoomScale) + (fHeight * targetView.zoomScale) - ((fBtnHeight + 6) * targetView.zoomScale),
                                                      fBtnWidth * targetView.zoomScale, fBtnHeight * targetView.zoomScale);
                    [btn_SubCorrect setTitle:str_Correct forState:UIControlStateNormal];
                    [btn_SubCorrect.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.f * (btn_SubCorrect.frame.size.width / fBtnWidth)]];
                    [btn_SubCorrect setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btn_SubCorrect setBackgroundColor:[UIColor whiteColor]];
                    btn_SubCorrect.layer.cornerRadius = btn_SubCorrect.frame.size.width/2;
                    btn_SubCorrect.layer.borderWidth = 1.f;
                    btn_SubCorrect.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
                }
                else
                {
                    btn_SubCorrect = tmp;
                }
                
                btn_SubCorrect.tag = [[dic objectForKey:@"questionId"] integerValue] + 100;
                [targetView addSubview:btn_SubCorrect];

                
                if( [str_UserCorrect isEqualToString:str_Correct] )
                {
                    //내 답
                    //맞은문제
                    UIButton *tmp = (UIButton *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 1000];
                    UIButton *btn_SubMyCorrect = nil;
                    if( tmp == nil )
                    {
                        btn_SubMyCorrect = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn_SubMyCorrect.userInteractionEnabled = NO;
                        //                        btn_SubMyCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fBtnWidth + 24) * targetView.zoomScale) - ((fBtnWidth / 1.5) * targetView.zoomScale) ,
                        btn_SubMyCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fBtnWidth + 24) * targetView.zoomScale) ,
                                                            (fStartY * targetView.zoomScale) + (fHeight * targetView.zoomScale) - ((fBtnHeight + 6) * targetView.zoomScale),
                                                            fBtnWidth * targetView.zoomScale, fBtnHeight * targetView.zoomScale);
                        [btn_SubMyCorrect setTitle:str_UserCorrect forState:UIControlStateNormal];
                        [btn_SubMyCorrect.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.f * (btn_SubMyCorrect.frame.size.width / fBtnWidth)]];
                        [btn_SubMyCorrect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_SubMyCorrect setBackgroundColor:[UIColor colorWithHexString:@"4388FA"]];
                        btn_SubMyCorrect.layer.cornerRadius = btn_SubMyCorrect.frame.size.width/2;
                        btn_SubMyCorrect.layer.borderColor = [UIColor whiteColor].CGColor;
                        btn_SubMyCorrect.layer.borderWidth = 1.f;
                        
                    }
                    else
                    {
                        btn_SubMyCorrect = tmp;
                    }
                    
                    btn_SubMyCorrect.tag = [[dic objectForKey:@"questionId"] integerValue] + 1000;
                    [targetView addSubview:btn_SubMyCorrect];
                }
                else
                {
                    //내 답
                    //틀린문제
                    UIButton *tmp = (UIButton *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 1000];
                    UIButton *btn_SubMyCorrect = nil;
                    if( tmp == nil )
                    {
                        btn_SubMyCorrect = [UIButton buttonWithType:UIButtonTypeCustom];
                        btn_SubMyCorrect.userInteractionEnabled = NO;
//                        btn_SubMyCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fBtnWidth + 24) * targetView.zoomScale) - ((fBtnWidth / 1.5) * targetView.zoomScale) ,
                        btn_SubMyCorrect.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fBtnWidth + 24) * targetView.zoomScale) ,
                                                            (fStartY * targetView.zoomScale) + (fHeight * targetView.zoomScale) - ((fBtnHeight + 6) * targetView.zoomScale),
                                                            fBtnWidth * targetView.zoomScale, fBtnHeight * targetView.zoomScale);
                        [btn_SubMyCorrect setTitle:str_UserCorrect forState:UIControlStateNormal];
                        [btn_SubMyCorrect.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.f * (btn_SubMyCorrect.frame.size.width / fBtnWidth)]];
                        [btn_SubMyCorrect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [btn_SubMyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
                        btn_SubMyCorrect.layer.cornerRadius = btn_SubMyCorrect.frame.size.width/2;
                        btn_SubMyCorrect.layer.borderColor = [UIColor whiteColor].CGColor;
                        btn_SubMyCorrect.layer.borderWidth = 1.f;
                        
                    }
                    else
                    {
                        btn_SubMyCorrect = tmp;
                    }
                    
                    btn_SubMyCorrect.tag = [[dic objectForKey:@"questionId"] integerValue] + 1000;
                    [targetView addSubview:btn_SubMyCorrect];
                }
            }
            
            
            
            NSInteger nMyStarCnt = [[dic objectForKey:@"existStarCount"] integerValue];
            if( nMyStarCnt > 0 )
            {
                //별표한거
                UIButton *tmp = (UIButton *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 10000];
                UIButton *btn_Correct = nil;
                if( tmp == nil )
                {
                    btn_Correct = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn_Correct.userInteractionEnabled = NO;
                    btn_Correct.frame = CGRectMake((fStartX * targetView.zoomScale) + (fWidth * targetView.zoomScale) - ((fBtnWidth + 24) * targetView.zoomScale) - ((fBtnWidth * 2) * targetView.zoomScale) ,
                                                   (fStartY * targetView.zoomScale) + (fHeight * targetView.zoomScale) - ((fBtnHeight + 6) * targetView.zoomScale),
                                                   fBtnWidth * targetView.zoomScale, fBtnHeight * targetView.zoomScale);
                    [btn_Correct setBackgroundImage:BundleImage(@"star_yellow.png") forState:UIControlStateNormal];
                }
                else
                {
                    btn_Correct = tmp;
                }
                
                btn_Correct.tag = [[dic objectForKey:@"questionId"] integerValue] + 10000;
                [targetView addSubview:btn_Correct];
            }
            else
            {
                //별표 안한거
                UIButton *tmp = (UIButton *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue] + 10000];
                if( tmp )
                {
                    [tmp removeFromSuperview];
                }
            }
        }
        
        UIImageView *tmp = (UIImageView *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue]];
        [tmp removeFromSuperview];
        
        if( self.isWrong == NO && self.isStar == NO )
        {
//            UIImageView *iv_Guide = nil;
//            if( tmp == nil )
//            {
//                iv_Guide = [[UIImageView alloc] initWithFrame:CGRectMake((fStartX * targetView.zoomScale) - 2, (fStartY * targetView.zoomScale) + 2,
//                                                                         (fWidth * targetView.zoomScale) - 8, (fHeight * targetView.zoomScale))];
//            }
//            else
//            {
//                iv_Guide = tmp;
//            }
//            
//            iv_Guide.tag = [[dic objectForKey:@"questionId"] integerValue];
//            iv_Guide.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
//            iv_Guide.layer.borderWidth = 1.f;
//            [targetView addSubview:iv_Guide];
        }
        
        targetView.ar_Guide = self.ar_Question;
    }
}

- (void)onOwerTouch:(UIButton *)btn
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"] forKey:@"apiToken"];
    [dicM setObject:[Util getUUID] forKey:@"uuid"];
    [dicM setObject:self.str_ExamId forKey:@"examId"];
    [dicM setObject:@"package" forKey:@"examMode"];
    [dicM setObject:@"pdfExam" forKey:@"examType"];
    [dicM setObject:@"1000" forKey:@"limitCount"];
    [dicM setObject:self.str_ExamPage forKey:@"pdfPage"];
    [dicM setObject:@"all" forKey:@"questionType"];
    [dicM setObject:@"next" forKey:@"scrollType"];
    [dicM setObject:@"solve" forKey:@"solveMode"];
    [dicM setObject:@"" forKey:@"testerId"];
    [dicM setObject:@"testing" forKey:@"viewMode"];

    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                        param:dicM
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSMutableArray *arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                                if( arM.count > 0 )
                                                {
                                                    NSDictionary *dic_QuestionInfos = [arM firstObject];
                                                    self.dic_CurrentQuestion = [arM firstObject];
                                                    [self updateAnswerView];
                                                    correctAnswerCount = [[self.dic_CurrentQuestion objectForKey:@"correctAnswerCount"] integerValue];
                                                    self.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                                                    self.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                                    
                                                    [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[dic_QuestionInfos objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
                                                    
                                                    NSArray *ar_Tmp = [dic_QuestionInfos objectForKey:@"examQuestionInfos"];
                                                    if( ar_Tmp.count > 0 )
                                                    {
                                                        NSDictionary *dic = [ar_Tmp firstObject];
                                                        if( [[dic objectForKey:@"questionType"] isEqualToString:@"pdf"] )
                                                        {
                                                            NSString *str_Body = [dic objectForKey:@"questionBody"];
                                                            NSArray *ar_Tmp = [str_Body componentsSeparatedByString:@"/"];
                                                            NSString *str_FileName = [ar_Tmp lastObject];
                                                            
                                                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                            NSString *documentsDirectory = [paths objectAtIndex:0];
                                                            
                                                            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
                                                            BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                                                            if( fileExists )
                                                            {
                                                                ReaderDocument *document_Tmp = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                                                                document_Tmp.isLocalPDf = YES;
                                                                
                                                                if (document_Tmp != nil)
                                                                {
                                                                    [Common setPdfDocument:document_Tmp];
                                                                    
                                                                    [weakSelf dismissViewControllerAnimated:NO completion:^{
                                                                        
                                                                    }];
                                                                    
                                                                    ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
                                                                    weakSelf.navigationController.navigationBarHidden = YES;
                                                                    vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                                                    vc.vc_Parent = self.vc_Parent;
                                                                    vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                                                                    vc.str_QTitle = self.str_ExamTitle;
                                                                    vc.dicM_Parameter = dicM;
                                                                    vc.str_Idx = self.str_ExamId;
                                                                    vc.str_StartIdx = self.str_ExamNo;
//                                                                    vc.nStartPdfPage = self.nStartPdfPage;
                                                                    vc.str_ChannelId = self.str_ChannelId;
                                                                    vc.isOwerMode = YES;
                                                                    vc.str_BeforeIdx = self.str_StartIdx;
                                                                    vc.str_SubjectName = self.str_SubjectName;
                                                                    vc.isBeforeWrong = self.isWrong;
                                                                    vc.isBeforeStar = self.isStar;
                                                                    vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
                                                                    vc.str_ExamPage = self.str_ExamPage;
//                                                                    vc.nStartPdfPage = [self.str_ExamPage integerValue];
                                                                    vc.nStartPdfPage = [self.str_BeforeIdx integerValue];
                                                                    vc.str_Prefix = self.str_Prefix;
                                                                    
//                                                                    vc.currentPage = [self.str_ExamPage integerValue];
                                                                    [vc setDocument:document_Tmp];
                                                                    vc.view.backgroundColor = [UIColor whiteColor];
                                                                    vc.completeBlock = self.completeBlock;
                                                                    
                                                                    [weakSelf.vc_Parent presentViewController:vc animated:NO completion:^{
                                                                        
                                                                    }];
                                                                }
                                                            }
                                                            else
                                                            {
                                                                NSString *str_Url = [NSString stringWithFormat:@"%@%@", [resulte objectForKey:@"img_prefix"], str_Body];
                                                                NSURL  *url = [NSURL URLWithString:str_Url];
                                                                NSData *urlData = [NSData dataWithContentsOfURL:url];
                                                                if ( urlData )
                                                                {
                                                                    [urlData writeToFile:filePath atomically:YES];
                                                                    
                                                                    ReaderDocument *document_Tmp = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                                                                    document_Tmp.isLocalPDf = YES;
                                                                    
                                                                    if (document_Tmp != nil)
                                                                    {
                                                                        [Common setPdfDocument:document_Tmp];
                                                                        
                                                                        [weakSelf dismissViewControllerAnimated:NO completion:^{
                                                                            
                                                                        }];
                                                                        
                                                                        ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
                                                                        weakSelf.navigationController.navigationBarHidden = YES;
                                                                        vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                                                        vc.vc_Parent = self.vc_Parent;
                                                                        vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                                                                        vc.str_QTitle = self.str_ExamTitle;
                                                                        vc.dicM_Parameter = dicM;
                                                                        vc.str_Idx = self.str_ExamId;
                                                                        vc.str_StartIdx = self.str_ExamNo;
//                                                                        vc.nStartPdfPage = self.nStartPdfPage;
                                                                        vc.str_ChannelId = self.str_ChannelId;
                                                                        vc.isOwerMode = YES;
                                                                        vc.str_BeforeIdx = self.str_StartIdx;
                                                                        vc.str_SubjectName = self.str_SubjectName;
                                                                        vc.isBeforeWrong = self.isWrong;
                                                                        vc.isBeforeStar = self.isStar;
                                                                        vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
                                                                        vc.str_ExamPage = self.str_ExamPage;
//                                                                        vc.nStartPdfPage = [self.str_ExamPage integerValue];
                                                                        vc.nStartPdfPage = [self.str_BeforeIdx integerValue];
                                                                        vc.str_Prefix = self.str_Prefix;
                                                                        
                                                                        [vc setDocument:document_Tmp];
                                                                        vc.view.backgroundColor = [UIColor whiteColor];
                                                                        vc.completeBlock = self.completeBlock;
                                                                        
                                                                        [weakSelf.vc_Parent presentViewController:vc animated:NO completion:^{
                                                                            
                                                                        }];
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MBProgressHUD hide];
    
    [mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide

    if( self.isWrong || self.isStar )
    {
        [mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide
        
        self.btn_ZoomOut.hidden = YES;
        self.btn_PdfNext.hidden = YES;
        self.v_Left.hidden = self.v_Right.hidden = NO;
    }

    self.navigationController.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    
    if (CGSizeEqualToSize(lastAppearSize, CGSizeZero) == false)
    {
        if (CGSizeEqualToSize(lastAppearSize, self.view.bounds.size) == false)
        {
            [self updateContentViews:theScrollView]; // Update content views
        }
        
        lastAppearSize = CGSizeZero; // Reset view size tracking
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [MBProgressHUD hide];

    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == true)
    {
        [self performSelector:@selector(showDocument) withObject:nil afterDelay:0.0];
    }
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
#endif // end of READER_DISABLE_IDLE Option
    
    //    [self.view bringSubviewToFront:self.v_Bottom];
    //    [self.view bringSubviewToFront:mainPagebar];
    
    [self.view sendSubviewToBack:theScrollView];
    [self.view bringSubviewToFront:self.v_Pause];
    

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateTimer"
                                                  object:nil];

    [self.tm_Arrow invalidate];
    self.tm_Arrow = nil;
    self.v_Left.hidden = self.v_Right.hidden = YES;

//    [self performSelector:@selector(onDismissInterval) withObject:nil afterDelay:0.5f];

    lastAppearSize = self.view.bounds.size; // Track view size
    
#if (READER_DISABLE_IDLE == TRUE) // Option
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
#endif // end of READER_DISABLE_IDLE Option
    
    NSMutableArray *arM = [self.navigationController.viewControllers mutableCopy];
    for( NSInteger i = 0; i < arM.count; i++ )
    {
        id vc = [arM objectAtIndex:i];
        if( [vc isKindOfClass:[QuestionContainerViewController class]] )
        {
            [arM removeObjectAtIndex:i];
        }
    }
    
    self.navigationController.viewControllers = arM;

    [self stopAudio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidUnload
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
    mainToolbar = nil; mainPagebar = nil;
    
    theScrollView = nil; contentViews = nil; lastHideTime = nil;
    
    documentInteraction = nil; printInteraction = nil;
    
    lastAppearSize = CGSizeZero; self.currentPage = 0;
    
    [super viewDidUnload];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return YES;
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    if( toInterfaceOrientation == UIDeviceOrientationLandscapeLeft || toInterfaceOrientation == UIDeviceOrientationLandscapeRight )
//    {
////        CGRect frame = theScrollView.frame;
////        frame.origin.y = 0;
////        frame.size.height = self.view.frame.size.height;
////        theScrollView.frame = frame;
////
////        self.lc_NaviHieght.constant = 0.f;
//
//        if( self.dic_CurrentQuestion && self.dic_CurrentPdf )
//        {
//            [self performSelector:@selector(onShowZoomInterval:)
//                       withObject:@{@"dic_Sub":self.dic_CurrentQuestion, @"dic_PdfInfo":self.dic_CurrentPdf}
//                       afterDelay:0.8f];
//        }
//
////        theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)]; // All
//    }
//    else
//    {
//        CGRect frame = theScrollView.frame;
//        frame.origin.y = 64.f;
//        frame.size.height = self.view.frame.size.height - 64.f;
//        theScrollView.frame = frame;
//        
//        self.lc_NaviHieght.constant = 64.f;
//        
//        if( self.dic_CurrentQuestion && self.dic_CurrentPdf )
//        {
//            [self performSelector:@selector(onShowZoomInterval:)
//                       withObject:@{@"dic_Sub":self.dic_CurrentQuestion, @"dic_PdfInfo":self.dic_CurrentPdf}
//                       afterDelay:0.8f];
//        }
//    }

    if (userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        if (printInteraction != nil)
        {
            [printInteraction dismissAnimated:NO];
        }
    }
    
    ignoreDidScroll = YES;
    
    if( self.vc_SideMenuViewController )
    {
        [self.vc_SideMenuViewController closeMenu];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    if (CGSizeEqualToSize(theScrollView.contentSize, CGSizeZero) == false)
    {
        [self updateContentViews:theScrollView];
        lastAppearSize = CGSizeZero;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    ignoreDidScroll = NO;
    
    if( fromInterfaceOrientation == UIDeviceOrientationLandscapeLeft || fromInterfaceOrientation == UIDeviceOrientationLandscapeRight )
    {
        //세로모드
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        
        CGRect frame = theScrollView.frame;
        frame.origin.y = 64.f;
        frame.size.height = self.view.frame.size.height - 64.f;
        theScrollView.frame = frame;

        self.lc_PauseTop.constant = 0;
        
        self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1;;
        //
        
        self.lc_NaviHieght.constant = 64.f;
        
        if( self.dic_CurrentQuestion && self.dic_CurrentPdf )
        {
            [self performSelector:@selector(onShowZoomInterval:)
                       withObject:@{@"dic_Sub":self.dic_CurrentQuestion, @"dic_PdfInfo":self.dic_CurrentPdf}
                       afterDelay:0.5f];
        }
        
//        self.v_Navi.backgroundColor = [UIColor whiteColor];
        self.v_Navi.alpha = 1.0f;
        self.iv_NumberBg.alpha = 1.0f;
//        self.iv_NaviBg.alpha = self.iv_NumberBlackBg.alpha = 0.f;
        
        //        theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64)]; // All
    }
    else
    {
        //가로모드
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        CGRect frame = theScrollView.frame;
        frame.origin.y = 64;
        frame.size.height = self.view.frame.size.height;
        theScrollView.frame = frame;
        
        self.lc_PauseTop.constant = -16.f;
        
        self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1;;
//
        self.lc_NaviHieght.constant = 48.f;
        
//        self.iv_NaviBg.backgroundColor = [UIColor whiteColor];
        self.v_Navi.alpha = 0.95f;
        self.iv_NumberBg.alpha = 0.9f;
//        self.iv_NaviBg.alpha = self.iv_NumberBlackBg.alpha = 0.5f;

        if( self.dic_CurrentQuestion && self.dic_CurrentPdf )
        {
            [self performSelector:@selector(onShowZoomInterval:)
                       withObject:@{@"dic_Sub":self.dic_CurrentQuestion, @"dic_PdfInfo":self.dic_CurrentPdf}
                       afterDelay:0.5f];
        }
        
        
        id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
        NSString *str_UserCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
        if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
        {
            if( isNumberQuestion )
            {
                //문제를 풀지 않았다면 버튼 표현
                self.lc_AnswerBottom.constant = -164.f;
                self.v_Bottom.lc_BottomViewBottom.constant = -self.view.frame.size.height;
            }
        }
        else
        {
            if( isNumberQuestion )
            {
                //문제를 풀었다면 공유바만 표현
                self.lc_AnswerBottom.constant = 0.f;
                self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
#ifdef DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    
    [super didReceiveMemoryWarning];
}

- (void)updateWrong
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_StartIdx, @"examNo",
                                        @"1", @"limitCount",
                                        self.str_SubjectName, @"subjectName",
                                        @"0", @"schoolGrade",
                                        @"0", @"personGrade",
                                        nil];
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/incorrect/question/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            weakSelf.dic_Resulte = [NSDictionary dictionaryWithDictionary:resulte];

                                            self.ar_Question = [resulte objectForKey:@"questionInfos"];
                                            self.dic_CurrentQuestion = [self.ar_Question objectAtIndex:self.nCurrentIdx];
                                            [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
                                        }
                                    }];
}

- (void)updateListWithFit:(BOOL)isFit
{
    if( self.isWrong || self.isStar )
    {
        NSDictionary *resulte = self.dic_Resulte;
        
//        NSDictionary *dic_ExamPackageInfo = [resulte objectForKey:@"examPackageInfo"];
//        nTotalQCnt = [[resulte objectForKey:@"seqTotalQuestionCount"] integerValue];
        nTotalQCnt = [self.str_SubjectTotalCount integerValue];
        
        self.lb_QTotalCnt.text = [NSString stringWithFormat:@"%ld", nTotalQCnt];
        self.lb_QCurrentCnt.text = self.str_StartIdx;
        
        if( [self.str_StartIdx integerValue] <= 1 )
        {
            self.v_Left.hidden = YES;
        }
        else if( [self.str_StartIdx integerValue] >= nTotalQCnt )
        {
            self.v_Right.hidden = YES;
        }
        else
        {
            self.v_Left.hidden = self.v_Right.hidden = NO;
        }
        
        self.ar_Question = [resulte objectForKey:@"questionInfos"];
        [self updateQuestionStatusWithUpdateCount:isFit];
        
        if( isFit && self.ar_Question.count > 0 )
        {
            NSDictionary *dic = [self.ar_Question firstObject];
            NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
            if( ar_Tmp.count > 0 )
            {
                NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                
                CGFloat fWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
                CGFloat fScale = (self.view.bounds.size.width) / fWidth;
                CGFloat fStartX = [[dic_PdfInfo objectForKey:@"startX"] floatValue];
                NSLog(@"fStartX :%f, scale: %f", fStartX, fScale);
                
                CGFloat fOriginalStartx = fStartX * fScale;
                CGFloat fPdfWidth = [[dic_PdfInfo objectForKey:@"pdfWidth"] floatValue];
                
                //                                                    CGFloat fXper = (fPdfWidth / fOriginalStartx) * 0.01;
                CGFloat fXper = fOriginalStartx/ fPdfWidth;
                
                
                NSNumber *key = [NSNumber numberWithInteger:self.currentPage]; // Page number key
                
                ReaderContentView *targetView = [contentViews objectForKey:key]; // View
                targetView.isWrong = (self.isWrong || self.isStar );

//                self.view.alpha = NO;
                
                [UIView animateWithDuration:.3f animations:^{
                    
                    targetView.zoomScale = targetView.minimumZoomScale + (targetView.minimumZoomScale * (fXper * 2));
                }completion:^(BOOL finished) {
                
//                    self.view.alpha = YES;
                }];
            }
        }
        
        if( self.dic_CurrentQuestion )
        {
            for( NSInteger i = 0; i < self.ar_Question.count; i++ )
            {
                NSInteger nNowId = [[self.dic_CurrentQuestion objectForKey:@"questionId"] integerValue];
                NSDictionary *dic = self.ar_Question[i];
                NSInteger nId = [[dic objectForKey:@"questionId"] integerValue];
                
                if( nNowId == nId )
                {
                    self.dic_CurrentQuestion = [NSDictionary dictionaryWithDictionary:dic];
                }
            }
        }

        
        {
            NSLog(@"In");
            
            if( self.ar_Question == nil || self.ar_Question.count <= 0 )
            {
//                [Util showToast:@"데이터 오류"];
                return;
            }
            NSDictionary *dic = self.ar_Question[0];
            NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
            if( ar_Tmp.count <= 0 ) return;
            
            NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];

            self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
            self.v_Bottom.str_ChannelId = self.str_ChannelId;
            [self bottomViewInit];
            [self.v_Bottom updateDList];
            [self.v_Bottom updateQList];
            
            //                        self.v_Bottom.lc_BottomViewBottom.constant = 0;
            //
            //                        [UIView animateWithDuration:10.7f animations:^{
            //
            //                            [self.view setNeedsLayout];
            //                        }];
            
            //                        isAnswerNonNumberFinish = NO;
            self.lb_StringCorrent.text = @"";
            self.lb_StringMyCorrent.text = @"";
            
            self.tf_NonNumberAnswer1.attributedText = self.tf_NonNumberAnswer2.attributedText = nil;
            self.tf_NonNumberAnswer1.text = self.tf_NonNumberAnswer2.text = @"";
            
//            //PDF 튀는 현상 수정
//            CGPoint offset = targetView.contentOffset;
//            [targetView setContentOffset:offset animated:NO];
            
            //                        [self goAnswerClose:nil];
            
            [self stopAudio];
            self.dic_AudioInfo = nil;
            
            //오디오 문제인지 검사
            if( ar_Tmp.count > 1 )
            {
                /*
                 height = 0;
                 orderInx = 1;
                 pdfHeight = 0;
                 pdfPage = 1;
                 pdfWidth = 0;
                 questionBody = "000/000/c06a75473eb83ebb91780dcce2ad7168.mp3";
                 questionType = audio;
                 startX = 0;
                 startY = 0;
                 width = 0;
                 */
                
                
                self.v_AudioContainer.hidden = YES;
                
                self.dic_AudioInfo = [ar_Tmp objectAtIndex:1];
                
                //                            [self addAudioView];
            }
            
            self.nCurrentIdx = 0;
            [self showZoom:dic withPdfInfo:dic_PdfInfo];
            
            
            //가로 모드일때
            if( (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight ||
               (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft )
            {
                self.lc_NaviHieght.constant = 48.f;
                
                id userCorrect = [dic objectForKey:@"user_correct"];
                NSString *str_UserCorrect = [dic objectForKey:@"user_correct"];
                if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
                {
                    //문제를 풀지 않았다면 버튼 표현
                    self.lc_AnswerBottom.constant = 0.f; //숫자 버튼 보이기
                    self.v_Bottom.lc_BottomViewBottom.constant = -self.view.frame.size.height; //툴바 숨기기
                    
                }
                else
                {
                    //문제를 풀었다면 공유바만 표현
                    self.lc_AnswerBottom.constant = -164.f; //숫자 버튼 숨기기
                    self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1; //툴바 보이기
                }
            }
        }
        
        return;
    }
    
    
    if( isOwerModeTmp2 )
    {
        [self.dicM_Parameter setObject:self.str_ExamPage forKey:@"pdfPage"];
        isOwerModeTmp2 = NO;
    }
    else
    {
        [self.dicM_Parameter setObject:[NSString stringWithFormat:@"%ld", self.currentPage] forKey:@"pdfPage"];
    }
    
    
    [self.dicM_Parameter setObject:@"" forKey:@"lastExamNo"];
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                        param:self.dicM_Parameter
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        [SVProgressHUD dismiss];

                                        if( resulte )
                                        {
                                            NSString *str_NormalQKey = [NSString stringWithFormat:@"PdfQuestion_%@",
                                                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                            
                                            NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
                                            NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
                                            NSString *str_Key = [NSString stringWithFormat:@"%ld_%ld",
                                                                 [[self.dicM_Parameter objectForKey:@"examId"] integerValue],
                                                                 self.currentPage];
                                            [dicM_NormalQ setObject:resulte forKey:str_Key];
                                            
                                            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM_NormalQ];
                                            [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
                                            [[NSUserDefaults standardUserDefaults] synchronize];

                                            
                                            self.dic_ExamInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examPackageInfo"]];
                                            
                                            NSDictionary *dic_ExamPackageInfo = [resulte objectForKey:@"examPackageInfo"];
                                            nTotalQCnt = [[dic_ExamPackageInfo objectForKey:@"questionCount"] integerValue];
                                            self.ar_Question = [resulte objectForKey:@"questionInfos"];
                                            [self updateQuestionStatusWithUpdateCount:isFit];

                                            if( isFit && self.ar_Question.count > 0 )
                                            {
                                                NSDictionary *dic = [self.ar_Question firstObject];
                                                NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
                                                if( ar_Tmp.count > 0 )
                                                {
                                                    NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                                                    
                                                    CGFloat fWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
                                                    CGFloat fScale = (self.view.bounds.size.width) / fWidth;
                                                    CGFloat fStartX = [[dic_PdfInfo objectForKey:@"startX"] floatValue];
                                                    NSLog(@"fStartX :%f, scale: %f", fStartX, fScale);
                                                    
                                                    CGFloat fOriginalStartx = fStartX * fScale;
                                                    CGFloat fPdfWidth = [[dic_PdfInfo objectForKey:@"pdfWidth"] floatValue];
                                                    
//                                                    CGFloat fXper = (fPdfWidth / fOriginalStartx) * 0.01;
                                                    CGFloat fXper = fOriginalStartx/ fPdfWidth;

                                                    
                                                    NSNumber *key = [NSNumber numberWithInteger:self.currentPage]; // Page number key
                                                    
                                                    ReaderContentView *targetView = [contentViews objectForKey:key]; // View
                                                    
                                                    [UIView animateWithDuration:0.3f animations:^{
                                                        
                                                        targetView.zoomScale = targetView.minimumZoomScale + (targetView.minimumZoomScale * (fXper * 2));
                                                    }];
                                                }
                                            }
                                            
                                            if( self.dic_CurrentQuestion )
                                            {
                                                for( NSInteger i = 0; i < self.ar_Question.count; i++ )
                                                {
                                                    NSInteger nNowId = [[self.dic_CurrentQuestion objectForKey:@"questionId"] integerValue];
                                                    NSDictionary *dic = self.ar_Question[i];
                                                    NSInteger nId = [[dic objectForKey:@"questionId"] integerValue];
                                                    
                                                    if( nNowId == nId )
                                                    {
                                                        self.dic_CurrentQuestion = [NSDictionary dictionaryWithDictionary:dic];
                                                    }
                                                }
                                            }
                                            
                                            if( isOwerModeTmp )
                                            {
                                                isOwerModeTmp = NO;
                                                for( NSInteger i = 0; i < self.ar_Question.count; i++ )
                                                {
                                                    NSDictionary *dic = [self.ar_Question objectAtIndex:i];
                                                    NSInteger nExamNoTmp = [[dic objectForKey:@"examNo"] integerValue];
                                                    if( nExamNoTmp == [self.str_StartIdx integerValue] )
                                                    {
                                                        self.dic_CurrentQuestion = [NSDictionary dictionaryWithDictionary:dic];
                                                        NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
//                                                        if( ar_Tmp.count <= 0 ) return;
                                                        NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                                                        [self showZoom:self.dic_CurrentQuestion withPdfInfo:dic_PdfInfo];
                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                        
                                        self.view.userInteractionEnabled = YES;
                                        
//                                        if( isMoveQuestion )
//                                        {
//                                            //화살표로 다음 문제 넘어갈때
//                                            isMoveQuestion = NO;
//                                            
//                                            NSDictionary *dic = [self.ar_Question firstObject];
//                                            NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
//                                            NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
//                                            [self showZoom:self.dic_CurrentQuestion withPdfInfo:dic_PdfInfo];
//                                        }
                                    }];
}


- (void)stopAudio
{
    if( self.v_Audio.player )
    {
        [self.v_Audio.player pause];
        [self.v_Audio.player seekToTime:CMTimeMake(0, 1)];
        self.v_Audio.player = nil;
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (ignoreDidScroll == NO) [self layoutContentViews:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self handleScrollViewDidEnd:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIScrollView class]])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - UIGestureRecognizer action methods

- (void)decrementPageNumber
{
    if ((maximumPage > minimumPage) && (self.currentPage != minimumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x -= theScrollView.bounds.size.width; // View X--
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)incrementPageNumber
{
    if ((maximumPage > minimumPage) && (self.currentPage != maximumPage))
    {
        CGPoint contentOffset = theScrollView.contentOffset; // Offset
        
        contentOffset.x += theScrollView.bounds.size.width; // View X++
        
        [theScrollView setContentOffset:contentOffset animated:YES];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if( (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight ||
           (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft )
        {
            if( self.lc_NaviHieght.constant == 0 )
            {
                //메뉴 보이기
                theScrollView.clipsToBounds = NO;
                
                self.lc_NaviHieght.constant = 48.f;
                
                
                id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                NSString *str_UserCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
                if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
                {
                    //안푼 문제
                    self.lc_AnswerBottom.constant = 0.f;
                    self.v_Bottom.lc_BottomViewBottom.constant = -self.view.frame.size.height;
                }
                else
                {
                    //푼 문제
                    self.lc_AnswerBottom.constant = -164;
                    self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1;
                }


                [UIView animateWithDuration:0.3f animations:^{

//                    CGRect frame = theScrollView.frame;
//                    frame.origin.y = 64.f;
//                    frame.size.height = self.view.frame.size.height - 64.f;
//                    theScrollView.frame = frame;
                    
                    [self.view layoutIfNeeded];
                }];
                
                self.tm_Arrow = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(onHideArrow) userInfo:nil repeats:NO];
                
                [UIView animateWithDuration:0.3f animations:^{
                    
                    self.lc_LeftArrowLeading.constant = 10.f;
                    self.lc_RightArrowTail.constant = 10.f;
                    [self.view layoutIfNeeded];
                }];
            }
            else
            {
                //메뉴 가리기
                theScrollView.clipsToBounds = NO;
                
                self.lc_NaviHieght.constant = 0.f;
                self.lc_AnswerBottom.constant = -164.f;
                self.v_Bottom.lc_BottomViewBottom.constant = -self.view.frame.size.height;
                

                [UIView animateWithDuration:0.3f animations:^{

//                    CGRect frame = theScrollView.frame;
//                    frame.origin.y = 0.f;
//                    frame.size.height = self.view.frame.size.height;
//                    theScrollView.frame = frame;
                    
                    [self.view layoutIfNeeded];
                }];
                
                [self onHideArrow];
            }

            return;
        }
        else
        {
            if( self.lc_LeftArrowLeading.constant < 0 )
            {
                self.tm_Arrow = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(onHideArrow) userInfo:nil repeats:NO];
                
                [UIView animateWithDuration:0.3f animations:^{
                    
                    self.lc_LeftArrowLeading.constant = 10.f;
                    self.lc_RightArrowTail.constant = 10.f;
                    [self.view layoutIfNeeded];
                }];
            }
            else
            {
                [self onHideArrow];
            }
        }
        

        //아래는 싱글탭 기능임 (하단에 전체 pdf뷰가 쭈르륵 나오는거)
//        CGRect viewRect = recognizer.view.bounds; // View bounds
//        
//        CGPoint point = [recognizer locationInView:recognizer.view]; // Point
//        
//        CGRect areaRect = CGRectInset(viewRect, TAP_AREA_SIZE, 0.0f); // Area rect
//        
//        if (CGRectContainsPoint(areaRect, point) == true) // Single tap is inside area
//        {
//            NSNumber *key = [NSNumber numberWithInteger:self.currentPage]; // Page number key
//            
//            ReaderContentView *targetView = [contentViews objectForKey:key]; // View
//            
//            id target = [targetView processSingleTap:recognizer]; // Target object
//            
//            if (target != nil) // Handle the returned target object
//            {
//                if ([target isKindOfClass:[NSURL class]]) // Open a URL
//                {
//                    NSURL *url = (NSURL *)target; // Cast to a NSURL object
//                    
//                    if (url.scheme == nil) // Handle a missing URL scheme
//                    {
//                        NSString *www = url.absoluteString; // Get URL string
//                        
//                        if ([www hasPrefix:@"www"] == YES) // Check for 'www' prefix
//                        {
//                            NSString *http = [[NSString alloc] initWithFormat:@"http://%@", www];
//                            
//                            url = [NSURL URLWithString:http]; // Proper http-based URL
//                        }
//                    }
//                    
//                    if ([[UIApplication sharedApplication] openURL:url] == NO)
//                    {
//#ifdef DEBUG
//                        NSLog(@"%s '%@'", __FUNCTION__, url); // Bad or unknown URL
//#endif
//                    }
//                }
//                else // Not a URL, so check for another possible object type
//                {
//                    if ([target isKindOfClass:[NSNumber class]]) // Goto page
//                    {
//                        NSInteger number = [target integerValue]; // Number
//                        
//                        [self showDocumentPage:number]; // Show the page
//                    }
//                }
//            }
//            else // Nothing active tapped in the target content view
//            {
//                if ([lastHideTime timeIntervalSinceNow] < -0.75) // Delay since hide
//                {
//                    if ((mainToolbar.alpha < 1.0f) || (mainPagebar.alpha < 1.0f)) // Hidden
//                    {
//                        if( self.v_Bottom.lc_BottomViewBottom.constant != 0 )
//                        {
//                            [mainToolbar showToolbar]; [mainPagebar showPagebar]; // Show
//                        }
//                        //                        [UIView animateWithDuration:0.3f animations:^{
//                        //                            self.v_Bottom.alpha = NO;
//                        //                        }];
//                    }
//                }
//            }
//            
//            return;
//        }
//        
//        CGRect nextPageRect = viewRect;
//        nextPageRect.size.width = TAP_AREA_SIZE;
//        nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
//        
//        if (CGRectContainsPoint(nextPageRect, point) == true) // page++
//        {
//            [self incrementPageNumber]; return;
//        }
//        
//        CGRect prevPageRect = viewRect;
//        prevPageRect.size.width = TAP_AREA_SIZE;
//        
//        if (CGRectContainsPoint(prevPageRect, point) == true) // page--
//        {
//            [self decrementPageNumber]; return;
//        }
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if( 1 )
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            self.lc_AnswerNonNumberBottom.constant = -164.f;
            self.lc_AnswerBottom.constant = -164.f;

            CGRect viewRect = recognizer.view.bounds;
            CGPoint point = [recognizer locationInView:recognizer.view];
            
            NSDictionary *dic = nil;
            for( NSInteger i = 0; i < self.ar_Question.count; i++ )
            {
                if( self.isWrong || self.isStar )
                {
                    [self showZoom:self.dic_CurrentQuestion withPdfInfo:self.dic_CurrentPdf];
                    return;
                }
                
                NSDictionary *dic = _ar_Question[i];
                NSArray *ar_Tmp = [dic objectForKey:@"examQuestionInfos"];
                if( ar_Tmp.count <= 0 ) return;
                
                NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                NSInteger nPage = [[dic_PdfInfo objectForKey:@"pdfPage"] integerValue];
                if( nPage == self.currentPage )
                {
                    NSNumber *key = [NSNumber numberWithInteger:self.currentPage];
                    ReaderContentView *targetView = [contentViews objectForKey:key];
                    
                    CGFloat fWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
                    CGFloat fHeight = [[dic_PdfInfo objectForKey:@"height"] floatValue];
                    
                    CGFloat fScale = (self.view.bounds.size.width) / fWidth;
                    fOldScale = fScale;
                    CGFloat fStartX = [[dic_PdfInfo objectForKey:@"startX"] floatValue];
                    CGFloat fStartY = [[dic_PdfInfo objectForKey:@"startY"] floatValue];
                    NSLog(@"originalScal:%f", fScale);
                    NSLog(@"startX:%f, startY:%f", fStartX, fStartY);
                    NSLog(@"width:%f, height:%f", fWidth, fHeight);
                    //                    NSLog(@"touchX:%f, touchY:%f", point.x + (point.x * (fScale - targetView.zoomScale)), point.y + (point.y * (fScale - targetView.zoomScale)));
                    NSLog(@"touchX:%f, touchY:%f", point.x, point.y);
                    
                    NSLog(@"scale:%f", targetView.zoomScale);
                    NSLog(@"currentOffsetX:%f, currentOffsetY:%f", targetView.contentOffset.x, targetView.contentOffset.y);
                    
                    NSLog(@"%f", (targetView.contentOffset.x + point.x) * fScale);
                    
                    
                    //                    CGFloat fSumScale = fScale / targetView.zoomScale;
                    CGFloat fSumX = (point.x + targetView.contentOffset.x) / targetView.zoomScale;
                    CGFloat fSumY = ((point.y - 66.f) + targetView.contentOffset.y) / targetView.zoomScale;
                    
                    NSLog(@"sumX:%f, sumY:%f", fSumX, fSumY);
                    
                    if( (fSumX > fStartX && fSumX < fStartX + fWidth) && (fSumY > fStartY && fSumY < fStartY + fHeight) )
                    {
                        NSLog(@"In");
                        
                        self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
                        self.v_Bottom.str_ChannelId = self.str_ChannelId;
//                        [self bottomViewInit];
//                        [self.v_Bottom updateDList];
//                        [self.v_Bottom updateQList];
                        
//                        self.v_Bottom.lc_BottomViewBottom.constant = 0;
//                        
//                        [UIView animateWithDuration:10.7f animations:^{
//                            
//                            [self.view setNeedsLayout];
//                        }];

//                        isAnswerNonNumberFinish = NO;
                        self.lb_StringCorrent.text = @"";
                        self.lb_StringMyCorrent.text = @"";

                        self.tf_NonNumberAnswer1.attributedText = self.tf_NonNumberAnswer2.attributedText = nil;
                        self.tf_NonNumberAnswer1.text = self.tf_NonNumberAnswer2.text = @"";
                        
                        //PDF 튀는 현상 수정
                        CGPoint offset = targetView.contentOffset;
                        [targetView setContentOffset:offset animated:NO];

//                        [self goAnswerClose:nil];
                        
                        [self stopAudio];
                        self.dic_AudioInfo = nil;
                        
                        //오디오 문제인지 검사
                        if( ar_Tmp.count > 1 )
                        {
                            /*
                             height = 0;
                             orderInx = 1;
                             pdfHeight = 0;
                             pdfPage = 1;
                             pdfWidth = 0;
                             questionBody = "000/000/c06a75473eb83ebb91780dcce2ad7168.mp3";
                             questionType = audio;
                             startX = 0;
                             startY = 0;
                             width = 0;
                             */
                            

                            self.v_AudioContainer.hidden = YES;
                            
                            self.dic_AudioInfo = [ar_Tmp objectAtIndex:1];
                            
//                            [self addAudioView];
                        }
                        
                        self.nCurrentIdx = i;
                        [self showZoom:dic withPdfInfo:dic_PdfInfo];
                        
                        
                        //가로 모드일때
                        if( (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight ||
                           (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft )
                        {
                            self.lc_NaviHieght.constant = 48.f;
                            
                            id userCorrect = [dic objectForKey:@"user_correct"];
                            NSString *str_UserCorrect = [dic objectForKey:@"user_correct"];
                            if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
                            {
                                //문제를 풀지 않았다면 버튼 표현
                                self.lc_AnswerBottom.constant = 0.f; //숫자 버튼 보이기
                                self.v_Bottom.lc_BottomViewBottom.constant = -self.view.frame.size.height; //툴바 숨기기
                                
                            }
                            else
                            {
                                //문제를 풀었다면 공유바만 표현
                                self.lc_AnswerBottom.constant = -164.f; //숫자 버튼 숨기기
                                self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1; //툴바 보이기
                            }
                        }

                        return;
                    }
                    else
                    {
                        NSLog(@"Out");
                    }
                }
            }
        }
    }
    else
    {
        if (recognizer.state == UIGestureRecognizerStateRecognized)
        {
            CGRect viewRect = recognizer.view.bounds; // View bounds
            
            CGPoint point = [recognizer locationInView:recognizer.view]; // Point
            
            CGRect zoomArea = CGRectInset(viewRect, TAP_AREA_SIZE, TAP_AREA_SIZE); // Area
            
            if (CGRectContainsPoint(zoomArea, point) == true) // Double tap is inside zoom area
            {
                NSNumber *key = [NSNumber numberWithInteger:self.currentPage]; // Page number key
                
                ReaderContentView *targetView = [contentViews objectForKey:key]; // View
                
                switch (recognizer.numberOfTouchesRequired) // Touches count
                {
                    case 1: // One finger double tap: zoom++
                    {
                        [targetView zoomIncrement:recognizer]; break;
                    }
                        
                    case 2: // Two finger double tap: zoom--
                    {
                        [targetView zoomDecrement:recognizer]; break;
                    }
                }
                
                return;
            }
            
            CGRect nextPageRect = viewRect;
            nextPageRect.size.width = TAP_AREA_SIZE;
            nextPageRect.origin.x = (viewRect.size.width - TAP_AREA_SIZE);
            
            if (CGRectContainsPoint(nextPageRect, point) == true) // page++
            {
                [self incrementPageNumber]; return;
            }
            
            CGRect prevPageRect = viewRect;
            prevPageRect.size.width = TAP_AREA_SIZE;
            
            if (CGRectContainsPoint(prevPageRect, point) == true) // page--
            {
                [self decrementPageNumber]; return;
            }
        }
    }
}

- (void)bottomViewInit
{
    [self.v_Bottom initFrame:self];
    
    self.btn_Menu.alpha = YES;
    self.btn_Star.alpha = YES;
    self.btn_Share.alpha = YES;
    self.btn_ZoomOut.alpha = YES;
    self.btn_PdfNext.alpha = YES;
    self.v_Correct.alpha = YES;
    self.lb_StringCorrent.alpha = YES;
    self.lb_StringMyCorrent.alpha = YES;
}

- (void)addAudioView
{
    if( self.dic_AudioInfo && [[self.dic_AudioInfo objectForKey:@"questionType"] isEqualToString:@"audio"] )
    {
        NSString *str_Body = [self.dic_AudioInfo objectForKey:@"questionBody"];
        NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_Prefix, str_Body];
        
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
        self.v_Audio = [topLevelObjects objectAtIndex:0];
        [self.v_Audio initPlayer:str_Url];
        
        CGRect frame = self.v_Audio.frame;
        frame.size.width = self.view.frame.size.width;
        self.v_Audio.frame = frame;
        
        [self.v_AudioContainer addSubview:self.v_Audio];
        self.v_AudioContainer.hidden = NO;
    }
    else
    {
        self.v_AudioContainer.hidden = YES;
    }
}


#pragma mark - ReaderContentViewDelegate methods

- (void)contentView:(ReaderContentView *)contentView touchesBegan:(NSSet *)touches
{
    if ((mainToolbar.alpha > 0.0f) || (mainPagebar.alpha > 0.0f))
    {
        if (touches.count == 1) // Single touches only
        {
            UITouch *touch = [touches anyObject]; // Touch info
            
            CGPoint point = [touch locationInView:self.view]; // Touch location
            
            CGRect areaRect = CGRectInset(self.view.bounds, TAP_AREA_SIZE, TAP_AREA_SIZE);
            
            if (CGRectContainsPoint(areaRect, point) == false) return;
        }
        
        [mainToolbar hideToolbar]; [mainPagebar hidePagebar]; // Hide
        
        
        //        [UIView animateWithDuration:0.3f animations:^{
        //            self.v_Bottom.alpha = YES;
        //        }];
        
        
        lastHideTime = [NSDate date]; // Set last hide time
    }
}

#pragma mark - ReaderMainToolbarDelegate methods

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar doneButton:(UIButton *)button
{
#if (READER_STANDALONE == FALSE) // Option
    
    [self closeDocument]; // Close ReaderViewController
    
#endif // end of READER_STANDALONE Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar cropButton:(UIButton *)button
{
    if ([delegate respondsToSelector:@selector(crop:)] == YES)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", self.currentPage] forKey:@"pdfPage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [delegate crop:self.currentPage]; // Dismiss the ReaderViewController
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar thumbsButton:(UIButton *)button
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    if (printInteraction != nil) [printInteraction dismissAnimated:NO];
    
    ThumbsViewController *thumbsViewController = [[ThumbsViewController alloc] initWithReaderDocument:document];
    
    thumbsViewController.title = self.title; thumbsViewController.delegate = self; // ThumbsViewControllerDelegate
    
    thumbsViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    thumbsViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:thumbsViewController animated:NO completion:NULL];
    
#endif // end of READER_ENABLE_THUMBS Option
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar exportButton:(UIButton *)button
{
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    NSURL *fileURL = document.fileURL; // Document file URL
    
    documentInteraction = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    
    documentInteraction.delegate = self; // UIDocumentInteractionControllerDelegate
    
    [documentInteraction presentOpenInMenuFromRect:button.bounds inView:button animated:YES];
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar printButton:(UIButton *)button
{
    if ([UIPrintInteractionController isPrintingAvailable] == YES)
    {
        NSURL *fileURL = document.fileURL; // Document file URL
        
        if ([UIPrintInteractionController canPrintURL:fileURL] == YES)
        {
            printInteraction = [UIPrintInteractionController sharedPrintController];
            
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.jobName = document.fileName;
            
            printInteraction.printInfo = printInfo;
            printInteraction.printingItem = fileURL;
            printInteraction.showsPageRange = YES;
            
            if (userInterfaceIdiom == UIUserInterfaceIdiomPad) // Large device printing
            {
                [printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
            else // Handle printing on small device
            {
                [printInteraction presentAnimated:YES completionHandler:
                 ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
                 {
#ifdef DEBUG
                     if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
#endif
                 }
                 ];
            }
        }
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar emailButton:(UIButton *)button
{
    if ([MFMailComposeViewController canSendMail] == NO) return;
    
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    unsigned long long fileSize = [document.fileSize unsignedLongLongValue];
    
    if (fileSize < 15728640ull) // Check attachment size limit (15MB)
    {
        NSURL *fileURL = document.fileURL; NSString *fileName = document.fileName;
        
        NSData *attachment = [NSData dataWithContentsOfURL:fileURL options:(NSDataReadingMapped|NSDataReadingUncached) error:nil];
        
        if (attachment != nil) // Ensure that we have valid document file attachment data available
        {
            MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
            
            [mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:fileName];
            
            [mailComposer setSubject:fileName]; // Use the document file name for the subject
            
            mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
            
            mailComposer.mailComposeDelegate = self; // MFMailComposeViewControllerDelegate
            
            [self presentViewController:mailComposer animated:YES completion:NULL];
        }
    }
}

- (void)tappedInToolbar:(ReaderMainToolbar *)toolbar markButton:(UIButton *)button
{
#if (READER_BOOKMARKS == TRUE) // Option
    
    if (printInteraction != nil) [printInteraction dismissAnimated:YES];
    
    if ([document.bookmarks containsIndex:self.currentPage]) // Remove bookmark
    {
        [document.bookmarks removeIndex:self.currentPage]; [mainToolbar setBookmarkState:NO];
    }
    else // Add the bookmarked page number to the bookmark index set
    {
        [document.bookmarks addIndex:self.currentPage]; [mainToolbar setBookmarkState:YES];
    }
    
#endif // end of READER_BOOKMARKS Option
}

#pragma mark - MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
#ifdef DEBUG
    if ((result == MFMailComposeResultFailed) && (error != NULL)) NSLog(@"%@", error);
#endif
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIDocumentInteractionControllerDelegate methods

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    documentInteraction = nil;
}

#pragma mark - ThumbsViewControllerDelegate methods

- (void)thumbsViewController:(ThumbsViewController *)viewController gotoPage:(NSInteger)page
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    [self showDocumentPage:page];
    
#endif // end of READER_ENABLE_THUMBS Option
}

- (void)dismissThumbsViewController:(ThumbsViewController *)viewController
{
#if (READER_ENABLE_THUMBS == TRUE) // Option
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
#endif // end of READER_ENABLE_THUMBS Option
}

#pragma mark - ReaderMainPagebarDelegate methods

- (void)pagebar:(ReaderMainPagebar *)pagebar gotoPage:(NSInteger)page
{
    [self showDocumentPage:page];
}

#pragma mark - UIApplication notification methods

- (void)applicationWillResign:(NSNotification *)notification
{
    [document archiveDocumentProperties]; // Save any ReaderDocument changes
    
    if (userInterfaceIdiom == UIUserInterfaceIdiomPad) if (printInteraction != nil) [printInteraction dismissAnimated:NO];
}






#pragma mark - ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
    [self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

//- (void)crop:(NSInteger)nPage
//{
//    [self dismissViewControllerAnimated:YES completion:^{
//
//
//
//        //        TOCropViewController *cropController = [[TOCropViewController alloc] initWithImage:self.i_Data];
//        //        cropController.delegate = self;
//        //        [self presentViewController:cropController animated:YES completion:nil];
//
//        CGSize imageSize = self.view.bounds.size;
//        UIImage *image = nil;
//
//        NSString *str_Path = [[NSUserDefaults standardUserDefaults] objectForKey:@"pdfUrl"];
//        image = [UIImage originalSizeImageWithPDFURL:[NSURL fileURLWithPath:str_Path] atPage:nPage];
//        if( image == nil )
//        {
//            image = [UIImage originalSizeImageWithPDFURL:[NSURL URLWithString:str_Path] atPage:nPage];
//        }
//
//
////        if( str_Path )
////        {
////            image = [UIImage originalSizeImageWithPDFURL:[NSURL URLWithString:str_Path] atPage:nPage];
////        }
////        else
////        {
////            image = [UIImage originalSizeImageWithPDFNamed:@"test.pdf" atPage:nPage];
////        }
//
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
//        //        imageView.backgroundColor = [UIColor whiteColor];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        imageView.image = image;
//        imageView.tintColor = [UIColor whiteColor];
//
//        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        QuestionTypeViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionTypeViewController"];
//        vc.i_Data = image;
//        vc.str_Title = [[NSUserDefaults standardUserDefaults] objectForKey:@"QTitle"];
//        vc.str_SubTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"QSubTitle"];
//        vc.dic_School = [[NSUserDefaults standardUserDefaults] objectForKey:@"QSchool"];
//        vc.nSchoolLevel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"QSchoolLevel"] integerValue];
//        vc.isContinue = YES;
//
//        [self.navigationController pushViewController:vc animated:NO];
//
//        //        InputAnswerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InputAnswerViewController"];
//        //        vc.str_Idx = self.str_Idx;
//        //        vc.i_Data = image;
//        //        vc.str_Title = [[NSUserDefaults standardUserDefaults] objectForKey:@"QTitle"];
//        //        vc.str_SubTitle = [[NSUserDefaults standardUserDefaults] objectForKey:@"QSubTitle"];
//        //        vc.dic_School = [[NSUserDefaults standardUserDefaults] objectForKey:@"QSchool"];;
//        //        vc.nSchoolLevel = [[[NSUserDefaults standardUserDefaults] objectForKey:@"QSchoolLevel"] integerValue];;
//        //
//        //        [self.navigationController pushViewController:vc animated:NO];
//    }];
//}


#pragma mark - ContentsScrollViewDelegate
- (void)onContentsDidScroll:(NSNotification *)noti
{
    UIScrollView *sv = [noti object];
    if( fOldScale > sv.zoomScale )
    {
        [UIView animateWithDuration:0.3f animations:^{
            if( self.isWrong == NO && self.isStar )
            {
                self.v_Bottom.alpha = self.v_Answer.alpha = self.v_AnswerNonNumber.alpha = self.v_AudioContainer.alpha = NO;
            }
            else
            {
//                self.v_Bottom.alpha = self.v_Answer.alpha = self.v_AnswerNonNumber.alpha = self.v_AudioContainer.alpha = NO;
            }
            
            [self.view endEditing:YES];
            [self stopAudio];
        }];
    }
}

- (void)updateTimer:(NSNotification *)noti
{
    //    [self.v_Title.btn_Time setTitle:[NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond] forState:UIControlStateNormal];

    if( self.isOwerMode )
    {
        [self.btn_Time setTitle:noti.object forState:UIControlStateNormal];
        [self.btn_PauseTime setTitle:noti.object forState:UIControlStateNormal];
    }
    else
    {
        [self.btn_Time setTitle:self.vc_Parent.v_Title.btn_Time.titleLabel.text forState:UIControlStateNormal];
        [self.btn_PauseTime setTitle:self.vc_Parent.v_Title.btn_Time.titleLabel.text forState:UIControlStateNormal];
    }
}


#pragma mark - IBAction
- (IBAction)goBack:(id)sender
{
    [Common removeAllPdfFile];
    
    if( self.isOwerMode )
    {
        self.str_StartIdx = self.str_BeforeIdx;
        self.isWrong = self.isBeforeWrong;
        self.isStar = self.isBeforeStar;
        
        [self updateListWithFit:YES];
        
        [self moveToPage:[NSString stringWithFormat:@"%ld", [self.str_BeforeIdx integerValue]]];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"backNoti" object:nil];
        }];
    }
//    [self.navigationController popViewControllerAnimated:NO];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"popVc" object:nil];

//    [self.navigationController popToRootViewControllerAnimated:YES];
    
    
    NSInteger nTesterId = [[self.dic_ExamUserInfo objectForKey_YM:@"testerId"] integerValue];
    if( nTesterId > 0 )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [NSString stringWithFormat:@"%@", [self.dic_ExamUserInfo objectForKey:@"testerId"]], @"testerId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/exit/solve/exam"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                //                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatReloadNoti" object:nil];
                                            }
                                        }];
    }
}

- (IBAction)goPlayToggle:(id)sender
{
    if( self.btn_Time.selected )
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.v_Pause.alpha = NO;
            [self.v_Audio resume];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.v_Pause.alpha = YES;
            
            if( self.dic_AudioInfo )
            {
                if( self.v_Audio )
                {
                    [self.v_Audio pause];
                }
            }
        }];
    }
    
    self.btn_Time.selected = !self.btn_Time.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kPauseTimer" object:nil];
}

- (IBAction)goSideMenu:(id)sender
{
    if( self.isWrong || self.isStar )
    {
        [self showWrongSideMenu];
    }
    else
    {
        __weak __typeof(&*self)weakSelf = self;
        
        //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        self.vc_SideMenuViewController = [kEtcBoard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
        self.vc_SideMenuViewController.str_TesterId = [NSString stringWithFormat:@"%@", [self.dic_ExamUserInfo objectForKey:@"testerId"]];
        self.vc_SideMenuViewController.str_Idx = self.str_Idx;
        //    vc.str_StartNo = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
//        self.vc_SideMenuViewController.str_StartNo = self.str_StartIdx;
        if( self.dic_CurrentQuestion )
        {
            self.vc_SideMenuViewController.str_StartNo = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examNo"] integerValue]];
        }
        else
        {
            self.vc_SideMenuViewController.str_StartNo = self.str_StartIdx;
        }
        self.vc_SideMenuViewController.str_ChannelId = self.str_ChannelId;
        
        [self.vc_SideMenuViewController setCompletionBlock:^(id completeResult) {
            
            NSDictionary *dic = [completeResult objectForKey:@"obj"];
            NSInteger nExamNo = [[dic objectForKey:@"examNo"] integerValue];
            NSInteger nPdfPage = [[completeResult objectForKey:@"pdfPage"] integerValue];
            [weakSelf showDocumentPage:nPdfPage];
            
            [weakSelf.dicM_Parameter setObject:[NSString stringWithFormat:@"%ld", weakSelf.currentPage] forKey:@"pdfPage"];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                                param:weakSelf.dicM_Parameter
                                           withMethod:@"GET"
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [MBProgressHUD hide];
                                                
                                                if( resulte )
                                                {
                                                    weakSelf.ar_Question = [resulte objectForKey:@"questionInfos"];
                                                    [weakSelf updateQuestionStatusWithUpdateCount:NO];
                                                    
                                                    for( NSInteger i = 0; i < weakSelf.ar_Question.count; i++ )
                                                    {
                                                        NSDictionary *dic_Sub = weakSelf.ar_Question[i];
                                                        NSInteger nCurrentExamNo = [[dic_Sub objectForKey:@"examNo"] integerValue];
                                                        
                                                        NSArray *ar_Tmp = [dic_Sub objectForKey:@"examQuestionInfos"];
                                                        if( ar_Tmp.count <= 0 ) return;
                                                        
                                                        NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                                                        if( nExamNo == nCurrentExamNo )
                                                        {
                                                            [weakSelf performSelector:@selector(onShowZoomInterval:) withObject:@{@"dic_Sub":dic_Sub, @"dic_PdfInfo":dic_PdfInfo} afterDelay:0.3f];
                                                            break;
                                                        }
                                                    }
                                                }
                                            }];
            
            
            
        }];
        
        [self presentViewController:self.vc_SideMenuViewController animated:NO completion:^{
            
        }];
    }
}

- (void)showWrongSideMenu
{
    __weak __typeof(&*self)weakSelf = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    WrongSideViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"WrongSideViewController"];
//    vc.str_TesterId = [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey_YM:@"testerId"]];
    vc.str_Idx = self.str_Idx;
    vc.str_StartNo = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
    vc.nNowQuestionNum = [[self.dic_CurrentQuestion objectForKey:@"examNo"] integerValue];
    vc.str_SubjectName = self.str_SubjectName;
    vc.listType = self.isWrong ? kWrong : kStarQ;
    
    [vc setCompletionBlock:^(id completeResult) {
        
        NSDictionary *dic = [completeResult objectForKey:@"obj"];
        
        NSInteger nExamNo = [[completeResult objectForKey:@"idx"] integerValue];
        weakSelf.str_StartIdx = [NSString stringWithFormat:@"%ld", nExamNo];
        [weakSelf performSelector:@selector(onMoveToPageInterval) withObject:nil afterDelay:0.3f];
    }];
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}

- (void)onMoveToPageInterval
{
    [self moveToPage:self.str_StartIdx];
}

- (void)onShowZoomInterval:(NSDictionary *)dic
{
    [self showZoom:[dic objectForKey:@"dic_Sub"] withPdfInfo:[dic objectForKey:@"dic_PdfInfo"]];
}

- (void)showZoom:(NSDictionary *)dic withPdfInfo:(NSDictionary *)dic_PdfInfo
{
    NSNumber *key = [NSNumber numberWithInteger:self.currentPage];
    ReaderContentView *targetView = [contentViews objectForKey:key];
    targetView.isWrong = (self.isWrong || self.isStar );
    
    CGFloat fWidth = [[dic_PdfInfo objectForKey:@"width"] floatValue];
    CGFloat fHeight = [[dic_PdfInfo objectForKey:@"height"] floatValue];
    
    CGFloat fScale = (self.view.bounds.size.width) / fWidth;
    fOldScale = fScale;
    CGFloat fStartX = [[dic_PdfInfo objectForKey:@"startX"] floatValue];
    CGFloat fStartY = [[dic_PdfInfo objectForKey:@"startY"] floatValue];
    
    if( self.isWrong == NO && self.isStar == NO )
    {
        self.lb_QCurrentCnt.text = self.lb_PauseQCurrentCnt.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examNo"]];
    }
    
    //답 갯수
    correctAnswerCount = [[dic objectForKey:@"correctAnswerCount"] integerValue];
//    correctAnswerCount = 2;
    
    if( correctAnswerCount > 1 )
    {
        CGRect frame = self.btn_Correct.frame;
        frame.origin.x = -20;
        frame.size.width = 50;
        self.btn_Correct.frame = frame;
        
        frame = self.btn_MyCorrect.frame;
        frame.origin.x = 15;
        frame.size.width = 50;
        self.btn_MyCorrect.frame = frame;
    }
    else
    {
        CGRect frame = self.btn_Correct.frame;
        frame.origin.x = -10;
        frame.size.width = 40;
        self.btn_Correct.frame = frame;
        
        frame = self.btn_MyCorrect.frame;
        frame.origin.x = 15;
        frame.size.width = 40;
        self.btn_MyCorrect.frame = frame;
    }
    
    
    //보기 갯수
    itemCount = [[dic objectForKey:@"itemCount"] integerValue];
    
    //객관식 여부
    isNumberQuestion = [[dic objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
    
    if( isNumberQuestion == NO )
    {
        self.v_Correct.hidden = YES;
        self.v_NonNumberCorrect.hidden = NO;
        
        id userCorrect = [dic objectForKey:@"user_correct"];
        NSString *str_UserCorrect = [dic objectForKey:@"user_correct"];
        if( [userCorrect isEqual:[NSNull null]] == NO && str_UserCorrect.length > 0 )
        {
            self.btn_Menu.hidden = YES;
            
            self.lc_AnswerNonNumberBottom.constant = 0;

            self.btn_PdfNext.hidden = NO;
            
            //푼 문제
            NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"user_correct"]];
            
            //정답
            NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
            str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            self.lb_StringCorrent.text = str_Correct;
            self.lb_StringMyCorrent.text = str_UserCorrect;
            
            if( [str_Correct isEqualToString:str_UserCorrect] )
            {
                //맞은
                self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
            }
            else
            {
                //틀린
                self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];
            }
        }
        else
        {
            self.btn_Menu.hidden = NO;
            self.v_NonNumberCorrect.hidden = YES;
            self.btn_PdfNext.hidden = YES;
        }
    }
    else
    {
        self.v_Correct.hidden = NO;
        self.v_NonNumberCorrect.hidden = YES;
        
        NSInteger nMyStarCnt = [[dic objectForKey:@"existStarCount"] integerValue];
        if( nMyStarCnt > 0 )
        {
            self.btn_Star.selected = YES;
        }
        else
        {
            self.btn_Star.selected = NO;
        }
        
        [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
        
        id userCorrect = [dic objectForKey:@"user_correct"];
        NSString *str_UserCorrect = [dic objectForKey:@"user_correct"];
        if( [userCorrect isEqual:[NSNull null]] == NO && str_UserCorrect.length > 0 )
        {
            self.btn_Menu.hidden = YES;
            self.v_Correct.hidden = NO;
            self.v_NonNumberCorrect.hidden = YES;
            if( self.isWrong == NO && self.isStar == NO )
            {
                self.btn_PdfNext.hidden = NO;
            }
//            self.lc_AnswerBottom.constant = -100;
            
            //푼 문제
            NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_correct"]];
            
            //정답
            NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
            str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];

            if( [str_UserCorrect isEqualToString:str_Correct] )
            {
                //맞은문제
                self.btn_Correct.hidden = NO;
                self.btn_MyCorrect.hidden = NO;
                
                str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                
                [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                [self.btn_MyCorrect setTitle:str_UserCorrect forState:UIControlStateNormal];
                
//                [self.btn_Correct setBackgroundColor:kMainColor];
                [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"4388FA"]];
                
//                self.btn_Correct.layer.cornerRadius = self.btn_Correct.frame.size.width / 2;
//                self.btn_MyCorrect.layer.cornerRadius = self.btn_MyCorrect.frame.size.width / 2;
//                self.btn_MyCorrect.layer.borderColor = [UIColor redColor].CGColor;
//                self.btn_MyCorrect.layer.borderWidth = 1.f;
            }
            else
            {
                //틀린문제
                self.btn_MyCorrect.hidden = self.btn_Correct.hidden = NO;
                
                str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
                
                [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
                [self.btn_MyCorrect setTitle:str_UserCorrect forState:UIControlStateNormal];
                
//                [self.btn_Correct setBackgroundColor:kMainColor];
                [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
                
//                self.btn_Correct.layer.cornerRadius = self.btn_Correct.frame.size.width / 2;
//                self.btn_MyCorrect.layer.cornerRadius = self.btn_MyCorrect.frame.size.width / 2;
//                self.btn_MyCorrect.layer.borderColor = [UIColor redColor].CGColor;
//                self.btn_MyCorrect.layer.borderWidth = 1.f;
            }
        }
        else
        {
            self.btn_Menu.hidden = NO;
            self.v_Correct.hidden = YES;
            self.v_NonNumberCorrect.hidden = YES;
            self.btn_PdfNext.hidden = YES;
            
            self.v_PageControllerView4.btn_1.selected = self.v_PageControllerView4.btn_2.selected =
            self.v_PageControllerView4.btn_3.selected = self.v_PageControllerView4.btn_4.selected = NO;
            
            self.v_PageControllerView2.btn_1.selected = self.v_PageControllerView2.btn_2.selected = NO;
            
            if( correctAnswerCount > 1 )
            {
                //            self.lb_MultiAnswer.text = [NSString stringWithFormat:@"이 문제는 정답이 %ld개 입니다.", correctAnswerCount];
                self.lb_MultiAnswer.hidden = NO;
                self.v_PageControllerView4.hidden = NO;
                self.v_PageControllerView2.hidden = YES;
            }
            else
            {
                //            self.lb_MultiAnswer.text = @"";
                self.lb_MultiAnswer.hidden = YES;
                self.v_PageControllerView4.hidden = YES;
                self.v_PageControllerView2.hidden = NO;
            }
        }
    }
    
    nQnaCount= [[dic objectForKey:@"qnaCount"] integerValue] + [[dic objectForKey:@"explainCount"] integerValue];
    [self.btn_Comment setTitle:[NSString stringWithFormat:@"풀이 %ld", nQnaCount] forState:UIControlStateNormal];
    
    self.dic_CurrentQuestion = dic;
    self.dic_CurrentPdf = dic_PdfInfo;
    
    self.v_Bottom.str_QId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];

    [self updateAnswerView];
    
    for( UIView *subView in self.v_Answer.subviews )
    {
        if( subView.tag > 0 )
        {
            subView.hidden = YES;
        }
    }
    
    for( UIView *subView in self.v_Answer.subviews )
    {
        if( subView.tag == itemCount )
        {
            self.v_Number = subView;
            break;
        }
    }
    
    self.v_Number.hidden = NO;
    for( id subView in self.v_Number.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn = (UIButton *)subView;
            if( btn.tag > 0 )
            {
                btn.selected = NO;
                btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn setBackgroundColor:[UIColor whiteColor]];
                [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateSelected];
            }
        }
    }
    
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.v_Bottom.alpha = self.v_Answer.alpha = self.v_AnswerNonNumber.alpha = self.v_AudioContainer.alpha = YES;
        [self addAudioView];
        
        if( self.isWrong == NO && self.isStar == NO )
        {
            targetView.zoomScale = fScale;
            
            if( (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight ||
               (long)[[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft )
            {
                //가로일때
                [targetView setContentOffset:CGPointMake(fStartX * fScale, (fStartY * fScale) - (self.dic_AudioInfo ? (20.f * fScale) : 0)) animated:NO];
            }
            else
            {
                //세로일때
                [targetView setContentOffset:CGPointMake(fStartX * fScale, (fStartY * fScale) - (self.dic_AudioInfo ? (48.f * fScale) : 0)) animated:NO];
            }
        }
        else
        {
            targetView.zoomScale = fScale;
//            [targetView setContentOffset:CGPointMake(targetView.contentOffset.x, (self.dic_AudioInfo ? -64.f : 0)) animated:NO];
            [targetView setContentOffset:CGPointMake(targetView.contentOffset.x, (self.dic_AudioInfo ? 0 : 0)) animated:NO];
        }
    }completion:^(BOOL finished) {
        
        if( self.isWrong == NO && self.isStar == NO )
        {
//            UIImageView *tmp = (UIImageView *)[targetView viewWithTag:[[dic objectForKey:@"questionId"] integerValue]];
//            UIImageView *iv_Guide = nil;
//            if( tmp == nil )
//            {
//                iv_Guide = [[UIImageView alloc] initWithFrame:CGRectMake((fStartX * fScale) - 2, (fStartY * fScale) + 2,
//                                                                         (fWidth * fScale) - 8, (fHeight * fScale))];
//            }
//            else
//            {
//                iv_Guide = tmp;
//            }
//            
//            iv_Guide.tag = [[dic objectForKey:@"questionId"] integerValue];
//            iv_Guide.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
//            iv_Guide.layer.borderWidth = 1.f;
//            [targetView addSubview:iv_Guide];
            
            targetView.nSelectedIdx = [[dic objectForKey:@"questionId"] integerValue];
            
            UIImageView *iv_Guide = (UIImageView *)[targetView viewWithTag:2222];
            if( iv_Guide )
            {
                [iv_Guide removeFromSuperview];
            }
            
            iv_Guide = [[UIImageView alloc] initWithFrame:CGRectMake((fStartX * fScale) - 2, (fStartY * fScale),
                                                                     (fWidth * fScale) - 4, (fHeight * fScale))];
            iv_Guide.tag = 2222;
            iv_Guide.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
            iv_Guide.layer.borderWidth = 1.f;
            [targetView addSubview:iv_Guide];
            
//            iv_Guide.tag = [[dic objectForKey:@"questionId"] integerValue];
        }
        

        targetView.ar_Guide = self.ar_Question;
    }];
    
    id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
    NSString *str_UserCorrect = [self.dic_CurrentQuestion objectForKey_YM:@"user_correct"];
    if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
    {
        
    }
    else
    {
        NSInteger nExamNo = [[self.dic_CurrentQuestion objectForKey:@"examNo"] integerValue];
        if( nExamNo < nTotalQCnt )
        {
            if( self.isWrong == NO && self.isStar == NO )
            {
                self.btn_PdfNext.hidden = NO;
            }
        }
        else
        {
            if( self.isWrong == NO && self.isStar == NO )
            {
                self.btn_PdfNext.hidden = YES;
            }
        }
    }
}

- (IBAction)goZoomOut:(id)sender
{
    if( self.ar_Question.count >= 2 )
    {
        if( self.isWrong == NO && self.isStar == NO )
        {
            NSDictionary *dic_First = [self.ar_Question firstObject];
            NSDictionary *dic_Last = [self.ar_Question lastObject];
            self.lb_QCurrentCnt.text = self.lb_PauseQCurrentCnt.text = [NSString stringWithFormat:@"%@ ~ %@", [dic_First objectForKey:@"examNo"], [dic_Last objectForKey:@"examNo"]];
        }
    }
    
    NSNumber *key = [NSNumber numberWithInteger:self.currentPage];
    __block ReaderContentView *targetView = [contentViews objectForKey:key];
    targetView.isWrong = (self.isWrong || self.isStar );

    [UIView animateWithDuration:0.3f animations:^{
        targetView.zoomScale = fOriginalScale;
        self.v_Bottom.alpha = self.v_Answer.alpha = self.v_AnswerNonNumber.alpha = self.v_AudioContainer.alpha = NO;
        [self.view endEditing:YES];
        [self stopAudio];
    }];
}

- (void)updateAnswerView
{
    id userCorrect = [self.dic_CurrentQuestion objectForKey:@"user_correct"];
    NSString *str_UserCorrect = [self.dic_CurrentQuestion objectForKey_YM:@"user_correct"];
    if( [userCorrect isEqual:[NSNull null]] || str_UserCorrect.length <= 0 )
    {
        //안푼문제
        correctAnswerCount = [[self.dic_CurrentQuestion objectForKey:@"correctAnswerCount"] integerValue];
        //    correctAnswerCount = 2;
        
        //보기 갯수
        itemCount = [[self.dic_CurrentQuestion objectForKey:@"itemCount"] integerValue];
        
        //객관식 여부
        isNumberQuestion = [[self.dic_CurrentQuestion objectForKey:@"isMultipleChoice"] isEqualToString:@"Y"];
        
        if( correctAnswerCount > 1 )
        {
            self.v_PageControllerView4.hidden = NO;
            self.v_PageControllerView2.hidden = YES;
        }
        else
        {
            self.v_PageControllerView4.hidden = YES;
            self.v_PageControllerView2.hidden = NO;
        }
        
        for( UIView *subView in self.v_Answer.subviews )
        {
            if( subView.tag > 0 )
            {
                subView.hidden = YES;
            }
        }
        
        for( UIView *subView in self.v_Answer.subviews )
        {
            if( subView.tag == itemCount )
            {
                self.v_Number = subView;
                break;
            }
        }
        
        self.v_Number.hidden = NO;
        for( id subView in self.v_Number.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn = (UIButton *)subView;
                if( btn.tag > 0 )
                {
                    btn.selected = NO;
                    btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                    [btn setBackgroundColor:[UIColor whiteColor]];
                    [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor colorWithHexString:@"EDB900"] forState:UIControlStateSelected];
                }
            }
        }
        
        if( isNumberQuestion )
        {
            //객관식 올리기
            self.lc_AnswerBottom.constant = 0;
        }
        else
        {
            //주관식 올리기
            self.lc_AnswerNonNumberBottom.constant = 0;
        }

//        self.lc_AnswerBottom.constant = 0;
    }
    else
    {
        //푼문제
        if( isNumberQuestion )
        {
            //객관식 올리기
            self.lc_AnswerBottom.constant = -164.f;
        }
        else
        {
            //주관식 올리기
            self.lc_AnswerNonNumberBottom.constant = -164.f;
        }

//        self.lc_AnswerBottom.constant = -100;
    }
}

- (IBAction)goAnswer:(id)sender
{
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        if( isNumberQuestion )
        {
            //객관식 올리기
            self.lc_AnswerBottom.constant = 0;
        }
        else
        {
            //주관식 올리기
            self.lc_AnswerNonNumberBottom.constant = 0;
        }
        
        self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height) * -1;

        [self.view layoutIfNeeded];
    }];
}

- (IBAction)goAnswerClose:(id)sender
{
    [self.view layoutIfNeeded];
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        if( isNumberQuestion )
        {
            //객관식 내리기
            self.lc_AnswerBottom.constant = -164.f;
        }
        else
        {
            //주관식 내리기
            self.lc_AnswerNonNumberBottom.constant = -164.f;
        }
        
        self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1;
        
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)goSelectNumber:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    
    str_MyCorrect = [NSMutableString string];
    
    if( correctAnswerCount > 1 )
    {
        //다중 답일 경우
        if( btn.selected )
        {
            if( [btn.backgroundColor isEqual:kMainColor] )
            {
                btn.selected = NO;
                btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn setBackgroundColor:[UIColor whiteColor]];
            }
            else
            {
                [btn setBackgroundColor:kMainColor];
                
                NSInteger nSelectedCnt = 0;
                UIView *superView = [btn superview];
                for( UIButton *btn_Sub in superView.subviews )
                {
                    if( btn_Sub.selected && [btn_Sub.backgroundColor isEqual:kMainColor] )
                    {
                        nSelectedCnt++;
                        
                        [str_MyCorrect appendString:btn_Sub.titleLabel.text];
                        [str_MyCorrect appendString:@","];
                    }
                }

                if( [str_MyCorrect hasSuffix:@","] )
                {
                    [str_MyCorrect deleteCharactersInRange:NSMakeRange([str_MyCorrect length]-1, 1)];
                }
                
                //정답 갯수와 같으면 정답 전송
                if( nSelectedCnt == correctAnswerCount )
                {
                    //정답 갯수와 같음, 서버로 전송!
                    //우선 내가 선택한 답을 빨간색으로
                    NSArray *ar_CorrectTmp = [str_MyCorrect componentsSeparatedByString:@","];
                    UIView *superView = [btn superview];
                    for( UIButton *btn_Sub in superView.subviews )
                    {
                        if( btn_Sub.selected )
                        {
                            for( NSInteger i = 0; i < ar_CorrectTmp.count; i++ )
                            {
                                if( [btn_Sub.titleLabel.text isEqualToString:[ar_CorrectTmp objectAtIndex:i]] )
                                {
                                    [btn_Sub setBackgroundColor:[UIColor whiteColor]];
                                    btn_Sub.layer.borderColor = [UIColor redColor].CGColor;
                                    [btn_Sub setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                    [btn_Sub setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                                }
                            }
                        }
                    }
                    
                    //정답은 파란색으로
                    NSString *str_CorrectTmp = [self.dic_CurrentQuestion objectForKey:@"correctAnswer"];
                    ar_CorrectTmp = [str_CorrectTmp componentsSeparatedByString:@","];
                    for( UIButton *btn_Sub in superView.subviews )
                    {
                        if( btn_Sub.selected )
                        {
                            for( NSInteger i = 0; i < ar_CorrectTmp.count; i++ )
                            {
                                if( [btn_Sub.titleLabel.text isEqualToString:[ar_CorrectTmp objectAtIndex:i]] )
                                {
                                    //정답이면
                                    [btn_Sub setBackgroundColor:kMainColor];
                                    btn_Sub.layer.borderColor = kMainColor.CGColor;
                                    [btn_Sub setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                    [btn_Sub setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                                }
                            }
                        }
                    }
                    
                    
                    if( [str_CorrectTmp isEqualToString:str_MyCorrect] == NO )
                    {
                        //오답이면 진동
#if !TARGET_IPHONE_SIMULATOR
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
                    }
                    
                    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
                    
                    if( self.isWrong || self.isStar )
                    {
                        [self onShowResult:dic];
                    }
                    else
                    {
                        [self sendCorrect:dic];
                    }
                }
            }
        }
        else
        {
            [btn setBackgroundColor:[UIColor colorWithHexString:@"FFFF00"]];
            btn.selected = YES;
        }
    }
    else
    {
        UIView *superView = [btn superview];
        for( UIButton *btn_Sub in superView.subviews )
        {
            if( btn != btn_Sub )
            {
                btn_Sub.selected = NO;
                btn_Sub.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn_Sub setBackgroundColor:[UIColor whiteColor]];
            }
        }
        
        if( btn.selected )
        {
            if( self.dic_CurrentQuestion == nil )   return;
            
            UIView *superView = [btn superview];
            for( UIButton *btn_Sub in superView.subviews )
            {
                btn_Sub.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn_Sub setBackgroundColor:[UIColor whiteColor]];
            }
            
            //두번째 선택일 경우
            NSInteger nCorrect = [[self.dic_CurrentQuestion objectForKey:@"correctAnswer"] integerValue];
            str_MyCorrect = [NSMutableString stringWithString:btn.titleLabel.text];
            if( [[self.dic_CurrentQuestion objectForKey:@"correctAnswer"] isEqualToString:str_MyCorrect] == NO )
            {
                //정답이 아닐 경우
                [btn setBackgroundColor:[UIColor whiteColor]];
                btn.layer.borderColor = [UIColor redColor].CGColor;
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                
                //바이브레이션
#if !TARGET_IPHONE_SIMULATOR
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
            }
            
            //정답표현
            UIButton *btn_Correct = nil;
            for( UIView *v_Sub in self.v_Number.subviews )
            {
                if( v_Sub.tag > 0 )
                {
                    if( v_Sub.tag == nCorrect )
                    {
                        btn_Correct = (UIButton *)v_Sub;
                    }
                }
            }
            [btn_Correct setBackgroundColor:kMainColor];
            btn_Correct.layer.borderColor = kMainColor.CGColor;
            [btn_Correct setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn_Correct setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            
            NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
            
            if( self.isWrong || self.isStar )
            {
                [self onShowResult:dic];
            }
            else
            {
                [self sendCorrect:dic];
            }
        }
        else
        {
            UIView *superView = [btn superview];
            
            for( UIButton *btn in superView.subviews )
            {
                btn.layer.borderColor = [UIColor colorWithHexString:@"EDB900"].CGColor;
                [btn setBackgroundColor:[UIColor whiteColor]];
            }
            
            [btn setBackgroundColor:[UIColor colorWithHexString:@"FFFF00"]];
            btn.selected = YES;
        }
    }
    
    
    /////////페이지컨트롤러//////////
    NSInteger nBlueCnt = 0;
    NSInteger nYellowCnt = 0;
    UIView *superView = [btn superview];
    for( UIButton *btn_Sub in superView.subviews )
    {
        if( [btn_Sub.backgroundColor isEqual:kMainColor] )
        {
            nBlueCnt++;
        }
        
        if( [btn_Sub.backgroundColor isEqual:[UIColor colorWithHexString:@"FFFF00"]] )
        {
            nYellowCnt++;
        }

    }

    self.v_PageControllerView4.btn_1.selected = self.v_PageControllerView4.btn_2.selected =
    self.v_PageControllerView4.btn_3.selected = self.v_PageControllerView4.btn_4.selected = NO;

    NSInteger nFillCnt = (nBlueCnt * 2) + (nYellowCnt > 0 ? 1 : 0);
    NSLog(@"nFillCnt : %ld", nFillCnt);
    if( nFillCnt == 1 )
    {
        self.v_PageControllerView4.btn_1.selected = YES;
        
        self.v_PageControllerView2.btn_1.selected = YES;
    }
    else if( nFillCnt == 2 )
    {
        self.v_PageControllerView4.btn_1.selected = YES;
        self.v_PageControllerView4.btn_2.selected = YES;
        
        self.v_PageControllerView2.btn_1.selected = YES;
        self.v_PageControllerView2.btn_2.selected = YES;
    }
    else
    {
        if( correctAnswerCount > 1 )
        {
            if( nFillCnt == 3 )
            {
                self.v_PageControllerView4.btn_1.selected = YES;
                self.v_PageControllerView4.btn_2.selected = YES;
                self.v_PageControllerView4.btn_3.selected = YES;
            }
            else if( nFillCnt == 4 )
            {
                self.v_PageControllerView4.btn_1.selected = YES;
                self.v_PageControllerView4.btn_2.selected = YES;
                self.v_PageControllerView4.btn_3.selected = YES;
                self.v_PageControllerView4.btn_4.selected = YES;
            }
        }
    }
    ////////////////////////
}

- (void)sendCorrect:(NSDictionary *)dic
{
    NSInteger nExamNo = [[self.dic_CurrentQuestion objectForKey:@"examNo"] integerValue];
    if( nExamNo < nTotalQCnt )
    {
        self.btn_PdfNext.hidden = NO;
    }
    else
    {
        self.btn_PdfNext.hidden = YES;
    }

    /*************오답문제 다시 풀기일 경우***************/
    if( [self.str_SortType isEqualToString:@"inCorrectQuestionSolve"] )
    {
        if( isNumberQuestion )
        {
            [self onShowResult:dic];
            [self performSelector:@selector(onUpdateInterval) withObject:nil afterDelay:0.3f];
        }
        else
        {
            [self performSelector:@selector(onUpdateInterval) withObject:nil afterDelay:0.3f];
            
            self.lb_StringCorrent.hidden = self.lb_StringMyCorrent.hidden = NO;
            self.lb_StringCorrent.alpha = self.lb_StringMyCorrent.alpha = YES;
        }

        return;
    }
    /*********************************************************/
    
    if( isNumberQuestion )
    {
        __block NSString *str_UserCorrect = [str_MyCorrect stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            //                                        [NSString stringWithFormat:@"%@", [self.dic_UserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                            [NSString stringWithFormat:@"%@", [self.dic_ExamUserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                            str_UserCorrect, @"userAnswer", //사용자가 입력한 답
                                            [NSString stringWithFormat:@"%ld", self.vc_Parent.nTime * 1000], @"examLapTime",  //경과시간
                                            @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                            [NSString stringWithFormat:@"%ld", self.ar_Question.count], @"totalQuestionCount", //전체문제수
                                            @"on", @"setMode",
                                            nil];

        
        
        if( [Util getNetworkSatatus] == nil )
        {
            NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            
            //정답을 전송했지만 오프라인시 강제로 배열 안의 딕셔너리 값을 바꿔줌
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
            [dicM setObject:str_UserCorrect forKey:@"user_correct"];
            self.dic_CurrentQuestion = [NSDictionary dictionaryWithDictionary:dicM];
            
            for( NSInteger i = 0; i < self.ar_Question.count; i++ )
            {
                NSDictionary *dic_Tmp = [self.ar_Question objectAtIndex:i];
                NSInteger nQId = [[dic_Tmp objectForKey:@"questionId"] integerValue];
                NSInteger nRoopQId = [[self.dic_CurrentQuestion objectForKey:@"questionId"] integerValue];
                if( nQId == nRoopQId )
                {
                    [self.ar_Question replaceObjectAtIndex:i withObject:self.dic_CurrentQuestion];
                    [self goAnswerClose:nil];
                    
                    NSArray *ar_Tmp = [self.dic_CurrentQuestion objectForKey:@"examQuestionInfos"];
                    if( ar_Tmp.count <= 0 ) return;
                    NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                    [self showZoom:self.dic_CurrentQuestion withPdfInfo:dic_PdfInfo];
                    
                    [self performSelector:@selector(onUpdateInterval) withObject:nil afterDelay:0.3f];
                    break;
                }
            }
            
            NSMutableDictionary *dicM_Offline = [NSMutableDictionary dictionary];
            [dicM_Offline setObject:@"POST" forKey:@"method"];
            [dicM_Offline setObject:@"v1/regist/exam/question/user/answer" forKey:@"path"];
            [dicM_Offline setObject:dicM_Params forKey:@"params"];
            
            //                        NSMutableArray *arM = [NSMutableArray array];
            
            NSMutableArray *arM = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"OfflineCall"]];
            if( arM == nil )
            {
                arM = [NSMutableArray array];
            }
            [arM addObject:dicM_Offline];
            [[NSUserDefaults standardUserDefaults] setObject:arM forKey:@"OfflineCall"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        
        
        
        
        
        
        
        __weak __typeof(&*self)weakSelf = self;
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                //                                            [self.dicM_Parameter setObject:@"solve" forKey:@"solveMode"];
                                                
                                                [weakSelf onShowResult:dic];
                                                [weakSelf performSelector:@selector(onUpdateInterval) withObject:nil afterDelay:0.3f];
                                                [weakSelf onShowResultIfNeed:resulte];
                                            }
                                        }];
    }
    else
    {
        __weak __typeof(&*self)weakSelf = self;

        //주관식이면
        str_MyCorrect = [NSMutableString string];
        NSString *str_CorrectTmp = [dic objectForKey:@"correctAnswer"];
        [str_MyCorrect appendString:self.tf_NonNumberAnswer1.text];
        
        self.lb_StringCorrent.text = @"";
//        self.lb_StringMyCorrent.text = @"";
        self.lb_StringMyCorrent.text = str_MyCorrect;

        self.v_Bottom.lc_BottomViewBottom.constant = (self.view.frame.size.height - 73) * -1;
        self.v_NonNumberCorrect.hidden = NO;
        
        if( [str_CorrectTmp isEqualToString:str_MyCorrect] == NO )
        {
            //오답이면 진동
#if !TARGET_IPHONE_SIMULATOR
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
#endif
            
            self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];
            
            //                NSString *str_Full = [NSString stringWithFormat:@"%@ %@", str_MyCorrect, str_CorrectTmp];
            //
            //                NSMutableAttributedString *str_Attr = [[NSMutableAttributedString alloc] initWithString:str_Full];
            //
            //                NSRange myCorrectRange = NSMakeRange(0, str_MyCorrect.length);
            //                NSRange correctRange = NSMakeRange(str_MyCorrect.length, str_Full.length - str_MyCorrect.length);
            //
            //                NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor redColor] };
            //                [str_Attr addAttributes:attrs range:myCorrectRange];
            //
            //                attrs = @{ NSStrikethroughStyleAttributeName : @2 };
            //                [str_Attr addAttributes:attrs range:myCorrectRange];
            //
            //                attrs = @{ NSForegroundColorAttributeName : [UIColor blueColor] };
            //                [str_Attr addAttributes:attrs range:correctRange];
            //
            //                weakSelf.tf_NonNumberAnswer1.attributedText = str_Attr;
            //
            //                [self.view endEditing:YES];
            //                self.lc_AnswerNonNumberBottom.constant = 0.f;
            //                self.lc_AnswerNonNumberCheckWidth1.constant = 0;
        }
        else
        {
            self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
            
            //                NSString *str_Full = [NSString stringWithFormat:@"%@", str_CorrectTmp];
            //
            //                NSMutableAttributedString *str_Attr = [[NSMutableAttributedString alloc] initWithString:str_Full];
            //
            //                NSRange correctRange = NSMakeRange(0, str_CorrectTmp.length);
            //
            //                NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor blueColor] };
            //                [str_Attr addAttributes:attrs range:correctRange];
            //
            //                weakSelf.tf_NonNumberAnswer1.attributedText = str_Attr;
            //
            //                [self.view endEditing:YES];
            //                self.lc_AnswerNonNumberBottom.constant = 0.f;
            //                self.lc_AnswerNonNumberCheckWidth1.constant = 0;
        }
        
        self.lb_StringCorrent.text = str_CorrectTmp;
        
        
        NSString *str_Tmp = self.tf_NonNumberAnswer1.text;
        NSArray *ar_MyCorrent = [str_Tmp componentsSeparatedByString:@","];
        //TODO: 정답전송
        NSMutableString *strM_Correct = [NSMutableString string];
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
        
        NSArray *ar_Sep = [str_Correct componentsSeparatedByString:@","];
        
        if( ar_MyCorrent.count < ar_Sep.count )
        {
            [self.navigationController.view makeToast:[NSString stringWithFormat:@"정답이 %ld개 입니다\n,로 구분해서 입력해 주세요", ar_Sep.count] withPosition:kPositionTop];
            self.lb_StringCorrent.text = @"";
            self.lb_StringMyCorrent.text = @"";
            self.btn_Menu.hidden = NO;
            return;
        }

        [self.view endEditing:YES];
        self.btn_Menu.hidden = YES;

        for( NSInteger i = 0; i < ar_Sep.count; i++ )
        {
            NSString *str_Tmp = ar_Sep[i];
            NSArray *ar_Tmp = [str_Tmp componentsSeparatedByString:@"-"];
            if( ar_Tmp.count > 1 )
            {
                NSString *str_Number = ar_Tmp[0];
                str_Number = [str_Number stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [strM_Correct appendString:str_Number];
                [strM_Correct appendString:@"-"];
                
                NSString *str_Tmp = ar_MyCorrent[i];
                NSString *str_MyCorrectTmp = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [strM_Correct appendString:str_MyCorrectTmp];
                [strM_Correct appendString:@"-"];
                [strM_Correct appendString:@"1"];
                [strM_Correct appendString:@","];
            }
            else
            {
                NSString *str_Tmp = ar_MyCorrent[i];
                NSString *str_MyCorrectTmp = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                [strM_Correct appendString:str_MyCorrectTmp];
                [strM_Correct appendString:@","];
            }
        }
        
        if( [strM_Correct hasSuffix:@","] )
        {
            [strM_Correct deleteCharactersInRange:NSMakeRange([strM_Correct length]-1, 1)];
        }
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [NSString stringWithFormat:@"%@", [self.dic_ExamUserInfo objectForKey:@"testerId"]], @"testerId",   //답안지 ID
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                            strM_Correct, @"userAnswer", //사용자가 입력한 답
                                            [NSString stringWithFormat:@"%ld", self.vc_Parent.nTime * 1000], @"examLapTime",  //경과시간
                                            @"1", @"answerClickCount",  //제권님이 우선 1로 보내라고 함
                                            [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswerCount"]], @"userCorrectAnswerCount",    //답 갯수
                                            [NSString stringWithFormat:@"%ld", self.ar_Question.count], @"totalQuestionCount", //전체문제수
                                            @"on", @"setMode",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/regist/exam/question/user/answer"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                //                                                    //                                            [self.dicM_Parameter setObject:@"solve" forKey:@"solveMode"];
                                                //
                                                //                                                    [weakSelf onShowResult:dic];
                                                [weakSelf performSelector:@selector(onUpdateInterval) withObject:nil afterDelay:0.3f];
                                                
                                                self.lb_StringCorrent.hidden = self.lb_StringMyCorrent.hidden = NO;
                                                self.lb_StringCorrent.alpha = self.lb_StringMyCorrent.alpha = YES;
                                                
                                                [weakSelf onShowResultIfNeed:resulte];
                                            }
                                        }];
        
        
        
        
        
        
        
        self.tf_NonNumberAnswer1.text = @"";
        self.tf_NonNumberAnswer2.text = @"";
        
    }
}

- (void)onShowResultIfNeed:(NSDictionary *)dic
{
    NSString *str_IsExamFinish = [dic objectForKey:@"isExamFinish"];
    if( [str_IsExamFinish isEqualToString:@"Y"] )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"결과를 확인하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 0 )
            {
                [self showResultView];
            }
        }];
    }
}

- (void)showResultView
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        //        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
        [self.navigationController.view makeToast:@"examId error" withPosition:kPositionCenter];
        return;
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }
    vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)onUpdateInterval
{
    [self updateListWithFit:NO];
    [self updateQuestionStatusWithUpdateCount:NO];
}

- (void)onShowResult:(NSDictionary *)dic
{
    [self goAnswerClose:nil];
    
    self.btn_Menu.hidden = YES;
    
    if( isNumberQuestion )
    {
        self.v_Correct.hidden = NO;
        self.v_Correct.alpha  = YES;
        
        self.v_NonNumberCorrect.hidden = YES;
    }
    else
    {
        self.v_Correct.hidden = YES;
        self.v_NonNumberCorrect.hidden = NO;
        self.lb_StringCorrent.alpha = YES;
        self.lb_StringMyCorrent.alpha = YES;
    }
    
    if( self.isWrong || self.isStar )
    {
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
        str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.lb_StringCorrent.text = str_Correct;
        
        self.lb_StringMyCorrent.text = self.tf_NonNumberAnswer1.text;
        
        if( [self.lb_StringCorrent.text isEqualToString:self.lb_StringMyCorrent.text] )
        {
            //맞은
            self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"4388FA"];
        }
        else
        {
            //틀린
            self.lb_StringMyCorrent.backgroundColor = [UIColor colorWithHexString:@"FF4F0C"];
        }
    }
    
//    [self.btn_Correct setBackgroundColor:kMainColor];
    [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
    
//    self.btn_Correct.layer.cornerRadius = self.btn_Correct.frame.size.width / 2;
//    self.btn_MyCorrect.layer.cornerRadius = self.btn_MyCorrect.frame.size.width / 2;
//    self.btn_MyCorrect.layer.borderColor = [UIColor redColor].CGColor;
//    self.btn_MyCorrect.layer.borderWidth = 1.f;
    
    NSString *str_Correct = [dic objectForKey:@"correctAnswer"];
    str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
    if( [str_Correct isEqualToString:str_MyCorrect] )
    {
//        self.btn_MyCorrect.hidden = YES;
        self.btn_MyCorrect.hidden = NO;
        [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"4388FA"]];
    }
    else
    {
        self.btn_MyCorrect.hidden = NO;
        [self.btn_MyCorrect setBackgroundColor:[UIColor colorWithHexString:@"FF4F0C"]];
    }
    
    [self.btn_MyCorrect setTitle:str_MyCorrect forState:UIControlStateNormal];
    
//    NSString *str_Correct = [dic objectForKey:@"correctAnswer"];
//    str_Correct = [str_Correct stringByReplacingOccurrencesOfString:@"|" withString:@","];
    [self.btn_Correct setTitle:str_Correct forState:UIControlStateNormal];
    
    for( UIButton *btn in self.v_Number.subviews )
    {
        if( btn.tag > 0 )
        {
            btn.selected = NO;
        }
    }
}

- (IBAction)goStarToggle:(id)sender
{
    if( self.isStar )
    {
        //별표 리스트일 경우엔 별표 리스트 삭제를 누른 효과와 동일하게 작동하게
        [self goWrongRemoveSelected:nil];
        return;
    }

    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                        !self.btn_Star.selected ? @"on" : @"off", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/question/star"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                if( self.btn_Star.selected )
                                                {
                                                    self.btn_Star.selected = NO;
                                                    
                                                    if( self.isWrong == NO && self.isStar == NO )
                                                    {
                                                        [self.dicM_Parameter setObject:[NSString stringWithFormat:@"%ld", self.currentPage] forKey:@"pdfPage"];
                                                        
                                                        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                                                                            param:self.dicM_Parameter
                                                                                       withMethod:@"GET"
                                                                                        withBlock:^(id resulte, NSError *error) {
                                                                                            
                                                                                            [MBProgressHUD hide];
                                                                                            
                                                                                            self.view.userInteractionEnabled = YES;
                                                                                            
                                                                                            if( resulte )
                                                                                            {
                                                                                                NSDictionary *dic_ExamPackageInfo = [resulte objectForKey:@"examPackageInfo"];
                                                                                                nTotalQCnt = [[dic_ExamPackageInfo objectForKey:@"questionCount"] integerValue];
                                                                                                self.ar_Question = [resulte objectForKey:@"questionInfos"];
                                                                                                self.dic_CurrentQuestion = [self.ar_Question objectAtIndex:self.nCurrentIdx];
                                                                                                [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
                                                                                                [self updateQuestionStatusWithUpdateCount:NO];
                                                                                            }
                                                                                        }];
                                                    }
                                                    else
                                                    {
                                                        self.view.userInteractionEnabled = YES;
                                                        [self updateWrong];
                                                    }
                                                }
                                                else
                                                {
                                                    self.iv_Star.hidden = NO;
                                                    
                                                    if( self.isWrong == NO && self.isStar == NO )
                                                    {
                                                        [self.dicM_Parameter setObject:[NSString stringWithFormat:@"%ld", self.currentPage] forKey:@"pdfPage"];
                                                        
                                                        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                                                                            param:self.dicM_Parameter
                                                                                       withMethod:@"GET"
                                                                                        withBlock:^(id resulte, NSError *error) {
                                                                                            
                                                                                            [MBProgressHUD hide];
                                                                                            
                                                                                            self.view.userInteractionEnabled = YES;
                                                                                            
                                                                                            if( resulte )
                                                                                            {
                                                                                                [self performSelector:@selector(onMoveStar) withObject:nil afterDelay:0.2f];
                                                                                                
                                                                                                NSDictionary *dic_ExamPackageInfo = [resulte objectForKey:@"examPackageInfo"];
                                                                                                nTotalQCnt = [[dic_ExamPackageInfo objectForKey:@"questionCount"] integerValue];
                                                                                                self.ar_Question = [resulte objectForKey:@"questionInfos"];
                                                                                                self.dic_CurrentQuestion = [self.ar_Question objectAtIndex:self.nCurrentIdx];
                                                                                                [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
                                                                                                [self updateQuestionStatusWithUpdateCount:NO];
                                                                                            }
                                                                                        }];
                                                    }
                                                    else
                                                    {
                                                        [self performSelector:@selector(onMoveStar) withObject:nil afterDelay:0.2f];
                                                        [self updateWrong];
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            self.view.userInteractionEnabled = YES;
                                        }
                                    }];
}
//남은거리 안맞음
//점 표시
//속도 숫자 바꿔주기

- (void)onMoveStar
{
    [UIView animateWithDuration:0.5f animations:^{
        
        self.iv_Star.frame = CGRectMake(80, self.view.bounds.size.height - 35, 25, 25);
    }completion:^(BOOL finished) {
        
        self.iv_Star.hidden = YES;
        self.iv_Star.frame = CGRectMake((self.view.bounds.size.width / 2) - 52, (self.view.bounds.size.height / 2) - 52, 104, 104);
        self.btn_Star.selected = YES;

//        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
//        NSInteger nStarCnt = [[dicM objectForKey:@"existStarCount"] integerValue];
//        [dicM setObject:[NSString stringWithFormat:@"%ld", ++nStarCnt] forKey:@"existStarCount"];
//        self.dic_CurrentQuestion = dicM;
//        
//        [self.ar_Question replaceObjectAtIndex:self.nCurrentIdx withObject:self.dic_CurrentQuestion];
//        [self updateQuestionStatusWithUpdateCount:NO];
        
        self.view.userInteractionEnabled = YES;
    }];
}

- (IBAction)goShowComment:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1] forKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    QuestionDiscriptionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionDiscriptionViewController"];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
//    vc.ar_Info = [self.dic_CurrentQuestion objectForKey:@"examExplainInfos"];
    vc.str_ExamId = self.str_Idx;
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }

    //    vc.str_ImagePreFix = self.str_ImagePreFix;
//    [self.navigationController pushViewController:vc animated:YES];
    [self presentViewController:navi animated:YES completion:nil];
    
}

- (IBAction)goStringAnswerSend:(id)sender
{
    if( self.tf_NonNumberAnswer1.text.length > 0 )
    {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:self.dic_CurrentQuestion];
        
        if( self.isWrong || self.isStar )
        {
            [self onShowResult:dic];
        }
        else
        {
            [self sendCorrect:dic];
        }
    }
}

- (IBAction)goShared:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
    SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
//    vc.str_ExamId = self.str_Idx;
    
    if( self.str_Idx == nil || self.str_Idx.length <= 0 )
    {
        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[self.dic_CurrentQuestion objectForKey:@"examId"] integerValue]];
    }
    else
    {
        vc.str_ExamId = self.str_Idx;
    }

    vc.str_QuestionId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
    vc.isModalMode = YES;
//    [self.navigationController pushViewController:vc animated:YES];
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
}

- (IBAction)goWrongRemoveSelected:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]], @"questionId",
                                        nil];
    
    NSString *str_Path = @"";
    if( self.isWrong )
    {
        str_Path = @"v1/hide/incorrect/question";
        
        if( self.btn_WrongTitle.selected )
        {
            [dicM_Params setObject:@"show" forKey:@"actionType"];
        }
        else
        {
            [dicM_Params setObject:@"hide" forKey:@"actionType"];
        }
    }
    else
    {
        if( self.btn_WrongTitle.selected )
        {
            [dicM_Params setObject:@"on" forKey:@"setMode"];
        }
        else
        {
            [dicM_Params setObject:@"off" forKey:@"setMode"];
        }
        
        str_Path = @"v1/set/exam/question/star";
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.btn_WrongTitle.selected = !weakSelf.btn_WrongTitle.selected;
                                                
                                                NSArray *ar = nil;
                                                if( self.isWrong )
                                                {
                                                    ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"inCorrectQuestionInfos"]];
                                                }
                                                else
                                                {
                                                    ar = [NSMutableArray arrayWithArray:[resulte objectForKey:@"starQuestionInfos"]];
                                                    
                                                    NSInteger nStartCnt = [self.btn_Star.titleLabel.text integerValue];
                                                    if( [[dicM_Params objectForKey:@"setMode"] isEqualToString:@"on"] )
                                                    {
                                                        self.btn_Star.selected = YES;
                                                        nStartCnt++;
                                                    }
                                                    else
                                                    {
                                                        self.btn_Star.selected = NO;
                                                        
                                                        nStartCnt--;
                                                        
                                                        if( nStartCnt < 0 )
                                                        {
                                                            nStartCnt = 0;
                                                        }
                                                    }
                                                    
                                                    [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", nStartCnt] forState:UIControlStateNormal];
                                                }
                                                
                                                for( NSInteger i = 0; i < ar.count; i++ )
                                                {
                                                    NSDictionary *dic = [ar objectAtIndex:i];
                                                    if( [[dic objectForKey:@"subjectName"] isEqualToString:self.str_SubjectName] )
                                                    {
                                                        self.str_SubjectTotalCount = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"questionCount"] integerValue]];
                                                        nTotalQCnt = [self.str_SubjectTotalCount integerValue];
                                                        self.lb_QTotalCnt.text = self.lb_PauseQTotalCnt.text = [NSString stringWithFormat:@"%ld", nTotalQCnt];
                                                    }
                                                }
                                            }
                                        }
                                    }];
}

- (IBAction)goPrev:(id)sender
{
    self.str_StartIdx = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] - 1];
    [self moveToPage:self.str_StartIdx];
}

- (IBAction)goNext:(id)sender
{
    self.str_StartIdx = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
    [self moveToPage:self.str_StartIdx];
}

- (void)moveToPage:(NSString *)aIdx
{
//    NSMutableArray *arM_Tmp = [self.vc_Parent.childViewControllers mutableCopy];
//    for( NSInteger i = 1; i < arM_Tmp.count; i++ )
//    {
//        id subViewController = [arM_Tmp objectAtIndex:i];
//        if( [subViewController isKindOfClass:[QuestionListSwipeViewController class]] )
//        {
//            UIViewController *vc_Tmp = (UIViewController *)subViewController;
//            [vc_Tmp removeFromParentViewController];
//        }
//    }

    if( [self.str_StartIdx integerValue] <= 1 )
    {
        self.v_Left.hidden = YES;
    }
    else if( [self.str_StartIdx integerValue] >= nTotalQCnt )
    {
        self.v_Right.hidden = YES;
    }
    else
    {
        self.v_Left.hidden = self.v_Right.hidden = NO;
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        aIdx, @"examNo",
                                        @"1", @"limitCount",
                                        self.str_SubjectName, @"subjectName",
                                        @"0", @"schoolGrade",
                                        @"0", @"personGrade",
                                        nil];
    __weak __typeof(&*self)weakSelf = self;
    
    NSString *str_Path = @"";
    if( self.isWrong )
    {
        str_Path = @"v1/get/my/incorrect/question/list";
    }
    else
    {
        str_Path = @"v1/get/my/star/question/list";
    }
    NSLog(@"SSSSSSSSSSSSSSSSSSS");
    
    NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
    NSString *str_Key = [NSString stringWithFormat:@"%ld_%@_%@", nMyId, self.str_SubjectName, aIdx];
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( data )
    {
        NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self move:dic withIdx:aIdx withParam:dicM_Params];
        return;
    }
    

    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        //pdfUrl = "000/000/b9bc2b6506e631e8a3118019f9b3b875.pdf_1916_25673_crop.pdf
                                        NSLog(@"EEEEEEEEEEEEEEEEEEE");
                                        if( resulte )
                                        {
                                            [self move:resulte withIdx:aIdx withParam:dicM_Params];
                                        }
                                    }];
}

- (void)move:(NSDictionary *)resulte withIdx:(NSString *)aIdx withParam:(NSMutableDictionary *)dicM_Params
{
    self.dic_Resulte = [NSDictionary dictionaryWithDictionary:resulte];
    
    NSMutableArray *arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
    if( arM.count > 0 )
    {
        NSDictionary *dic_QuestionInfos = [arM firstObject];
        self.dic_CurrentQuestion = [arM firstObject];
        [self updateAnswerView];
        correctAnswerCount = [[self.dic_CurrentQuestion objectForKey:@"correctAnswerCount"] integerValue];
        self.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
        self.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
        
        NSDictionary *dic_Tmp = [self.ar_Question firstObject];
        if( dic_Tmp )
        {
            //로컬 저장
            NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
            NSString *str_Key = [NSString stringWithFormat:@"%ld_%@_%@", nMyId, self.str_SubjectName, aIdx];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resulte];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        NSInteger nQnaCnt = [[dic_QuestionInfos objectForKey:@"explainCount"] integerValue] + [[dic_QuestionInfos objectForKey:@"qnaCount"] integerValue];
        
        [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[dic_QuestionInfos objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
        
        [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
        NSArray *ar_Tmp = [dic_QuestionInfos objectForKey:@"examQuestionInfos"];
        if( ar_Tmp.count > 0 )
        {
            NSDictionary *dic = [ar_Tmp firstObject];
            if( [[dic objectForKey:@"questionType"] isEqualToString:@"pdf"] )
            {
                NSString *str_Body = [dic_QuestionInfos objectForKey:@"pdfUrl"];
                NSArray *ar_Tmp = [str_Body componentsSeparatedByString:@"/"];
                NSString *str_FileName = [ar_Tmp lastObject];
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,str_FileName];
                BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
                if( fileExists )
                {
                    //                                                            [weakSelf dismissViewControllerAnimated:NO completion:^{
                    //
                    //                                                            }];
                    
                    NSMutableDictionary *dicM_Obj = [NSMutableDictionary dictionary];
                    [dicM_Obj setObject:resulte forKey:@"resulte"];
                    [dicM_Obj setObject:dicM_Params forKey:@"params"];
                    [dicM_Obj setObject:self.str_StartIdx forKey:@"startIdx"];
                    [dicM_Obj setObject:filePath forKey:@"filePath"];
                    
                    [self performSelector:@selector(onTest1:) withObject:dicM_Obj afterDelay:0.1f];
                    return ;
                    
                    ReaderDocument *document_Tmp = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                    document_Tmp.isLocalPDf = YES;
                    
                    if (document_Tmp != nil)
                    {
                        [Common setPdfDocument:document_Tmp];
                        
                        [self dismissViewControllerAnimated:NO completion:^{
                            
                        }];
                        
                        ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
                        self.navigationController.navigationBarHidden = YES;
                        vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                        vc.vc_Parent = self.vc_Parent;
                        vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                        vc.str_QTitle = self.lb_QTitle.text;
                        vc.dicM_Parameter = dicM_Params;
                        vc.str_Idx = self.str_Idx;
                        vc.str_StartIdx = self.str_StartIdx;
                        //                                                                vc.nStartPdfPage = self.nStartPdfPage;
                        vc.str_ChannelId = self.str_ChannelId;
                        vc.str_WrongTitle = self.lb_QTitle.text;
                        vc.isWrong = self.isWrong;
                        vc.isStar = self.isStar;
                        vc.str_SubjectName = self.str_SubjectName;
                        vc.dic_Resulte = [NSDictionary dictionaryWithDictionary:resulte];
                        vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
                        vc.str_Prefix = self.str_Prefix;
                        
                        if( self.isOwerMode )
                        {
                            vc.isOwerMode = NO;
                            vc.str_StartIdx = self.str_BeforeIdx;
                            //                                                                    vc.nStartPdfPage = [self.str_BeforeIdx integerValue];
                        }
                        else
                        {
                            vc.nStartPdfPage = 1;
                        }
                        
                        [vc setDocument:document_Tmp];
                        vc.view.backgroundColor = [UIColor whiteColor];
                        //                                                                vc.completeBlock = self.completeBlock;
                        
                        [self.vc_Parent presentViewController:vc animated:NO completion:^{
                            
                        }];
                    }
                }
                else
                {
                    NSString *str_Url = [NSString stringWithFormat:@"%@%@", [resulte objectForKey:@"img_prefix"], str_Body];
                    NSURL  *url = [NSURL URLWithString:str_Url];
                    NSData *urlData = [NSData dataWithContentsOfURL:url];
                    if ( urlData )
                    {
                        [urlData writeToFile:filePath atomically:YES];
                        
                        NSMutableDictionary *dicM_Obj = [NSMutableDictionary dictionary];
                        [dicM_Obj setObject:resulte forKey:@"resulte"];
                        [dicM_Obj setObject:dicM_Params forKey:@"params"];
                        [dicM_Obj setObject:self.str_StartIdx forKey:@"startIdx"];
                        [dicM_Obj setObject:filePath forKey:@"filePath"];
                        
                        [self performSelector:@selector(onTest1:) withObject:dicM_Obj afterDelay:0.1f];
                        return ;
                        
                        ReaderDocument *document_Tmp = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
                        document_Tmp.isLocalPDf = YES;
                        
                        if (document_Tmp != nil)
                        {
                            [Common setPdfDocument:document_Tmp];
                            
                            [self dismissViewControllerAnimated:NO completion:^{
                                
                            }];
                            
                            ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
                            self.navigationController.navigationBarHidden = YES;
                            vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                            vc.vc_Parent = self.vc_Parent;
                            vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
                            vc.str_QTitle = self.lb_QTitle.text;
                            vc.dicM_Parameter = dicM_Params;
                            vc.str_Idx = self.str_Idx;
                            vc.str_StartIdx = self.str_StartIdx;
                            //                                                                    vc.nStartPdfPage = self.nStartPdfPage;
                            vc.str_ChannelId = self.str_ChannelId;
                            vc.str_WrongTitle = self.lb_QTitle.text;
                            vc.isWrong = self.isWrong;
                            vc.isStar = self.isStar;
                            vc.str_SubjectName = self.str_SubjectName;
                            vc.dic_Resulte = [NSDictionary dictionaryWithDictionary:resulte];
                            vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
                            vc.isOwerMode = NO;
                            vc.str_Prefix = self.str_Prefix;
                            //                                                                    vc.nStartPdfPage = [self.str_BeforeIdx integerValue];
                            if( self.isOwerMode )
                            {
                                vc.isOwerMode = NO;
                                vc.str_StartIdx = self.str_BeforeIdx;
                                //                                                                        vc.nStartPdfPage = [self.str_BeforeIdx integerValue];
                            }
                            else
                            {
                                vc.nStartPdfPage = 1;
                            }
                            
                            [vc setDocument:document_Tmp];
                            vc.view.backgroundColor = [UIColor whiteColor];
                            //                                                                    vc.completeBlock = self.completeBlock;
                            
                            [self.vc_Parent presentViewController:vc animated:NO completion:^{
                                
                            }];
                        }
                    }
                }
            }
            else
            {
                //pdf가 아니면
                
                //                                                        if( weakSelf.completeBlock )
                if( 1 )
                {
                    NSMutableDictionary *dicM_Obj = [NSMutableDictionary dictionary];
                    [dicM_Obj setObject:resulte forKey:@"resulte"];
                    [dicM_Obj setObject:dicM_Params forKey:@"params"];
                    [dicM_Obj setObject:self.str_StartIdx forKey:@"startIdx"];
                    
                    [self performSelector:@selector(onTest2:) withObject:dicM_Obj afterDelay:0.1f];
                    
                    //                                                            weakSelf.completeBlock(weakSelf.str_StartIdx);
                    
                    return ;
                }
            }
        }
    }
    
    [self showDocument];
    
    [self updateListWithFit:NO];
}

- (void)onTest1:(NSDictionary *)dicM_Obj
{
    [self dismissViewControllerAnimated:NO completion:^{
        
        NSString *filePath = [dicM_Obj objectForKey:@"filePath"];
        NSDictionary *resulte = [dicM_Obj objectForKey:@"resulte"];
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithDictionary:[dicM_Obj objectForKey:@"dicM_Params"]];
        NSLog(@"시작");
        ReaderDocument *document_Tmp = [ReaderDocument withDocumentFilePath:filePath password:nil withLocalPdf:YES];
        document_Tmp.isLocalPDf = YES;
        
        if (document_Tmp != nil)
        {
            [Common setPdfDocument:document_Tmp];
            
            ReaderViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReaderViewController"];
            self.navigationController.navigationBarHidden = YES;
            vc.ar_Question = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
            vc.vc_Parent = self.vc_Parent;
            vc.dic_ExamUserInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examUserInfo"]];
            vc.str_QTitle = self.lb_QTitle.text;
            vc.dicM_Parameter = dicM_Params;
            vc.str_Idx = self.str_Idx;
            vc.str_StartIdx = self.str_StartIdx;
            //                                                                vc.nStartPdfPage = self.nStartPdfPage;
            vc.str_ChannelId = self.str_ChannelId;
            vc.str_WrongTitle = self.lb_QTitle.text;
            vc.isWrong = self.isWrong;
            vc.isStar = self.isStar;
            vc.str_SubjectName = self.str_SubjectName;
            vc.dic_Resulte = [NSDictionary dictionaryWithDictionary:resulte];
            vc.str_SubjectTotalCount = self.str_SubjectTotalCount;
            vc.str_Prefix = self.str_Prefix;
            
            if( self.isOwerMode )
            {
                vc.isOwerMode = NO;
                vc.str_StartIdx = self.str_BeforeIdx;
                //                                                                    vc.nStartPdfPage = [self.str_BeforeIdx integerValue];
            }
            else
            {
                vc.nStartPdfPage = 1;
            }
            
            [vc setDocument:document_Tmp];
            vc.view.backgroundColor = [UIColor whiteColor];
            //                                                                vc.completeBlock = self.completeBlock;
            
            [self.vc_Parent presentViewController:vc animated:NO completion:^{
                
            }];
        }

    }];

    
    NSLog(@"종료");
}

- (void)onTest2:(NSDictionary *)dicM_Obj
{
    NSLog(@"시작");
    
    [self dismissViewControllerAnimated:NO completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNormalQuestion" object:dicM_Obj];

    }];
    
}

- (IBAction)goPdfNext:(id)sender
{
    NSInteger nOldExamNo = [[self.dic_CurrentQuestion objectForKey:@"examNo"] integerValue];
    if( nOldExamNo >= nTotalQCnt )  return;
    
    NSInteger nExamNo = nOldExamNo + 1;
    __block NSInteger nPdfPage = [[self.dic_CurrentPdf objectForKey:@"pdfPage"] integerValue];
    
    NSDictionary *dic_QLast = [self.ar_Question lastObject];
    NSInteger nLastExamNo = [[dic_QLast objectForKey:@"examNo"] integerValue];
    

    if( nExamNo > nLastExamNo )
    {
        __block UIButton *btn = (UIButton *)sender;
        btn.hidden = YES;
        self.view.userInteractionEnabled = NO;
//        self.view.userInteractionEnabled = NO;
        
        nPdfPage += 1;
        
        [self.dicM_Parameter setObject:[NSString stringWithFormat:@"%ld", nPdfPage] forKey:@"pdfPage"];

        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
                                            param:self.dicM_Parameter
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                isMoveQuestion = YES;
                                                
                                                self.ar_Question = [resulte objectForKey:@"questionInfos"];
                                                [self showDocumentPage:nPdfPage];

//                                                [self updateQuestionStatusWithUpdateCount:NO];
                                                
                                                for( NSInteger i = 0; i < self.ar_Question.count; i++ )
                                                {
                                                    NSDictionary *dic_Sub = self.ar_Question[i];
                                                    NSInteger nCurrentExamNo = [[dic_Sub objectForKey:@"examNo"] integerValue];
                                                    
                                                    NSArray *ar_Tmp = [dic_Sub objectForKey:@"examQuestionInfos"];
                                                    if( ar_Tmp.count <= 0 ) return;
                                                    
                                                    NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
                                                    if( nExamNo == nCurrentExamNo )
                                                    {
                                                        [self performSelector:@selector(onShowZoomInterval:) withObject:@{@"dic_Sub":dic_Sub, @"dic_PdfInfo":dic_PdfInfo} afterDelay:1.5f];
                                                        NSLog(@"zoom zoom zoom zoom");
                                                        break;
                                                    }
                                                }
                                            }
                                            
//                                            btn.userInteractionEnabled = YES;
                                            [self performSelector:@selector(onUserInteractionInterval) withObject:nil afterDelay:2.0f];
                                        }];
    }
    else
    {
//        [self showDocumentPage:nPdfPage];
        [self.dicM_Parameter setObject:[NSString stringWithFormat:@"%ld", nPdfPage] forKey:@"pdfPage"];
        
        [self updateQuestionStatusWithUpdateCount:NO];
        
        for( NSInteger i = 0; i < self.ar_Question.count; i++ )
        {
            NSDictionary *dic_Sub = self.ar_Question[i];
            NSInteger nCurrentExamNo = [[dic_Sub objectForKey:@"examNo"] integerValue];
            
            NSArray *ar_Tmp = [dic_Sub objectForKey:@"examQuestionInfos"];
            if( ar_Tmp.count <= 0 ) return;
            
            NSDictionary *dic_PdfInfo = [ar_Tmp firstObject];
            if( nExamNo == nCurrentExamNo )
            {
                [self performSelector:@selector(onShowZoomInterval:) withObject:@{@"dic_Sub":dic_Sub, @"dic_PdfInfo":dic_PdfInfo} afterDelay:0.3f];
                break;
            }
        }
    }
}

- (void)onUserInteractionInterval
{
    self.view.userInteractionEnabled = YES;
}

- (IBAction)goAsk:(id)sender
{
    __block NSDictionary *dic_ExamPackageInfo = self.dic_ExamInfo;
    if( dic_ExamPackageInfo == nil )
    {
        return;
    }

    __block NSString *str_TeacherId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserId"]];
    __block NSString *str_TeacherName = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserName"]];
    __block NSString *str_TeacherImgUrl = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"answerUserThumbnail"]];
    
    NSMutableArray *arM = [NSMutableArray array];
    __block NSString *str_PdfImageUrl = @"";
    NSMutableString *strM_Urls = [NSMutableString string];
    NSArray *ar_Tmp = [self.dic_CurrentQuestion objectForKey:@"examQuestionInfos"];
    for( NSInteger i = 0; i < ar_Tmp.count; i++ )
    {
        NSDictionary *dic = ar_Tmp[i];
        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
        [dicM setObject:[dic objectForKey:@"pdfImgUrl"] forKey:@"pdfImgUrl"];
        [dicM setObject:[dic objectForKey:@"questionType"] forKey:@"questionType"];
        [dicM setObject:[dic objectForKey:@"width"] forKey:@"width"];
        [dicM setObject:[dic objectForKey:@"height"] forKey:@"height"];
        [arM addObject:dicM];
    }
    
    NSMutableDictionary *dicM_Item = [NSMutableDictionary dictionary];
    [dicM_Item setObject:arM forKey:@"examQuestionInfos"];
    [dicM_Item setObject:[NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"examId"]] forKey:@"examId"];
    [dicM_Item setObject:[NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"examTitle"]] forKey:@"examTitle"];
    [dicM_Item setObject:[NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"examNo"]] forKey:@"examNo"];
    [dicM_Item setObject:[NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]] forKey:@"questionId"];
    [dicM_Item setObject:[NSString stringWithFormat:@"%ld", self.currentPage] forKey:@"pdfPage"];
    
    if( ar_Tmp && ar_Tmp.count > 0 )
    {
        for( NSInteger i = 0; i < ar_Tmp.count; i++ )
        {
            NSDictionary *dic_Tmp = [ar_Tmp objectAtIndex:i];
            [strM_Urls appendString:[NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"pdfImgUrl"]]];
            [strM_Urls appendString:@"|"];
        }
    }

    if( [strM_Urls hasSuffix:@"|"] )
    {
        [strM_Urls deleteCharactersInRange:NSMakeRange([strM_Urls length]-1, 1)];
    }

    str_PdfImageUrl = strM_Urls;
    
    if( str_PdfImageUrl == nil || str_PdfImageUrl.length <= 0 )
    {
//        ALERT(@"", @"pdf image null", @"", @"ok", nil);
        [self.navigationController.view makeToast:@"pdf image not found" withPosition:kPositionCenter];
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        str_TeacherId, @"inviteUserIdStr",
                                        @"group", @"channelType",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/make/chat/room"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic_QnaInfo = [resulte objectForKey:@"qnaRoomInfo"];
                                                __block NSString *str_RId = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"rId"]];
                                                
                                                NSString *str_SBChannelUrl = [resulte objectForKey_YM:@"sendbirdChannelUrl"];
                                                NSString *str_TmpRId = [NSString stringWithFormat:@"%ld", [[resulte objectForKey_YM:@"rId"] integerValue]];
                                                if( str_SBChannelUrl.length > 0 && [str_TmpRId integerValue] > 0 )
                                                {
                                                    //기존 방이 있을 경우 기존걸 사용
                                                    [SBDGroupChannel getChannelWithUrl:str_SBChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                        
                                                        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                                        ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                                        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                                                        navi.navigationBarHidden = YES;
                                                        vc.str_RId = str_RId;
                                                        vc.dic_Info = dic_QnaInfo;
                                                        //                                                        vc.str_RoomName = str_TeacherName;
                                                        vc.str_RoomTitle = str_TeacherName;
                                                        vc.str_RoomThumb = str_TeacherImgUrl;
                                                        vc.ar_UserIds = [NSArray arrayWithObject:str_TeacherId];
                                                        vc.channel = channel;
                                                        
                                                        vc.isAskMode = YES;
                                                        vc.isPdfMode = YES;
                                                        vc.dic_PdfQuestionInfo = dicM_Item;
                                                        vc.str_PdfImageUrl = str_PdfImageUrl;
                                                        vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"examId"]];
                                                        vc.str_ExamTitle = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"examTitle"]];
                                                        vc.str_ExamNo = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"examNo"]];
                                                        vc.str_SubjectName = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"subjectName"]];
                                                        vc.str_PdfPage = [NSString stringWithFormat:@"%ld", self.currentPage];
                                                        vc.str_QuestinId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
                                                        [self presentViewController:navi animated:YES completion:^{
                                                            
                                                        }];
                                                    }];
                                                }
                                                else
                                                {
                                                    NSMutableArray *arM_UserList = [NSMutableArray array];
                                                    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                                                    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
                                                    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
                                                    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
                                                    [arM_UserList addObject:dicM_MyInfo];
                                                    
                                                    NSMutableDictionary *dicM_OtherInfo = [NSMutableDictionary dictionary];
                                                    [dicM_OtherInfo setObject:[NSString stringWithFormat:@"%@", str_TeacherId] forKey:@"userId"];
                                                    [dicM_OtherInfo setObject:str_TeacherName forKey:@"userName"];
                                                    [dicM_OtherInfo setObject:str_TeacherImgUrl forKey:@"imgUrl"];
                                                    [arM_UserList addObject:dicM_OtherInfo];
                                                    
                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_QnaInfo];
                                                    [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                    
                                                    NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];
                                                    
                                                    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
                                                    NSError * err;
                                                    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
                                                    NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    
                                                    [SBDGroupChannel createChannelWithName:@"" isDistinct:NO userIds:@[str_TeacherId] coverUrl:@"" data:str_Dic customType:nil
                                                                         completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                                             
                                                                             if (error != nil)
                                                                             {
                                                                                 NSLog(@"Error: %@", error);
                                                                                 if( error.code == 400201 )
                                                                                 {
                                                                                     UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                                                     [window makeToast:@"가입된 회원이 아닙니다" withPosition:kPositionCenter];
                                                                                 }
                                                                                 return;
                                                                             }
                                                                             
                                                                             SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                                                             NSLog(@"%@", baseChannel.channelUrl);
                                                                             [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                                                             
                                                                             NSDictionary *dic_RoomInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"qnaRoomInfo"]];
                                                                             
                                                                             UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                                                             ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                                                             UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                                                                             navi.navigationBarHidden = YES;
                                                                             vc.str_RId = str_RId;
                                                                             vc.dic_Info = dic_RoomInfo;
                                                                             vc.str_RoomName = str_ChannelName;
                                                                             vc.str_RoomTitle = nil;
                                                                             vc.str_RoomThumb = str_TeacherImgUrl;
                                                                             vc.ar_UserIds = [NSArray arrayWithObject:str_TeacherId];
                                                                             vc.channel = channel;
                                                                             vc.isAskMode = YES;
                                                                             vc.isPdfMode = YES;
                                                                             vc.dic_PdfQuestionInfo = dicM_Item;
                                                                             vc.str_PdfImageUrl = str_PdfImageUrl;
                                                                             vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"examId"]];
                                                                             vc.str_ExamTitle = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"examTitle"]];
                                                                             vc.str_ExamNo = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"examNo"]];
                                                                             vc.str_SubjectName = [NSString stringWithFormat:@"%@", [dic_ExamPackageInfo objectForKey:@"subjectName"]];
                                                                             vc.str_PdfPage = [NSString stringWithFormat:@"%ld", self.currentPage];
                                                                             vc.str_QuestinId = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
                                                                             [self presentViewController:navi animated:YES completion:^{
                                                                                 
                                                                             }];
                                                                         }];
                                                }
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

@end
