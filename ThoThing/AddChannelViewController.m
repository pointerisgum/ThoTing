//
//  AddChannelViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 30..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "AddChannelViewController.h"

@interface AddChannelCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Count;
@property (nonatomic, weak) IBOutlet UIButton *btn_Check;
@end

@implementation AddChannelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
//    NSLayoutConstraint *c = self.iv_User.constraints[0];
//    self.iv_User.layer.cornerRadius = c.constant / 2;
    
    [self layoutIfNeeded];
    
    self.iv_User.clipsToBounds = YES;
    //    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end

@interface AddChannelViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    
    UIColor *deSelectColor;
    NSMutableDictionary *dicM_Check;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Add;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation AddChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNaviWithTitle:@"채널등록" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self addChannelButtionItem] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    
    dicM_Check = [NSMutableDictionary dictionary];
    deSelectColor = [UIColor colorWithRed:180.f/255.f green:180.f/255.f blue:180.f/255.f alpha:1];

    self.btn_Add.layer.cornerRadius = 8.f;
    self.btn_Add.layer.borderWidth = 1.f;
    self.btn_Add.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
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
                                        @"", @"listType",
                                        nil];
    
    __weak __typeof__(self) weakSelf = self;

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/bookmark/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                             if( resulte )
                                             {
                                                 str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                                 str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                 str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                 
                                                 weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
                                                 
                                                 for( NSInteger i = 0; i < weakSelf.arM_List.count;  i++ )
                                                 {
                                                     NSDictionary *dic = weakSelf.arM_List[i];
                                                     if( [[dic objectForKey:@"isBookMark"] isEqualToString:@"Y"] )
                                                     {
                                                         NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
                                                         [dicM_Check setObject:str_UserId forKey:str_UserId];
                                                     }
                                                 }
                                                 
                                                 [weakSelf.tbv_List reloadData];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddChannelCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     channelId = 5;
     channelName = "\Uc601\Uc5b4\Ub4e3\Uae30_\Uae30\Ucd9c";
     channelUrl = englishLC;
     imgUrl = "000/000/english_lc.png";
     isBookMark = N;
     isMemberAllow = A;
     memberLevel = 9;
     statusCode = T;
     */

    NSDictionary *dic = self.arM_List[indexPath.row];
    
    if( [[dic objectForKey:@"channelType"] isEqualToString:@"channel"] )
    {
        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey_YM:@"imgUrl"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
    }
    else
    {
        cell.iv_User.image = BundleImage(@"hashtag.png");
    }
    
    cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];
    
    cell.lb_SubTitle.text = [dic objectForKey_YM:@"channelName"];
    
    cell.lb_Count.text = [NSString stringWithFormat:@"%@명", [dic objectForKey_YM:@"userCount"]];

    NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    NSInteger nSelectedUserId = [[dicM_Check objectForKey:str_UserId] integerValue];
    if( nSelectedUserId > 0 )
    {
        cell.btn_Check.selected = YES;
    }
    else
    {
        cell.btn_Check.selected = NO;
    }

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    
    AddChannelCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.btn_Check.selected = !cell.btn_Check.selected;
    
    if( cell.btn_Check.selected )
    {
        //선택이면 추가
        [dicM_Check setObject:str_UserId forKey:str_UserId];
    }
    else
    {
        //아니면 우선 삭제
        [dicM_Check removeObjectForKey:str_UserId];
    }
    
    if( dicM_Check.count > 0 )
    {
        [self buttonOn];
    }
    else
    {
        [self buttonOff];
    }

}

- (void)buttonOn
{
    self.btn_Add.userInteractionEnabled = YES;
    
    self.btn_Add.layer.borderColor = kMainColor.CGColor;
    [self.btn_Add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_Add setBackgroundColor:kMainColor];
}

- (void)buttonOff
{
    self.btn_Add.userInteractionEnabled = NO;
    
    self.btn_Add.layer.borderColor = deSelectColor.CGColor;
    [self.btn_Add setTitleColor:deSelectColor forState:UIControlStateNormal];
    [self.btn_Add setBackgroundColor:[UIColor whiteColor]];
}



- (IBAction)goAddChannel:(id)sender
{
    if( dicM_Check.count <= 0 ) return;
    
    self.btn_Add.userInteractionEnabled = NO;
    
    NSMutableString *strM = [NSMutableString string];
//    NSArray *ar_AllKeys = dicM_Check.allKeys;
//    for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
//    {
//        [strM appendString:[dicM_Check objectForKey:ar_AllKeys[i]]];
//        [strM appendString:@"-Y-"];
////        [strM appendString:@","];
//    }
    
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        NSDictionary *dic = self.arM_List[i];
        NSString *str_ChannelId = [dicM_Check objectForKey:[NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]]];
        if( str_ChannelId == nil || [str_ChannelId integerValue] <= 0 )
        {
            [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]]];
            [strM appendString:@"-N-"];
            [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"channelType"]]];
            [strM appendString:@","];
        }
        else
        {
            [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]]];
            [strM appendString:@"-Y-"];
            [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"channelType"]]];
            [strM appendString:@","];
        }
    }
    
    if( [strM hasSuffix:@","] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        strM, @"strBookmarkInfo",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/bookmark"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadNoti" object:nil];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                [window makeToast:@"등록했습니다" withPosition:kPositionBottom];
                                                
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.btn_Add.userInteractionEnabled = YES;
                                    }];
}


@end
