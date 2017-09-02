//
//  ReportPopUpViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 28..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ReportPopUpViewController.h"
#import "ReportPopUpHeaderCell.h"
#import "ReportPopUpListCell.h"

@interface ReportPopUpViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvHeight;
@end

@implementation ReportPopUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for( NSInteger i = 0; i < self.ar_List.count; i++ )
    {
        NSDictionary *dic = self.ar_List[i];
        if( [[dic objectForKey:@"channelName"] isEqualToString:@"나의 레포트"] )
        {
            [self.ar_List removeObjectAtIndex:i];
        }
    }
    
    [self.ar_List addObject:@{@"channelName":@"나의 레포트", @"channelId":@"0"}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tbv_List reloadData];
    
    self.lc_TbvHeight.constant = 0;
    
    [self.tbv_List setNeedsLayout];
}

- (void)viewDidLayoutSubviews
{
    [UIView animateWithDuration:0.7f animations:^{
        
        self.lc_TbvHeight.constant = self.tbv_List.contentSize.height;
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
    
    static NSString *CellIdentifier = @"ReportPopUpListCell";
    ReportPopUpListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dic = self.ar_List[indexPath.row];
    
    if( [[dic objectForKey:@"channelId"] integerValue] == self.nSelectedIdx )
    {
        cell.iv_Check.hidden = NO;
    }
    else
    {
        cell.iv_Check.hidden = YES;
    }
    
    cell.lb_Title.text = [dic objectForKey:@"channelName"];
    
//    if( indexPath.row == self.ar_List.count - 1 )
//    {
//        cell.iv_UnderLine.hidden = NO;
//    }
//    else
//    {
//        cell.iv_UnderLine.hidden = YES;
//    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.ar_List[indexPath.row];

    if( self.completionBlock )
    {
        self.completionBlock(dic);
    }
    
    [self onCancel:nil];
}
 
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"ReportPopUpHeaderCell";
    ReportPopUpHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.lb_Title.text = @"레포트 선택";
    
    [cell.btn_Cancel addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)onCancel:(UIButton *)btn
{
    [UIView animateWithDuration:0.7f
                     animations:^{
                        
                         self.lc_TbvHeight.constant = 0;
                     }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
