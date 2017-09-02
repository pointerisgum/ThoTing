//
//  StarListViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 8..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "StarListViewController.h"
#import "StarListCell.h"
#import "QuestionIngStarNaviView.h"
#import "StarListDetailViewController.h"

@interface StarListViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) QuestionIngStarNaviView *v_RightMenu;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation StarListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionIngStarNaviView" owner:self options:nil];
    self.v_RightMenu = [topLevelObjects objectAtIndex:0];
    self.v_RightMenu.btn_Count.userInteractionEnabled = NO;
//    [self.v_RightMenu.btn_Count addTarget:self action:@selector(onStarList:) forControlEvents:UIControlEventTouchUpInside];
    
    [self initNaviWithTitle:@"별표한 문제" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[[UIBarButtonItem alloc] initWithCustomView:self.v_RightMenu] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateList];
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
                                            [self.v_RightMenu.btn_Count setTitle:[NSString stringWithFormat:@"%ld", [[resulte objectForKey:@"myStarQuestionCount"] integerValue]] forState:UIControlStateNormal];

                                            self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"starQuestionInfos"]];
                                            [self.tbv_List reloadData];
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
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"StarListCell";
    StarListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    cell.lb_Title.text = [dic objectForKey:@"subjectName"];
    
    NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
    cell.lb_SubTitle.text = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
    
    [cell.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"questionCount"] integerValue]] forState:UIControlStateNormal];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];

    StarListDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StarListDetailViewController"];
    vc.str_SchoolGrade = [NSString stringWithFormat:@"%@", [dic objectForKey:@"schoolGrade"]];
    vc.str_PersonGrade = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"personGrade"] integerValue]];
    vc.str_SubjectName = [dic objectForKey:@"subjectName"];
    vc.nPage = 1;
    vc.nTotalPage = [[dic objectForKey:@"questionCount"] integerValue];
    [self.navigationController pushViewController:vc animated:YES];
}





@end
