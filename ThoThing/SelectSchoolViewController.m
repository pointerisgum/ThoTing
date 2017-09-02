//
//  SelectSchoolViewController.m
//  ThoTing
//
//  Created by KimYoung-Min on 2016. 6. 15..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "SelectSchoolViewController.h"
#import "SelectSchoolCell.h"

@interface SelectSchoolViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UITextField *tf;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Cancel;
@end

@implementation SelectSchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.btn_Cancel.layer.cornerRadius = 8.f;
//    self.btn_Cancel.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.btn_Cancel.layer.borderWidth = 1.f;
    
    self.tbv_List.hidden = YES;
    [self.tf becomeFirstResponder];
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
    NSLog(@"%@", self.tf.text);
    
    if( self.tf.text.length <= 0 )
    {
        self.ar_List = nil;
        self.tbv_List.hidden = YES;
        [self.tbv_List reloadData];
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"] forKey:@"apiToken"];
    [dicM_Params setObject:[Util getUUID] forKey:@"uuid"];
    [dicM_Params setObject:self.tf.text forKey:@"schoolName"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/school/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"schoolNameInfos"]];
                                            if( self.ar_List.count > 0 )
                                            {
                                                self.tbv_List.hidden = NO;
                                            }
                                            else
                                            {
                                                self.tbv_List.hidden = YES;
                                            }
                                            [self.tbv_List reloadData];
                                        }
                                    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateList) withObject:nil afterDelay:0.1f];
    
    return YES;
}


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
    
    static NSString *CellIdentifier = @"SelectSchoolCell";
    SelectSchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    /*
     schoolAddress = "\Uacbd\Uae30 \Uace0\Uc591\Uc2dc \Ub355\Uc591\Uad6c \Ud654\Uc815\Ub3d9854\Ubc88\Uc9c0";
     schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
     schoolId = 9199;
     schoolName = "\Ud654\Uc218\Uace0\Ub4f1\Ud559\Uad50";
     schoolRegion = "\Uacbd\Uae30";
     */
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    cell.lb_School.text = [dic objectForKey:@"schoolName"];
    cell.lb_Area.text = [dic objectForKey:@"schoolRegion"];
    
//    cell.lb_Number.text = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue]];
//    cell.lb_Title.text = [NSString stringWithFormat:@"주관식 / 정답:%ld", [[dic objectForKey:@"correctAnswer"] integerValue]];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( self.completionBlock )
    {
        NSDictionary *dic = self.ar_List[indexPath.row];
        self.completionBlock(dic);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
