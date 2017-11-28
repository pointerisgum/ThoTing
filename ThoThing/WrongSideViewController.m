//
//  WrongStarViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 3. 1..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "WrongSideViewController.h"
#import "SideMenuCell.h"
#import "ReportDetailViewController.h"
#import "QuestionListSwipeViewController.h"

@interface WrongSideViewController ()
{
    BOOL isLoding;
    BOOL isDownScroll;
    
    NSString *str_StartNum;
    NSString *str_LastNum;
}
@property (nonatomic, strong) NSMutableArray *ar_List;
@property (nonatomic, weak) IBOutlet UIView *v_Side;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SideMenuX;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Title;
@end

@implementation WrongSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    nNowQuestionNum = 0;
    
    
    str_StartNum = self.str_StartNo;

    //    str_LastNum = [NSString stringWithFormat:@"%ld", [self.str_StartNo integerValue] - 1];
    str_LastNum = @"0";
    
    //    if( [str_LastNum integerValue] < 15 )
    //    {
    //        str_LastNum = [NSString stringWithFormat:@"%d", 0];
    //    }
    
    isDownScroll = YES;

    self.btn_Title.layer.borderWidth = 1.f;
    self.btn_Title.layer.borderColor = [UIColor colorWithHexString:@"DCB000"].CGColor;
    self.btn_Title.layer.cornerRadius = 4.f;
    
    if( self.listType == kWrong )
    {
        [self.btn_Title setTitle:@"오답 리스트" forState:UIControlStateNormal];
    }
    else
    {
        [self.btn_Title setTitle:@"별표 리스트" forState:UIControlStateNormal];
    }
    
    [self updateList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lc_SideMenuX.constant = -self.view.bounds.size.width;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)updateList
{
    //    if( self.listType == kAll && isDownScroll == NO && [str_StartNum integerValue] <= 1 )
    if( isDownScroll == NO && [str_StartNum integerValue] <= 1 )
    {
        isLoding = NO;
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
//                                        self.str_TesterId ? self.str_TesterId : @"", @"testerId",
                                        @"50", @"limitCount",
                                        self.str_SubjectName, @"subjectName",
                                        nil];
    
    if( isDownScroll )
    {
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.ar_List.count + 1] forKey:@"endExamNo"];
    }
    else
    {
        [dicM_Params setObject:@"0" forKey:@"endExamNo"];
    }
    
    switch (self.listType)
    {
        case kWrong:
            [dicM_Params setObject:@"inCorrect" forKey:@"questionType"];
            break;
            
        case kStarQ:
            [dicM_Params setObject:@"star" forKey:@"questionType"];
            break;

        default:
            [dicM_Params setObject:@"inCorrect" forKey:@"questionType"];
            break;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/side/question/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic = [NSDictionary dictionaryWithDictionary:resulte];
                                                
                                                if( weakSelf.ar_List.count <= 0 || weakSelf.ar_List == nil )
                                                {
                                                    weakSelf.ar_List = [NSMutableArray arrayWithArray:[dic objectForKey:@"questionList"]];
                                                }
                                                else
                                                {
                                                    if( isDownScroll )
                                                    {
                                                        [weakSelf.ar_List addObjectsFromArray:[dic objectForKey:@"questionList"]];
                                                    }
                                                    else
                                                    {
                                                        NSMutableArray *arM = [NSMutableArray arrayWithArray:[dic objectForKey:@"questionList"]];
                                                        [arM addObjectsFromArray:weakSelf.ar_List];
                                                        weakSelf.ar_List = [NSMutableArray arrayWithArray:arM];
                                                    }
                                                }
                                                
                                                NSDictionary *dic_First = [weakSelf.ar_List firstObject];
                                                NSDictionary *dic_Last = [weakSelf.ar_List lastObject];
                                                str_StartNum = [NSString stringWithFormat:@"%@", [dic_First objectForKey:@"examNo"]];
                                                str_LastNum = [NSString stringWithFormat:@"%@", [dic_Last objectForKey:@"examNo"]];
                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                        
                                        isLoding = NO;
                                    }];
}


#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if( scrollView == self.tbv_List )
//    {
//        if( self.tbv_List.contentOffset.y > (self.tbv_List.contentSize.height * 0.7f) && isLoding == NO )
//        {
//            isLoding = YES;
//            isDownScroll = YES;
//            [self updateList];
//        }
//    }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView.contentOffset.y <= 0 && isLoding == NO )
    {
        //여기 (오답, 별표 사이드 메뉴가 몇개 안될때 스크롤 튕기면 더 불러와짐)
        //up
        isLoding = YES;
        isDownScroll = NO;
        [self updateList];
    }
    else if( isLoding == NO )
    {
        //down
        isLoding = YES;
        isDownScroll = YES;
        [self updateList];
    }
}

#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideMenuCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     examId: 문제지ID
     u_progress: 푼 문제수
     isExamFinish: 시험 종료 여부 [Y-종료한 시험, N-풀고있는 시험]
     questionCount: 전체 문제수
     questionId: 문제ID
     examNo: 문제번호
     correctAnswer: 정답
     isSolve: 풀었는지, 안풀었는지 여부 [0 : 푼 문제, !=0 안푼문제]
     isCorrect: 정답 여부 [1-맞은 문제, 0-틀린문제]
     existStar: 별표여부 [0-별표 안함, !=0 별표한 문제]
     questionText: 첫번째 문제 text [text, html이 아니면 빈값]
     questionType: 첫번째 문제 형식 [text, html]
     */
    
//    if( indexPath.row % 2 )
//    {
//        cell.contentView.backgroundColor = [UIColor colorWithRed:247.f/255.f green:247.f/255.f blue:247.f/255.f alpha:1];
//    }
//    else
//    {
//        cell.contentView.backgroundColor = [UIColor whiteColor];
//    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 8, 0, 0);

    NSDictionary *dic = [self.ar_List objectAtIndex:indexPath.row];
    
    cell.lb_Number.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examNo"]];
    cell.lc_NumberWidth.constant = 0;
    
    NSString *str_Type = [dic objectForKey:@"questionType"];
    if( [str_Type isEqualToString:@"text"] || [str_Type isEqualToString:@"pdf"] )
    {
        NSString *str_Body = [dic objectForKey:@"questionText"];
        if( [str_Body isEqual:[NSNull class]] == NO )
        {
            str_Body = [str_Body stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            cell.lb_Title.text = str_Body;
        }
        
        if ( [str_Type isEqualToString:@"pdf"] && cell.lb_Title.text.length < 0 )
        {
            cell.lb_Number.text = @"";
            cell.lc_NumberWidth.constant = -30;
        }
        
    }
    else if( [str_Type isEqualToString:@"html"] )
    {
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        NSString *str_Body = [dic objectForKey:@"questionText"];
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [attrStr addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [attrStr length])];
        
        cell.lb_Title.attributedText = attrStr;
    }
    else
    {
        cell.lb_Title.text = @"";
        cell.lb_Title.attributedText = nil;
    }
    
//    //별표여부
//    BOOL isStar = [[dic objectForKey:@"existStar"] boolValue];
//    if( isStar )
//    {
//        cell.iv_Star.hidden = NO;
//    }
//    else
//    {
//        cell.iv_Star.hidden = YES;
//    }
    
//    //틀린문제 표시
//    BOOL isDone = [[dic objectForKey:@"isSolve"] boolValue];
//    if( isDone )
//    {
//        BOOL isPass = [[dic objectForKey:@"isCorrect"] boolValue];
//        if( isPass )
//        {
//            //맞음
//            cell.lb_Number.textColor = cell.lb_Title.textColor = [UIColor blackColor];
//        }
//        else
//        {
//            //틀림
//            cell.lb_Number.textColor = cell.lb_Title.textColor = kMainRedColor;
//        }
//    }
//    else
//    {
//        cell.lb_Number.textColor = cell.lb_Title.textColor = [UIColor blackColor];
//    }
    
    //현재 문제 표시
    if( [[dic objectForKey:@"examNo"] integerValue] == self.nNowQuestionNum )
    {
        cell.separatorInset = UIEdgeInsetsMake(0, 1150, 0, 0);
        cell.iv_RedLine.hidden = NO;
    }
    else
    {
        cell.iv_RedLine.hidden = YES;
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    if( self.completionBlock )
    {
        switch (self.listType)
        {
            case kWrong:
                self.completionBlock(@{@"obj":dic, @"type":@"inCorrectQuestion", @"pdfPage":[NSString stringWithFormat:@"%@",[dic objectForKey:@"pdfPage"]],
                                       @"idx":[NSString stringWithFormat:@"%ld", indexPath.row + 1]});
                break;
                
            case kStarQ:
                self.completionBlock(@{@"obj":dic, @"type":@"myStarQuestion", @"pdfPage":[NSString stringWithFormat:@"%@",[dic objectForKey:@"pdfPage"]],
                                       @"idx":[NSString stringWithFormat:@"%ld", indexPath.row + 1]});
                break;
        }
        
        [self goCloseMenu:nil];
    }
}



#pragma mark - IBAction
- (void)closeMenu
{
    self.lc_SideMenuX.constant = 0;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }];
}

- (IBAction)goCloseMenu:(id)sender
{
    [self closeMenu];
}

@end
