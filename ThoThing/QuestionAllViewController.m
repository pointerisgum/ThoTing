//
//  QuestionAllViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionAllViewController.h"
#import "QuestionDetailViewController.h"
#import "QuestionMainCell.h"

@interface QuestionAllViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation QuestionAllViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNaviWithTitle:@"#고등학교" withLeftItem:[self leftBackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    self.navigationController.navigationBarHidden = NO;
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


#pragma mark - UIGesture
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    QuestionItemView *view = (QuestionItemView *)gestureRecognizer.view;
    NSLog(@"%ld", view.tag);
    
    //문제집 디테일로 이동
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
//    vc.dic_Info = self.ar_List[view.tag];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - UITableViewDelegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count / 3;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"QuestionMainCell";
    QuestionMainCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    /*
     OpenYn = Y;
     changeDate = "2016-06-22 11:09:22";
     clipCount = 0;
     coverBgColor = "bgm-cyan";
     createDate = "2016-06-18 21:18:43";
     examId = 488;
     examSolveCount = 0;
     examTitle = "\Uacf5\Ubd802";
     examUniqueUserCount = 0;
     examUserCount = 0;
     groupId = 0;
     groupName = "<null>";
     groupQuestionCount = 0;
     heartCount = 0;
     isClip = "-1";
     isFinishCount = 0;
     isSolve = 0;
     lectureId = 0;
     personGrade = 0;
     publisherId = 0;
     publisherName = "";
     questionCount = 10;
     schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
     subjectName = "\Uad6d\Uc5b4";
     teacherImg = "no-image";
     teacherName = "\Ud1a0\Ud305\Uc120\Uc0dd\Ub2d81";
     teacherUrl = T108160419;
     */
    
    cell.tag = indexPath.row;
    
    if( self.ar_List.count >= 3 )
    {
        
        NSDictionary *dic1 = self.ar_List[(indexPath.row / 3) + (indexPath.row % 3)];
        cell.v_Item1.lb_Subject.text = [dic1 objectForKey:@"subjectName"];
        NSInteger nGrade = [[dic1 objectForKey:@"personGrade"] integerValue];
        cell.v_Item1.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic1 objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
        cell.v_Item1.lb_Ower.text = [dic1 objectForKey:@"publisherName"];
        cell.v_Item1.lb_Price.text = @"무료";//[dic1 objectForKey:@""];
        cell.v_Item1.nSection = indexPath.row / 3;
        cell.v_Item1.tag = indexPath.row % 3;
        
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap1 setNumberOfTapsRequired:1];
        [cell.v_Item1 addGestureRecognizer:singleTap1];
        
        
        
        NSDictionary *dic2 = self.ar_List[(indexPath.row / 3) + (indexPath.row % 3)];
        cell.v_Item2.lb_Subject.text = [dic2 objectForKey:@"subjectName"];
        nGrade = [[dic2 objectForKey:@"personGrade"] integerValue];
        cell.v_Item2.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic2 objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
        cell.v_Item2.lb_Ower.text = [dic2 objectForKey:@"publisherName"];
        cell.v_Item2.lb_Price.text = @"무료";//[dic1 objectForKey:@""];
        cell.v_Item2.nSection = indexPath.row / 3;
        cell.v_Item2.tag = indexPath.row % 3;
        
        UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap2 setNumberOfTapsRequired:1];
        [cell.v_Item2 addGestureRecognizer:singleTap2];
        
        
        NSDictionary *dic3 = self.ar_List[(indexPath.row / 3) + (indexPath.row % 3)];
        cell.v_Item3.lb_Subject.text = [dic3 objectForKey:@"subjectName"];
        nGrade = [[dic3 objectForKey:@"personGrade"] integerValue];
        cell.v_Item3.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic3 objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
        cell.v_Item3.lb_Ower.text = [dic3 objectForKey:@"publisherName"];
        cell.v_Item3.lb_Price.text = @"무료";//[dic1 objectForKey:@""];
        cell.v_Item3.nSection = indexPath.row / 3;
        cell.v_Item3.tag = indexPath.row % 3;
        
        UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [singleTap3 setNumberOfTapsRequired:1];
        [cell.v_Item3 addGestureRecognizer:singleTap3];
    }
    
    return cell;
}

@end
