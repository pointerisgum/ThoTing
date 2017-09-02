//
//  ActionSheetBottomViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ActionSheetBottomViewController.h"
#import "ActionSheetBottomCell.h"
#import "ActionSheetBottomStarCell.h"

@interface ActionSheetBottomViewController () <StarViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *dicM_CurrentInfo;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvHeight;
@end

@implementation ActionSheetBottomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [self.iv_Bg addGestureRecognizer:imageTap];
    self.lc_TbvHeight.constant = self.arM_List.count * 64.f;
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

- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:^{
        
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_List[indexPath.row];

    NSString *str_Type = [dic objectForKey:@"type"];
    NSString *str_Contents = [dic objectForKey:@"contents"];

    if( [str_Type isEqualToString:@"star"] )
    {
        static NSString *CellIdentifier = @"ActionSheetBottomStarCell";
        ActionSheetBottomStarCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if( self.dicM_CurrentInfo == nil )
        {
            self.dicM_CurrentInfo = [NSMutableDictionary dictionaryWithDictionary:[dic objectForKey:@"data"]];
        }
        
        NSInteger nStarCount = [[self.dicM_CurrentInfo objectForKey:@"myStarCount"] integerValue];
        cell.starView.delegate = self;
        [cell.starView setStarScore:nStarCount];
        
        //구매한 컨텐츠
        if( [[self.dicM_CurrentInfo objectForKey:@"isPaid"] isEqualToString:@"paid"] )
        {
            if( nStarCount > 0 )
            {
                //평가한 문제
                cell.lb_Discrip.hidden = YES;
                cell.lb_Score.hidden = NO;
                
                cell.lb_Score.text = [NSString stringWithFormat:@"%@ / %@명",
                                      [self.dicM_CurrentInfo objectForKey:@"avgStarCount"], [self.dicM_CurrentInfo objectForKey_YM:@"starUserCount"]];
            }
            else
            {
                //평가하지 않은 문제
                cell.lb_Discrip.hidden = NO;
                cell.lb_Score.hidden = YES;
            }
        }
        
        return cell;
    }

    
    static NSString *CellIdentifier = @"ActionSheetBottomCell";
    ActionSheetBottomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.sw.hidden = YES;
    
    
    cell.lb_Title.textColor = kMainColor;
    
    if( [str_Type isEqualToString:@"normal"] )
    {
        cell.btn_Info.hidden = YES;
    }
    else if( [str_Type isEqualToString:@"result"] )
    {
        cell.btn_Info.hidden = YES;
        cell.lb_Title.textColor = [UIColor redColor];
    }
    else if( [str_Type isEqualToString:@"share"] )
    {
        cell.btn_Info.hidden = NO;
        [cell.btn_Info setImage:BundleImage(@"circle_left_arrow.png") forState:UIControlStateNormal];
    }
    else if( [str_Type isEqualToString:@"info"] )
    {
        cell.btn_Info.hidden = NO;
        [cell.btn_Info setImage:BundleImage(@"Info_blue.png") forState:UIControlStateNormal];
    }
    else if( [str_Type isEqualToString:@"toggle"] )
    {
        cell.lb_Title.textColor = [UIColor redColor];
        cell.btn_Info.hidden = YES;
        cell.sw.hidden = NO;
        cell.sw.on = ![[dic objectForKey:@"value"] isEqualToString:@"Y"];
        cell.sw.tag = indexPath.row;
        [cell.sw addTarget:self action:@selector(onSharedToggle:) forControlEvents:UIControlEventValueChanged];
    }
    
    cell.lb_Title.text = str_Contents;
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{

        if( self.completionBlock )
        {
            NSDictionary *dic = self.arM_List[indexPath.row];
            self.completionBlock(dic);
        }
    }];
}


- (void)onSharedToggle:(UISwitch *)sw
{
    if( self.completionBlock )
    {
        NSDictionary *dic = self.arM_List[sw.tag];
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dicM setObject:[NSNumber numberWithBool:sw.on] forKey:@"onOff"];
        self.completionBlock(dicM);
    }
}


#pragma mark - StarViewDelegate
- (void)didUpdateStarView:(NSInteger)nScore
{
    NSLog(@"nScore : %ld", nScore);
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dicM_CurrentInfo objectForKey:@"examId"]], @"examId",
                                        [NSString stringWithFormat:@"%ld", nScore], @"starCount",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/package/star"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                [self.dicM_CurrentInfo setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"avgStarCount"]]
                                                                          forKey:@"avgStarCount"];
                                                [self.dicM_CurrentInfo setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"myStarCount"]]
                                                                          forKey:@"myStarCount"];
                                                [self.dicM_CurrentInfo setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"starUserCount"]]
                                                                          forKey:@"starUserCount"];

                                                [self.tbv_List reloadData];
                                                
                                                if( self.completionStarBlock )
                                                {
                                                    self.completionStarBlock(self.dicM_CurrentInfo);
                                                }
                                            }
                                        }
                                    }];
}

@end
