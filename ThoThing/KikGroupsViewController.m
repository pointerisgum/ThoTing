//
//  KikGroupsViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 28..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikGroupsViewController.h"
#import "KikGroupsHeaderCell.h"
#import "KikGroupsCell.h"
#import "KikGroupMakeViewController.h"
#import "ChatIngUserCell.h"
#import "KikRoomInfoViewController.h"
#import "KikBotMainCell.h"

@interface KikGroupsViewController ()
{
    BOOL isSearchMode;
    NSString *str_UserImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *arM_MainHeader;
@property (nonatomic, strong) NSMutableArray *arM_BackUpMainHeader;
@property (nonatomic, strong) NSMutableArray *arM_MyGroup;
@property (nonatomic, strong) NSMutableArray *arM_Group;
@property (nonatomic, strong) NSMutableArray *arM_BackUpMyGroup;
@property (nonatomic, strong) NSMutableArray *arM_BackUpGroup;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UITextField *tf_Search;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_NaviHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CancelWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SearchBgHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvBottom;
@end

@implementation KikGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arM_MainHeader = [NSMutableArray array];
    self.arM_BackUpMainHeader = [NSMutableArray array];
    
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hide];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
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
    __weak __typeof(&*self)weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/open/group/tag/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                str_UserImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
                                                NSArray *ar_MyGroup = [resulte objectForKey:@"myGroups"];
                                                if( ar_MyGroup && ar_MyGroup.count > 0 )
                                                {
                                                    weakSelf.arM_MyGroup = [NSMutableArray arrayWithArray:[resulte objectForKey:@"myGroups"]];
                                                    weakSelf.arM_BackUpMyGroup = [NSMutableArray arrayWithArray:[resulte objectForKey:@"myGroups"]];
                                                    
                                                    [weakSelf.arM_MainHeader addObject:@"나의 그룹"];
                                                    [weakSelf.arM_BackUpMainHeader addObject:@"나의 그룹"];
                                                }

                                                NSArray *ar_Group = [resulte objectForKey:@"tagList"];
                                                if( ar_Group && ar_Group.count > 0 )
                                                {
                                                    weakSelf.arM_Group = [NSMutableArray arrayWithArray:[resulte objectForKey:@"tagList"]];
                                                    weakSelf.arM_BackUpGroup = [NSMutableArray arrayWithArray:[resulte objectForKey:@"tagList"]];

                                                    [weakSelf.arM_MainHeader addObject:@"그룹들"];
                                                    [weakSelf.arM_BackUpMainHeader addObject:@"그룹들"];
                                                }
                                                
                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                    }];
}

- (void)searchWord:(NSString *)aWord
{
    if( aWord.length <= 0 )
    {
        [self.arM_MainHeader removeAllObjects];
        [self.arM_MyGroup removeAllObjects];
        [self.arM_Group removeAllObjects];
        [self.tbv_List reloadData];

        return;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    NSString *str_SearchWord = [aWord stringByReplacingOccurrencesOfString:@"#" withString:@""];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        str_SearchWord, @"tagName",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/search/open/group/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                [weakSelf.arM_MainHeader removeAllObjects];
                                                
                                                weakSelf.arM_MyGroup = [NSMutableArray arrayWithArray:[resulte objectForKey:@"matchGroups"]];
                                                if( weakSelf.arM_MyGroup.count > 0 )
                                                {
                                                    [weakSelf.arM_MainHeader addObject:@""];
                                                }
                                                
                                                weakSelf.arM_Group = [NSMutableArray arrayWithArray:[resulte objectForKey:@"similarGroups"]];
                                                if( weakSelf.arM_Group.count > 0 )
                                                {
                                                    [weakSelf.arM_MainHeader addObject:@"유사한 그룹"];
                                                }

                                                [weakSelf.tbv_List reloadData];
                                            }
                                        }
                                    }];
}



#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    __weak __typeof(&*self)weakSelf = self;
    
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            weakSelf.lc_TbvBottom.constant = -keyboardBounds.size.height;
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            weakSelf.lc_TbvBottom.constant = 0.f;
        }
    }completion:^(BOOL finished) {
        
    }];
}

- (void)startSearchMode
{
    isSearchMode = YES;
    [self.arM_MainHeader removeAllObjects];
    [self.arM_MyGroup removeAllObjects];
    [self.arM_Group removeAllObjects];
    [self.tbv_List reloadData];
    
    __weak __typeof(&*self)weakSelf = self;
    self.lc_NaviHeight.constant = 0.f;
    self.lc_CancelWidth.constant = 44.f;
    self.lc_SearchBgHeight.constant = 64.f;
    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];
}



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_Search )
    {
        if( self.tf_Search.text.length > 0 )
        {
            [self updateSearchWord];
        }
        else
        {
            [self startSearchMode];
        }
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(updateSearchWord) withObject:nil afterDelay:0.1f];

    return YES;
}

- (void)updateSearchWord
{
    [self searchWord:self.tf_Search.text];
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arM_MainHeader.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 && self.arM_MyGroup.count > 0 )
    {
        return self.arM_MyGroup.count;
    }
    
    return self.arM_Group.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( isSearchMode )
    {
        /*
         owerId: 오픈그룹 개설자 ID
         ownerEmail: 오픈그룹 개설자 email
         ownerName: 오픈그룹 개설자 사용자명
         ownerThumbnail: 오픈그룹 개설자 사용자 이미지
         rId: 채팅방 rId
         questionId: 채팅방 questionId
         channelId: 채팅방 채널 ID
         roomName: 오픈그룹명
         sendbirdChannelType: 샌드버드 채널 유형 [open, group]
         sendbirdChannelUrl: 샌드버드 채널 url
         */
        
        BOOL isMyGroup = YES;
        NSDictionary *dic = nil;
        NSString *str_Header = self.arM_MainHeader[indexPath.section];
        if( [str_Header isEqualToString:@"유사한 그룹"] )
        {
            isMyGroup = NO;
            dic = self.arM_Group[indexPath.row];
        }
        else
        {
            dic = self.arM_MyGroup[indexPath.row];
        }
        
        ChatIngUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIngUserCell"];
        
        NSString *str_RoomName = [self getSharpName:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"roomName"]]];
        if( isMyGroup )
        {
            cell.lb_Name.text = [str_RoomName stringByReplacingOccurrencesOfString:@"#" withString:@""];
        }
        else
        {
            cell.lb_Name.text = str_RoomName;
        }
        
        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"ownerThumbnail"]];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] placeholderImage:BundleImage(@"no_image@2x.png")];
        
        cell.lb_NinkName.text = [dic objectForKey_YM:@"hashTag"];
        
        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"memberCount"]];
        
        return cell;
    }
    
    NSDictionary *dic = nil;
    NSString *str_Header = self.arM_MainHeader[indexPath.section];
    if( [str_Header isEqualToString:@"그룹들"] )
    {
        KikGroupsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KikGroupsCell"];
        dic = self.arM_Group[indexPath.row];
        
        cell.lb_Title.text = [self getSharpName:[dic objectForKey_YM:@"tagName"]];
        cell.lb_Count.text = @"";
        
        return cell;
    }
    else
    {
        KikBotMainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KikBotMainCell"];
        dic = self.arM_MyGroup[indexPath.row];
        cell.lb_MemberCount.text = @"";
        
        NSString *str_Thumb = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"groupThumbnail"]];
        if( str_Thumb && str_Thumb.length > 0 )
        {
            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", str_UserImagePrefix, str_Thumb]]];
        }
        else
        {
            cell.iv_User.image = BundleImage(@"");
            cell.iv_User.backgroundColor = [UIColor colorWithHexString:@"FF9900"];
            cell.lb_MemberCount.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"memberCount"]];
        }
        
        
        
        NSString *str_RoomNameTmp = [self getSharpName:[dic objectForKey_YM:@"roomName"]];;
        cell.lb_Titile.text = [str_RoomNameTmp stringByReplacingOccurrencesOfString:@"#" withString:@""];
        cell.lb_Tags.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"hashTag"]];
        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"memberCount"]];
        
        return cell;
    }

    return nil;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( isSearchMode )
    {
        [self.view endEditing:YES];
        
        NSDictionary *dic = nil;
        NSString *str_Header = self.arM_MainHeader[indexPath.section];
        if( [str_Header isEqualToString:@"유사한 그룹"] )
        {
            dic = self.arM_Group[indexPath.row];
        }
        else
        {
            dic = self.arM_MyGroup[indexPath.row];
        }

        KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
        vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]];    //2494
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    NSDictionary *dic = nil;
    NSString *str_Header = self.arM_MainHeader[indexPath.section];
    if( [str_Header isEqualToString:@"그룹들"] )
    {
        dic = self.arM_Group[indexPath.row];
        NSString *str_Name = [self getSharpName:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"tagName"]]];
        self.tf_Search.text = str_Name;
        [self startSearchMode];
        [self searchWord:str_Name];
    }
    else
    {
        dic = self.arM_MyGroup[indexPath.row];
        KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
        vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]];    //2494
        vc.str_Tag = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"hashTag"]];
        vc.roomType = kOpenGroup;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( isSearchMode )
    {
        return 54.f;
    }
    
    NSString *str_Header = self.arM_MainHeader[indexPath.section];
    if( [str_Header isEqualToString:@"그룹들"] )
    {
        return 54.f;
    }
    
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *str_Title = [self.arM_MainHeader objectAtIndex:section];
    if( str_Title && str_Title.length > 0 )
    {
        return 40.f;
    }
    
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"KikGroupsHeaderCell";
    KikGroupsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    cell.lb_Title.text = [self.arM_MainHeader objectAtIndex:section];
    
    return cell;
}

- (NSString *)getSharpName:(NSString *)aName
{
    if( [aName hasPrefix:@"#"] == NO )
    {
        aName = [NSString stringWithFormat:@"#%@", aName];
    }
    
    return aName;
}

#pragma mark - IBAction
- (IBAction)goCancel:(id)sender
{
    [self endSearchMode];
}
 
- (void)endSearchMode
{
    isSearchMode = NO;
    self.tf_Search.text = @"";
    self.arM_MainHeader = [NSMutableArray arrayWithArray:self.arM_BackUpMainHeader];
    self.arM_MyGroup = [NSMutableArray arrayWithArray:self.arM_BackUpMyGroup];
    self.arM_Group = [NSMutableArray arrayWithArray:self.arM_BackUpGroup];
    [self.tbv_List reloadData];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.view endEditing:YES];
    self.lc_NaviHeight.constant = 64.f;
    self.lc_CancelWidth.constant = 0.f;
    self.lc_SearchBgHeight.constant = 44.f;
    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];
}

- (IBAction)goMakeGroups:(id)sender
{
    KikGroupMakeViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikGroupMakeViewController"];
    vc.isGroupsMode = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
