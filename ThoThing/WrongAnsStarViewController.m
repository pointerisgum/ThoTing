//
//  WrongAnsStarViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 2. 24..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "WrongAnsStarViewController.h"
#import "WrongAndStarCell.h"
#import "QuestionContainerViewController.h"

@interface WrongAnsStarViewController ()
@property (nonatomic, strong) NSMutableArray *arM_Wrong;
@property (nonatomic, strong) NSMutableArray *arM_Star;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet UITableView *tbv_Wrong;
@property (nonatomic, weak) IBOutlet UITableView *tbv_Star;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContainerWidth;
@end

@implementation WrongAnsStarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.seg.selectedSegmentIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MBProgressHUD hide];

    self.navigationController.navigationBar.hidden = YES;
    
    [self updateWrongList];
    [self updateStarList];
}

- (void)viewDidLayoutSubviews
{
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.frame.size.width * 2, self.sv_Contents.frame.size.height);
    self.lc_ContainerWidth.constant = self.sv_Contents.contentSize.width;
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

- (void)updateWrongList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/incorrect/question/subject/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            self.arM_Wrong = [NSMutableArray arrayWithArray:[resulte objectForKey:@"inCorrectQuestionInfos"]];
                                            [self.tbv_Wrong reloadData];
                                        }
                                    }];

}

- (void)updateStarList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/star/question/subject/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            self.arM_Star = [NSMutableArray arrayWithArray:[resulte objectForKey:@"starQuestionInfos"]];
                                            [self.tbv_Star reloadData];
                                        }
                                    }];
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_Wrong )
    {
        return self.arM_Wrong.count;
    }
    
    return self.arM_Star.count;

//    if( self.seg.selectedSegmentIndex == 0 )
//    {
//        return self.arM_Wrong.count;
//    }
//    
//    return self.arM_Star.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WrongAndStarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WrongAndStarCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if( tableView == self.tbv_Wrong )
    {
        NSDictionary *dic = [self.arM_Wrong objectAtIndex:indexPath.row];
        cell.lb_Title.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"subjectName"]];
        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionCount"]];
    }
    else
    {
        NSDictionary *dic = [self.arM_Star objectAtIndex:indexPath.row];
        cell.lb_Title.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"subjectName"]];
        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionCount"]];
    }

//    if( self.seg.selectedSegmentIndex == 0 )
//    {
//        NSDictionary *dic = [self.arM_Wrong objectAtIndex:indexPath.row];
//        cell.lb_Title.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"subjectName"]];
//        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionCount"]];
//    }
//    else
//    {
//        NSDictionary *dic = [self.arM_Star objectAtIndex:indexPath.row];
//        cell.lb_Title.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"subjectName"]];
//        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionCount"]];
//    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( self.seg.selectedSegmentIndex == 0 )
    {
        //오답
        NSDictionary *dic = [self.arM_Wrong objectAtIndex:indexPath.row];
        
        QuestionContainerViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.str_StartIdx = @"1";
        vc.str_SubjectName = [dic objectForKey_YM:@"subjectName"];
        vc.isWrong = YES;
        vc.str_SubjectTotalCount = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionCount"]];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        //별표
        NSDictionary *dic = [self.arM_Star objectAtIndex:indexPath.row];

        QuestionContainerViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.str_StartIdx = @"1";
        vc.str_SubjectName = [dic objectForKey_YM:@"subjectName"];
        vc.isStar = YES;
        vc.str_SubjectTotalCount = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionCount"]];

        [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - IBAction
- (IBAction)goSegChange:(id)sender
{
    if( self.seg.selectedSegmentIndex == 0 )
    {
        [UIView animateWithDuration:0.3f animations:^{
           
            self.sv_Contents.contentOffset = CGPointZero;
            [self.view setNeedsLayout];
        }];

        [self updateWrongList];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.frame.size.width, 0);
            [self.view setNeedsLayout];
        }];

        [self updateStarList];
    }
}

@end
