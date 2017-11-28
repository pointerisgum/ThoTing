//
//  SideMenuViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 31..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "SideMenuViewController.h"
#import "SideMenuCell.h"
#import "ReportDetailViewController.h"
#import "QuestionListSwipeViewController.h"

static NSString *kMoreCount = @"50";

@interface SideMenuViewController ()
{
    BOOL isLoding;
    BOOL isDownScroll;
    
    NSString *str_StartNum;
    NSString *str_LastNum;
    NSInteger nNowQuestionNum;
}
@property (nonatomic, strong) NSMutableArray *ar_List;

@property (nonatomic, assign) ListType listType;
@property (nonatomic, weak) IBOutlet UIView *v_Side;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SideMenuX;

@property (nonatomic, weak) IBOutlet UITableView *tbv_List;

@property (nonatomic, weak) IBOutlet UILabel *lb_PassCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_NonPassCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_StarCnt;

@property (nonatomic, weak) IBOutlet UIButton *btn_Pass;
@property (nonatomic, weak) IBOutlet UIButton *btn_NonPass;
@property (nonatomic, weak) IBOutlet UIButton *btn_Star;
@property (nonatomic, weak) IBOutlet UIButton *btn_Result;

@property (nonatomic, weak) IBOutlet UISegmentedControl *sg;

@end

@implementation SideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.str_StartNo = @"15";
    
//    nNowQuestionNum = 0;
    
    if( [self.str_StartNo integerValue] <= 0 )
    {
        self.str_StartNo = @"1";
    }
    
    str_StartNum = self.str_StartNo;
    if( [str_StartNum integerValue] - 10 <= 0 )
    {
        str_StartNum = @"1";
    }
    else
    {
        str_StartNum = [NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 5];
    }
    
    nNowQuestionNum = [self.str_StartNo integerValue];
    
//    str_LastNum = [NSString stringWithFormat:@"%ld", [self.str_StartNo integerValue] - 1];
    str_LastNum = @"0";
    
//    if( [str_LastNum integerValue] < 15 )
//    {
//        str_LastNum = [NSString stringWithFormat:@"%d", 0];
//    }
    
    isDownScroll = YES;
    
    self.listType = kAll;
    
    self.btn_Result.layer.cornerRadius = 10.f;
    self.btn_Result.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btn_Result.layer.borderWidth = 1.f;
    self.btn_Result.userInteractionEnabled = NO;
    
    [self updateTopData];
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

- (void)updateTopData
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_TesterId, @"testerId",
                                        nil];
    
    switch (self.listType)
    {
        case kPass:
            [dicM_Params setObject:@"correctQuestion" forKey:@"questionType"];
            break;
            
        case kNonPass:
            [dicM_Params setObject:@"inCorrectQuestion" forKey:@"questionType"];
            break;
            
        case kStar:
            [dicM_Params setObject:@"starQuestion" forKey:@"questionType"];
            break;
            
        default:
            [dicM_Params setObject:@"all" forKey:@"questionType"];
            break;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/now/solve/exam/question/count"
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
                                                
                                                //현재 풀고 있는 문제 번호
//                                                nNowQuestionNum = [[dic objectForKey:@"beginExamNo"] integerValue];
                                                
                                                //전체 문제 수
                                                NSInteger nTotalCnt = [[dic objectForKey:@"questionCount"] integerValue];
                                                
                                                //맞은 수
                                                NSInteger nPassCnt = [[dic objectForKey:@"correctQuestionCount"] integerValue];
                                                weakSelf.lb_PassCnt.text = [NSString stringWithFormat:@"%ld", nPassCnt];
                                                
                                                //틀린 수
                                                NSInteger nNonPassCnt = [[dic objectForKey:@"inCorrectQuestionCount"] integerValue];
                                                weakSelf.lb_NonPassCnt.text = [NSString stringWithFormat:@"%ld", nNonPassCnt];
                                                
                                                //별표 수
                                                weakSelf.lb_StarCnt.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"starQuestionCount"]];
                                                
                                                
                                                //맞은 문제와 틀린 문제를 더해서 총 문제수와 비교한다
                                                //두개의 합이 같으면 다 푼걸로 간주
                                                if( nTotalCnt <= (nPassCnt + nNonPassCnt) )
                                                {
                                                    self.btn_Result.selected = YES;
                                                    self.btn_Result.layer.borderColor = kMainRedColor.CGColor;
                                                    self.btn_Result.userInteractionEnabled = YES;
                                                }
                                                else
                                                {
                                                    self.btn_Result.selected = NO;
                                                    self.btn_Result.layer.borderColor = [UIColor lightGrayColor].CGColor;
                                                    self.btn_Result.userInteractionEnabled = NO;
                                                }
                                                
                                                [self updateList];
                                            }
                                        }
                                    }];
}

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
                                        self.str_TesterId, @"testerId",
//                                        @"", @"firstExamNo",
//                                        str_LastNum, @"lastExamNo",
//                                        isDownScroll ? @"next" : @"pre", @"scrollType",
                                        kMoreCount, @"limitCount",
                                        nil];
    
    if( isDownScroll )
    {
        [dicM_Params setObject:@"" forKey:@"firstExamNo"];

        if( self.ar_List && self.ar_List.count > 0 )
        {
            NSDictionary *dic = [self.ar_List lastObject];
            NSString *str_LastNo = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examNo"]];
            [dicM_Params setObject:str_LastNo forKey:@"lastExamNo"];
        }
        else
        {
            [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1] forKey:@"lastExamNo"];
        }

        [dicM_Params setObject:@"next" forKey:@"scrollType"];

        ////        [dicM_Params setObject:str_StartNum forKey:@"firstExamNo"];
//        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1] forKey:@"lastExamNo"];
    }
    else
    {
        [dicM_Params setObject:@"" forKey:@"lastExamNo"];

        if( self.ar_List && self.ar_List.count > 0 )
        {
            NSDictionary *dic = [self.ar_List firstObject];
            NSString *str_FirstNo = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examNo"]];
            [dicM_Params setObject:str_FirstNo forKey:@"firstExamNo"];
        }
        else
        {
            [dicM_Params setObject:@"0" forKey:@"firstExamNo"];
        }

        [dicM_Params setObject:@"pre" forKey:@"scrollType"];
    }

    switch (self.listType)
    {
        case kPass:
            [dicM_Params setObject:@"correctQuestion" forKey:@"questionType"];
            break;

        case kNonPass:
            [dicM_Params setObject:@"inCorrectQuestion" forKey:@"questionType"];
            break;

        case kStar:
            [dicM_Params setObject:@"starQuestion" forKey:@"questionType"];
            break;

        default:
            [dicM_Params setObject:@"all" forKey:@"questionType"];
            break;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/now/solve/exam/question/list"
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
//                                                str_StartNum = [NSString stringWithFormat:@"%@", [dic_First objectForKey:@"examNo"]];
                                                NSInteger nLastNo = [[dic_Last objectForKey:@"examNo"] integerValue];
                                                str_StartNum = [NSString stringWithFormat:@"%ld", nLastNo + 1];
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
        
//        if ( [str_Type isEqualToString:@"pdf"] && cell.lb_Title.text.length < 0 )
        if ( [str_Type isEqualToString:@"pdf"] )
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
    
    //별표여부
    BOOL isStar = [[dic objectForKey:@"existStar"] boolValue];
    if( isStar )
    {
        cell.iv_Star.hidden = NO;
    }
    else
    {
        cell.iv_Star.hidden = YES;
    }
    
    //틀린문제 표시
    BOOL isDone = [[dic objectForKey:@"isSolve"] boolValue];
    if( isDone )
    {
        BOOL isPass = [[dic objectForKey:@"isCorrect"] boolValue];
        if( isPass )
        {
            //맞음
            cell.lb_Number.textColor = cell.lb_Title.textColor = [UIColor blackColor];
        }
        else
        {
            //틀림
            cell.lb_Number.textColor = cell.lb_Title.textColor = kMainRedColor;
        }
    }
    else
    {
        cell.lb_Number.textColor = cell.lb_Title.textColor = [UIColor blackColor];
    }
    
    //현재 문제 표시
    if( self.str_ExamNo && [self.str_ExamNo integerValue] > 0 )
    {
        if( [[dic objectForKey:@"examNo"] integerValue] == [self.str_ExamNo integerValue] )
        {
            cell.separatorInset = UIEdgeInsetsMake(0, 1150, 0, 0);
            cell.iv_RedLine.hidden = NO;
        }
        else
        {
            cell.iv_RedLine.hidden = YES;
        }
    }
    else
    {
        if( [[dic objectForKey:@"examNo"] integerValue] == nNowQuestionNum )
        {
            cell.separatorInset = UIEdgeInsetsMake(0, 1150, 0, 0);
            cell.iv_RedLine.hidden = NO;
        }
        else
        {
            cell.iv_RedLine.hidden = YES;
        }
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    if( [self.str_SortType isEqualToString:@"inCorrectQuestionSolve"] )
    {
        BOOL isPass = [[dic objectForKey:@"isCorrect"] boolValue];
        if( isPass )
        {
            return;
        }
    }
    
    if( self.completionBlock )
    {
        switch (self.listType)
        {
            case kPass:
                self.completionBlock(@{@"obj":dic, @"type":@"correctQuestion", @"pdfPage":[NSString stringWithFormat:@"%@",[dic objectForKey:@"pdfPage"]]});
                break;
                
            case kNonPass:
                self.completionBlock(@{@"obj":dic, @"type":@"inCorrectQuestion", @"pdfPage":[NSString stringWithFormat:@"%@",[dic objectForKey:@"pdfPage"]]});
                break;
                
            case kStar:
                self.completionBlock(@{@"obj":dic, @"type":@"myStarQuestion", @"pdfPage":[NSString stringWithFormat:@"%@",[dic objectForKey:@"pdfPage"]]});
                break;
                
            default:
                self.completionBlock(@{@"obj":dic, @"type":@"all", @"pdfPage":[NSString stringWithFormat:@"%@",[dic objectForKey:@"pdfPage"]]});
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

//- (IBAction)goPass:(id)sender
//{
//    self.btn_NonPass.selected = self.btn_Star.selected = NO;
//    
//    UIButton *btn = (UIButton *)sender;
//    if( btn.selected )
//    {
//        btn.selected = NO;
//        self.listType = kAll;
//        
//        isDownScroll = YES;
//        str_StartNum = self.str_StartNo;
//        str_LastNum = @"0";//[NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
//        [self.ar_List removeAllObjects];
//        self.ar_List = nil;
//    }
//    else
//    {
//        btn.selected = YES;
//        self.listType = kPass;
//        
//        isDownScroll = YES;
//        str_StartNum = @"1";
//        str_LastNum = [NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
//        [self.ar_List removeAllObjects];
//        self.ar_List = nil;
//    }
//    
//    [self updateList];
//}
//
//- (IBAction)goNonPass:(id)sender
//{
//    self.btn_Pass.selected = self.btn_Star.selected = NO;
//    
//    UIButton *btn = (UIButton *)sender;
//    if( btn.selected )
//    {
//        btn.selected = NO;
//        self.listType = kAll;
//        
//        isDownScroll = YES;
//        str_StartNum = self.str_StartNo;
//        str_LastNum = @"0";//[NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
//        [self.ar_List removeAllObjects];
//        self.ar_List = nil;
//    }
//    else
//    {
//        btn.selected = YES;
//        self.listType = kNonPass;
//        
//        isDownScroll = YES;
//        str_StartNum = @"1";
//        str_LastNum = [NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
//        [self.ar_List removeAllObjects];
//        self.ar_List = nil;
//    }
//    
//    [self updateList];
//}
//
//- (IBAction)goStar:(id)sender
//{
//    self.btn_Pass.selected = self.btn_NonPass.selected = NO;
//    
//    UIButton *btn = (UIButton *)sender;
//    if( btn.selected )
//    {
//        btn.selected = NO;
//        self.listType = kAll;
//        
//        isDownScroll = YES;
//        str_StartNum = self.str_StartNo;
//        str_LastNum = @"0";//[NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
//        [self.ar_List removeAllObjects];
//        self.ar_List = nil;
//    }
//    else
//    {
//        btn.selected = YES;
//        self.listType = kStar;
//        
//        isDownScroll = YES;
//        str_StartNum = @"1";
//        str_LastNum = [NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
//        [self.ar_List removeAllObjects];
//        self.ar_List = nil;
//    }
//    
//    [self updateList];
//}
//
//- (IBAction)goResult:(id)sender
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
//    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
//    vc.str_ExamId = self.str_Idx;
//    vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
//    [self presentViewController:vc animated:YES completion:^{
//        
//    }];
//}

- (IBAction)goSegChange:(id)sender
{
    switch (self.sg.selectedSegmentIndex)
    {
        case 0:
        {
            self.listType = kAll;
            
            isDownScroll = YES;
            str_StartNum = @"1";
            str_LastNum = [NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
            [self.ar_List removeAllObjects];
            self.ar_List = nil;
            
            [self updateList];
        }
            break;

        case 1:
        {
            self.listType = kNonPass;
            
            isDownScroll = YES;
            str_StartNum = @"1";
            str_LastNum = [NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
            [self.ar_List removeAllObjects];
            self.ar_List = nil;

            [self updateList];
        }
            break;

        case 2:
        {
            self.listType = kStar;
            
            isDownScroll = YES;
            str_StartNum = @"1";
            str_LastNum = [NSString stringWithFormat:@"%ld", [str_StartNum integerValue] - 1];
            [self.ar_List removeAllObjects];
            self.ar_List = nil;
            
            [self updateList];
        }
            break;

        default:
            break;
    }
}

@end
