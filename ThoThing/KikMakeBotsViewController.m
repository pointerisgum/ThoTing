//
//  KikMakeBotsViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikMakeBotsViewController.h"
#import "SearchBarViewController.h"
#import "MWPhotoBrowser.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChatFeedViewController.h"
#import "KikGroupsHeaderCell.h"
#import "KikRoomInfoViewController.h"

@interface KikMakeBotsViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZImageEditingControllerDelegate>
{
    NSString *str_BotId;
    
    NSString *str_UserImagePrefix;
    NSMutableString *strM_UserIds;
    NSMutableString *strM_RoomName;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) KikGroupsHeaderCell *headerCell;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, assign) CGRect frameRect;
@property (nonatomic, weak) IBOutlet UIButton *btn_Start;
@property (nonatomic, weak) IBOutlet UIView *v_ThumbBg;
@property (nonatomic, weak) IBOutlet UIButton *btn_Thumb;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UITextField *tf_GroupName;
@property (nonatomic, weak) IBOutlet UIView *v_AddMemberBg;
@property (nonatomic, weak) IBOutlet UITextField *tf_AddMember;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvBottom;
@property (nonatomic, weak) IBOutlet UITextField *tf_Tag;
@end

@implementation KikMakeBotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *overlayImage = [UIImage imageNamed:@"kik_image_edith.png"];
    CGFloat newX = [UIScreen mainScreen].bounds.size.width / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat newY = [UIScreen mainScreen].bounds.size.height / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    self.frameRect = CGRectMake(newX, newY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self.overlayImageView = [[UIImageView alloc] initWithFrame:self.frameRect];
    self.overlayImageView.image = overlayImage;

    
    self.arM_List = [NSMutableArray array];
    
    self.v_ThumbBg.layer.cornerRadius = self.v_ThumbBg.frame.size.width / 2;
    self.v_ThumbBg.layer.borderColor = kRoundColor.CGColor;
    self.v_ThumbBg.layer.borderWidth = 1.f;
    
    self.v_AddMemberBg.layer.cornerRadius = 4.f;
    self.v_AddMemberBg.layer.borderColor = kRoundColor.CGColor;
    self.v_AddMemberBg.layer.borderWidth = 1.f;

    self.headerCell = [self.tbv_List dequeueReusableCellWithIdentifier:@"KikGroupsHeaderCell"];
    self.tbv_List.tableHeaderView = self.headerCell;
    
    if( self.dic_ModifyData )
    {
        [self.btn_Start setTitle:@"수정" forState:0];
        
        NSString *str_UserImagePrefix = [self.dic_ModifyData objectForKey_YM:@"userImg_prefix"];
        NSString *str_Thumb = [self.dic_ModifyData objectForKey:@"chatThumbnail"];
        [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", str_UserImagePrefix, str_Thumb]]];
        
        id hashTag = [self.dic_ModifyData objectForKey:@"hashTagStr"];
        if( [hashTag isKindOfClass:[NSNull class]] == NO )
        {
            self.tf_Tag.text = hashTag;
        }
        
        NSString *str_RoomName = [self.dic_ModifyData objectForKey:@"roomName"];
        self.tf_GroupName.text = str_RoomName;
        
        NSArray *ar = [self.dic_ModifyData objectForKey:@"examList"];
        [self.arM_List addObjectsFromArray:ar];
        [self.tbv_List reloadData];
    }
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


#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_Tag )
    {
        if( textField.text.length <= 0 )
        {
            self.tf_Tag.text = @"#";
        }
    }
    else if( textField == self.tf_AddMember )
    {
        __weak __typeof(&*self)weakSelf = self;

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"SearchNavi"];
        SearchBarViewController *vc = [navi.viewControllers firstObject];
        vc.isLibraryMode = YES;
        vc.isBotMakeMode = YES;
        vc.ar_DidSelectList = self.arM_List;
        [vc setCompletionBlock:^(id completeResult) {
            
            NSLog(@"%@", completeResult);
            weakSelf.arM_List = [NSMutableArray arrayWithArray:completeResult];
            [weakSelf.tbv_List reloadData];
        }];
        [self.navigationController pushViewController:vc animated:YES];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( textField == self.tf_Tag )
    {
        [self performSelector:@selector(changeInPutTag:) withObject:string afterDelay:0.1f];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}


- (void)changeInPutTag:(NSString *)aString
{
    self.tf_Tag.text = [self.tf_Tag.text stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    if( [aString isEqualToString:@" "] )
    {
        aString = @",";
    }
    
    if( (self.tf_Tag.text.length == 0) || (self.tf_Tag.text.length == 1 && [self.tf_Tag.text isEqualToString:@"#"]) )
    {
        self.tf_Tag.text = @"#";
        return;
    }
    
    const char * _char = [aString cStringUsingEncoding:NSUTF8StringEncoding];
    int isBackSpace = strcmp(_char, "\b");
    if (isBackSpace == -8)
    {
        NSString *str_LastChar = [self.tf_Tag.text substringWithRange:NSMakeRange(self.tf_Tag.text.length - 1, 1)];
        NSLog(@"%@", str_LastChar);
        if( [str_LastChar isEqualToString:@"#"] )
        {
            self.tf_Tag.text = [self.tf_Tag.text substringToIndex:self.tf_Tag.text.length - 2];
        }
        
        return;
    }
    
    NSArray *ar = [self.tf_Tag.text componentsSeparatedByString:@","];
    if( ar.count > 3 )
    {
        ALERT_ONE(@"태그는 3개까지 등록 가능합니다");
        //        [ALToastView toastKeyboardTop:self.view withText:@"태그는 3개까지 등록 가능합니다"];
        NSMutableString *strM = [NSMutableString string];
        for( NSInteger i = 0; i < 3; i++ )
        {
            [strM appendString:ar[i]];
            [strM appendString:@","];
        }
        
        if( [strM hasSuffix:@","] )
        {
            [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
        }
        
        self.tf_Tag.text = strM;
        return;
    }
    
    NSMutableString *strM = [NSMutableString string];
    for( NSInteger i = 0; i < ar.count; i++ )
    {
        NSString *str = ar[i];
        if( [str hasPrefix:@"#"] == NO )
        {
            [strM appendString:@"#"];
        }
        [strM appendString:str];
        [strM appendString:@","];
    }
    
    if( [strM hasSuffix:@","] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }
    
    self.tf_Tag.text = strM;
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( self.arM_List.count > 0 )
    {
        self.btn_Start.selected = YES;
    }
    else
    {
        self.btn_Start.selected = NO;
    }
    
    self.headerCell.lb_Title.text = [NSString stringWithFormat:@"%ld", self.arM_List.count];
    return self.arM_List.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.contentView.layer.shadowOffset = CGSizeMake(10, 10);
    //    cell.layer.shadowOffset = CGSizeMake(10, 10);
    
    
    cell.layer.masksToBounds = NO;
    cell.clipsToBounds = YES;
    cell.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    cell.layer.borderWidth = 0.5f;
    
    
    //    cell.layer.shadowOpacity = 1.0;
    //    cell.layer.shadowRadius = 1;
    //    cell.layer.shadowOffset = CGSizeMake(5, 5);
    //    cell.layer.shadowColor = [UIColor redColor].CGColor;
    
    //    cell.layer.shadowOffset = CGSizeMake(25, 25);
    //    cell.layer.shadowColor = [[UIColor redColor] CGColor];
    //    cell.layer.shadowRadius = 3;
    //    cell.layer.shadowOpacity = .75f;
    //    CGRect shadowFrame = cell.layer.bounds;
    //    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    //    cell.layer.shadowPath = shadowPath;
    
    //    cell.contentView.layer.shadowOpacity = 1.0;
    //    cell.contentView.layer.shadowRadius = 1;
    //    cell.contentView.layer.shadowOffset = CGSizeMake(0, 2);
    //    cell.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    //    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 100)];
    //    v.backgroundColor = [UIColor whiteColor];
    
    
    
    for( id subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    if( 1 )
    {
        /*
         통안의 검색 결과
         bgColor = "bgm-bluegray";
         codeHex = "#607D8B";
         codeName = "bgm-bluegray";
         examId = 415;
         examTitle = "2016\Ud559\Ub144\Ub3c4 3\Uc6d4 \Uace03 \Uc804\Uad6d\Uc5f0\Ud569\Ud559\Ub825\Ud3c9\Uac00";
         examUniqueUserCount = 13;
         examUserCount = 18;
         hashTag = "#\Ud559\Ud3c9";
         personGrade = 0;
         questionCount = 8;
         schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
         score = 160;
         subjectName = "\Uad6d\Uc5b4";
         */
        
        UIImageView *iv_Cover = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 60, 80)];
        
        if( [[dic objectForKey:@"codeHex"] isEqual:[NSNull null]] || [dic objectForKey:@"codeHex"] == nil )
        {
            if( [[dic objectForKey:@"subjectCodeHex"] isEqual:[NSNull class]] == NO && [dic objectForKey:@"subjectCodeHex"] )
            {
                iv_Cover.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"subjectCodeHex"]];
            }
            else
            {
                iv_Cover.backgroundColor = [UIColor blackColor];
            }
        }
        else
        {
            iv_Cover.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        }
        
        UILabel *lb_Subject = [[UILabel alloc] initWithFrame:CGRectMake(iv_Cover.frame.origin.x + 5, iv_Cover.frame.origin.y + 5,
                                                                        iv_Cover.frame.size.width - 10, iv_Cover.frame.size.height - 10)];
        lb_Subject.text = [dic objectForKey:@"subjectName"];
        lb_Subject.numberOfLines = 0;
        lb_Subject.textAlignment = NSTextAlignmentCenter;
        lb_Subject.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        lb_Subject.textColor = [UIColor whiteColor];
        lb_Subject.minimumScaleFactor = 0.5f;
        
        UILabel *lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(iv_Cover.frame.origin.x + iv_Cover.frame.size.width + 10, 10,
                                                                      self.view.bounds.size.width - (iv_Cover.frame.origin.x + iv_Cover.frame.size.width + 10 + 8 + 40), 36)];
        lb_Title.text = [dic objectForKey:@"examTitle"];
        lb_Title.numberOfLines = 2;
        lb_Title.textAlignment = NSTextAlignmentLeft;
        lb_Title.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Title.textColor = kMainColor;
        
        UILabel *lb_Tag = [[UILabel alloc] initWithFrame:CGRectMake(lb_Title.frame.origin.x, lb_Title.frame.origin.y + lb_Title.frame.size.height,
                                                                    lb_Title.frame.size.width, 20)];
        lb_Tag.text = @"tag";//[dic objectForKey_YM:@"hashTag"];
        lb_Tag.numberOfLines = 1;
        lb_Tag.textAlignment = NSTextAlignmentLeft;
        lb_Tag.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Tag.textColor = [UIColor lightGrayColor];
        
        UILabel *lb_Ower = [[UILabel alloc] initWithFrame:CGRectMake(lb_Tag.frame.origin.x, lb_Tag.frame.origin.y + lb_Tag.frame.size.height,
                                                                     lb_Tag.frame.size.width, 20)];
        lb_Ower.text = [dic objectForKey:@"schoolGrade"];
        lb_Ower.numberOfLines = 1;
        lb_Ower.textAlignment = NSTextAlignmentLeft;
        lb_Ower.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Ower.textColor = [UIColor darkGrayColor];
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIButton *btn_Info = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Info.frame = CGRectMake(window.bounds.size.width - 55, 0, 40, 50);
        [btn_Info setImage:BundleImage(@"info.png") forState:UIControlStateNormal];
        btn_Info.tag = indexPath.section;
//        [btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *btn_Check = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Check.selected = NO;
        btn_Check.frame = CGRectMake(window.bounds.size.width - 55, 50, 40, 50);
        
        [btn_Check setImage:BundleImage(@"kik_cell_select_off.png") forState:UIControlStateNormal];
        [btn_Check setImage:BundleImage(@"kik_cell_select_on.png") forState:UIControlStateSelected];
        btn_Check.tag = indexPath.section;
        [btn_Check addTarget:self action:@selector(onCheck:) forControlEvents:UIControlEventTouchUpInside];
        
        for( NSInteger i = 0; i < self.arM_List.count; i++ )
        {
            NSDictionary *dic_Tmp = self.arM_List[i];
            if( [dic_Tmp isEqual:dic] )
            {
                btn_Check.selected = YES;
                break;
            }
        }
        
        [cell.contentView addSubview:btn_Check];
        [cell.contentView addSubview:iv_Cover];
        [cell.contentView addSubview:lb_Subject];
        [cell.contentView addSubview:lb_Title];
        [cell.contentView addSubview:lb_Tag];
        [cell.contentView addSubview:lb_Ower];
        [cell.contentView addSubview:btn_Info];
    }
    else
    {
        /*
         channelName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         examId = 62;
         examNo = 319;
         examTitle = "1\Ub4f1\Uae09\Ub9cc\Ub4e4\Uae30 \Ud55c\Uad6d\Uc0ac 1060\Uc81c";
         hashString = "\Uc774\Uc21c\Uc2e0\Uc774 \Uc774\Ub044\Ub294 \Uc218\Uad70\Uc758 \Uc2b9\Ub9ac\Ub97c \Ud1b5\Ud574 (\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000)\Uace1\Ucc3d\n\Uc9c0\Ub300\Ub97c \Uc9c0\Ud0a4\Uace0\Uff0c \Uc65c\Uad70\Uc758 \Ubb3c\Uc790 \Uc218\Uc1a1\Uc5d0 \Ud0c0\Uaca9\Uc744 \Uc904 \Uc218 \Uc788\Uc5c8\Ub2e4.";
         personGrade = "\Uc804\Uccb4";
         publisherName = "\Ubbf8\Ub798\Uc5d4";
         questionCount = 520;
         questionId = 3141;
         schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
         subjectName = "\Ud55c\Uad6d\Uc0ac";
         teacherName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         */
        
        UILabel *lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10,
                                                                      self.view.bounds.size.width - 30, 20)];
        lb_Title.text = [dic objectForKey:@"examTitle"];
        lb_Title.numberOfLines = 1;
        lb_Title.textAlignment = NSTextAlignmentLeft;
        lb_Title.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Title.textColor = kMainColor;
        
        UILabel *lb_Tag = [[UILabel alloc] initWithFrame:CGRectMake(lb_Title.frame.origin.x, lb_Title.frame.origin.y + lb_Title.frame.size.height,
                                                                    lb_Title.frame.size.width, 20)];
        lb_Tag.text = [NSString stringWithFormat:@"#%@ #%@ #%@", [dic objectForKey:@"schoolGrade"], [dic objectForKey:@"personGrade"], [dic objectForKey:@"subjectName"]];
        lb_Tag.numberOfLines = 1;
        lb_Tag.textAlignment = NSTextAlignmentLeft;
        lb_Tag.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Tag.textColor = [UIColor lightGrayColor];
        
        UILabel *lb_Discription = [[UILabel alloc] initWithFrame:CGRectMake(lb_Tag.frame.origin.x, lb_Tag.frame.origin.y + lb_Tag.frame.size.height,
                                                                            lb_Title.frame.size.width, 36)];
        lb_Discription.text = [dic objectForKey:@"hashString"];
        lb_Discription.numberOfLines = 2;
        lb_Discription.textAlignment = NSTextAlignmentLeft;
        lb_Discription.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Discription.textColor = [UIColor darkGrayColor];
        
        [cell.contentView addSubview:lb_Title];
        [cell.contentView addSubview:lb_Tag];
        [cell.contentView addSubview:lb_Discription];
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40.f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    static NSString *CellIdentifier = @"KikGroupsHeaderCell";
//    KikGroupsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//
//    cell.lb_Title.text = [NSString stringWithFormat:@"%ld", self.arM_List.count];
//
//    return cell;
//}


- (void)onCheck:(UIButton *)btn
{
    if( self.dic_ModifyData )
    {
        //봇 수정시 문제는 수정 할 수 없음 왜냐면 기존 다른 문제에 영향을 끼쳐서 그렇다고 함 17.11.24 제권님
    }
    else
    {
        NSDictionary *dic = self.arM_List[btn.tag];
        
        [self.arM_List removeObject:dic];
        [self.tbv_List reloadData];
    }
}


#pragma mark - DZImageEditingControllerDelegate
- (void)imageEditingControllerDidCancel:(DZImageEditingController *)editingController
{
    [editingController dismissViewControllerAnimated:YES
                                          completion:nil];
}

- (void)imageEditingController:(DZImageEditingController *)editingController
     didFinishEditingWithImage:(UIImage *)editedImage
{
    self.iv_Thumb.image = editedImage;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        DZImageEditingController *editingViewController = [DZImageEditingController new];
        editingViewController.defaultScale = 1.0f;
        editingViewController.image = image;
        editingViewController.overlayView = self.overlayImageView;
        editingViewController.cropRect = self.frameRect;
        editingViewController.delegate = self;
        
        [self presentViewController:editingViewController
                           animated:YES
                         completion:nil];
    }];
}




#pragma mark - IBAction
- (IBAction)goStart:(id)sender
{
    [self.view endEditing:YES];
    
    __weak __typeof(&*self)weakSelf = self;
    
    if( self.btn_Start.selected == NO ) return;
    
    if( self.tf_GroupName.text.length <= 0 )
    {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@""
                                             message:@"봇 이름을 입력해 주세요"
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[@"확인"]
                                            tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                
                                                if (buttonIndex == controller.cancelButtonIndex)
                                                {
                                                    NSLog(@"Cancel Tapped");
                                                }
                                                else if (buttonIndex == controller.destructiveButtonIndex)
                                                {
                                                    NSLog(@"Delete Tapped");
                                                }
                                                else if (buttonIndex >= controller.firstOtherButtonIndex)
                                                {
                                                    [weakSelf.tf_GroupName becomeFirstResponder];
                                                }
                                            }];
        return;
    }
    
    if( self.tf_Tag.text.length <= 1 )
    {
        [UIAlertController showAlertInViewController:self
                                           withTitle:@""
                                             message:@"태그를 입력해 주세요"
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[@"확인"]
                                            tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                
                                                if (buttonIndex == controller.cancelButtonIndex)
                                                {
                                                    NSLog(@"Cancel Tapped");
                                                }
                                                else if (buttonIndex == controller.destructiveButtonIndex)
                                                {
                                                    NSLog(@"Delete Tapped");
                                                }
                                                else if (buttonIndex >= controller.firstOtherButtonIndex)
                                                {
                                                    [weakSelf.tf_Tag becomeFirstResponder];
                                                }
                                            }];
        return;
    }
    
    if( self.iv_Thumb.image == nil )
    {
        self.btn_Thumb.selected = YES;
        
        [UIAlertController showAlertInViewController:self
                                           withTitle:@""
                                             message:@"이미지를 선택해 주세요"
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@[@"확인"]
                                            tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                
                                                if (buttonIndex == controller.cancelButtonIndex)
                                                {
                                                    NSLog(@"Cancel Tapped");
                                                }
                                                else if (buttonIndex == controller.destructiveButtonIndex)
                                                {
                                                    NSLog(@"Delete Tapped");
                                                }
                                                else if (buttonIndex >= controller.firstOtherButtonIndex)
                                                {
                                                    [weakSelf goThumb:nil];
                                                }
                                            }];
        
        return;
    }

    self.btn_Start.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"user", @"type",
                                        nil];
    
    [[WebAPI sharedData] imageUpload:@"v1/upload/user/image/uploader"
                               param:dicM_Params
                          withImages:[NSDictionary dictionaryWithObject:UIImageJPEGRepresentation(self.iv_Thumb.image, 0.3f) forKey:@"file"]
                           withBlock:^(id resulte, NSError *error) {
                               
                               NSString *str_UploadImageUrl = nil;
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                   if( nCode == 200 )
                                   {
                                       str_UploadImageUrl = [resulte objectForKey:@"ImageUrl"];
                                   }
                               }
                               
                               weakSelf.btn_Start.userInteractionEnabled = YES;
                               
                               [weakSelf makePublicGroup:str_UploadImageUrl];
                           }];
}

- (void)makePublicGroup:(NSString *)coverUrl
{
    __weak __typeof(&*self)weakSelf = self;
    
    self.btn_Start.userInteractionEnabled = NO;
    
    
    
    
    NSMutableString *strM_ExamId = [NSMutableString string];
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        NSDictionary *dic = self.arM_List[i];
        [strM_ExamId appendString:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"examId"]]];
        [strM_ExamId appendString:@","];
    }
    
    if( [strM_ExamId hasSuffix:@","] )
    {
        [strM_ExamId deleteCharactersInRange:NSMakeRange([strM_ExamId length]-1, 1)];
    }

    
    
    
    
    strM_UserIds = nil;
    strM_UserIds = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
//    for( NSInteger i = 0; i < self.arM_List.count; i++ )
//    {
//        NSDictionary *dic = self.arM_List[i];
//        [strM_UserIds appendString:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]]];
//        [strM_UserIds appendString:@","];
//    }
//
//    if( [strM_UserIds hasSuffix:@","] )
//    {
//        [strM_UserIds deleteCharactersInRange:NSMakeRange([strM_UserIds length]-1, 1)];
//    }

    
    
    /////////////////////////
    NSMutableArray *arM_UserList = [NSMutableArray array];
    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_MyInfo];
    
    
    strM_RoomName = [NSMutableString stringWithString:self.tf_GroupName.text];
    
    //    NSString *str_Tag = [self.tf_Tag.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    //    NSString* str_Tag = [self.tf_Tag.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    if( str_UserImagePrefix == nil || str_UserImagePrefix.length <= 0 )
    {
        str_UserImagePrefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"];
    }

    NSString *str_Path = @"v1/make/exam/chatbot";
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.tf_GroupName.text, @"chatBotName",
//                                        strM_ExamId, @"examIdStr",
                                        coverUrl, @"imgUrl",
//                                        [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl], @"imgUrl",
                                        self.tf_Tag.text, @"hashTagStr",
                                        nil];
    
    if( self.dic_ModifyData )
    {
        str_Path = @"v1/update/exam/chatbot";
        [dicM_Params setObject:[NSString stringWithFormat:@"%@", [self.dic_ModifyData objectForKey:@"botId"]] forKey:@"botId"];
    }
    else
    {
        [dicM_Params setObject:strM_ExamId forKey:@"examIdStr"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            if( self.dic_ModifyData )
                                            {
                                                SDImageCache *imageCache = [SDImageCache sharedImageCache];
                                                [imageCache clearMemory];
                                                [imageCache clearDisk];

                                                [Util showToast:@"수정 되었습니다"];
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }
                                            else
                                            {
                                                str_BotId = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userId"]];
                                                
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    NSString *str_SDBChannelUrl = [resulte objectForKey_YM:@"sendbirdChannelUrl"];
                                                    if( str_SDBChannelUrl.length > 0 )
                                                    {
                                                        //방이 있으면
                                                        NSDictionary *dic = resulte;
                                                        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                        [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                        [dicM setObject:str_BotId forKey:@"botUserId"];
                                                        [dicM setObject:@"chatBot" forKey:@"roomType"];
                                                        
                                                        [weakSelf makePublicSendbird:dic withCover:coverUrl];
                                                    }
                                                    else
                                                    {
                                                        //아마 방이 없을때가 대부분일듯
                                                        [weakSelf makeNewRoom:resulte withUserId:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"userId"]] withImageUrl:@"" withCoverUrl:coverUrl];
                                                    }
                                                }
                                                else
                                                {
                                                    [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }
                                        
                                        weakSelf.btn_Start.userInteractionEnabled = YES;
                                    }];
}

- (void)makeNewRoom:(NSDictionary *)dic withUserId:(NSString *)str_UserId withImageUrl:(NSString *)str_ImageUrl withCoverUrl:(NSString *)coverUrl
{
    __block NSDictionary *dic_BotInfo = [NSDictionary dictionaryWithDictionary:dic];
    
    __weak __typeof(&*self)weakSelf = self;

    __block NSString *str_CoverUrl = [NSString stringWithString:coverUrl];
    
    self.btn_Start.userInteractionEnabled = NO;
    
    //기존 방이 없을 경우 만들기
    if( str_UserImagePrefix == nil || str_UserImagePrefix.length <= 0 )
    {
        str_UserImagePrefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"];
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        str_UserId, @"inviteUserIdStr",
                                        @"group", @"channelType",
//                                        [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl], @"imgUrl",
                                        coverUrl, @"imgUrl",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/make/chat/room"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic_QnaInfo = [resulte objectForKey:@"qnaRoomInfo"];

                                                NSMutableArray *arM_UserList = [NSMutableArray array];
                                                NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                                                [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
                                                [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
                                                [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
                                                [arM_UserList addObject:dicM_MyInfo];

                                                NSMutableDictionary *dicM_OtherInfo = [NSMutableDictionary dictionary];
                                                [dicM_OtherInfo setObject:str_UserId forKey:@"userId"];
                                                [dicM_OtherInfo setObject:weakSelf.tf_GroupName.text forKey:@"userName"];
                                                [dicM_OtherInfo setObject:coverUrl forKey:@"imgUrl"];
                                                [arM_UserList addObject:dicM_OtherInfo];
                                                
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_QnaInfo];
                                                [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                [dicM setObject:str_BotId forKey:@"botUserId"];
                                                [dicM setObject:@"chatBot" forKey:@"roomType"];

                                                
                                                NSString *str_RId = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"rId"]];
//                                                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];

                                                
                                                
                                                
                                                
                                                
                                                if( str_CoverUrl )
                                                {
                                                    if( str_UserImagePrefix == nil || str_UserImagePrefix.length <= 0 )
                                                    {
                                                        str_UserImagePrefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"];
                                                    }

                                                    str_CoverUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, str_CoverUrl];
                                                }
                                                
                                                NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dic_BotInfo objectForKey_YM:@"botUserId"]] forKey:@"botUserId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dic_BotInfo objectForKey_YM:@"botOwnerId"]] forKey:@"botOwnerId"];
                                                [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dic_BotInfo objectForKey_YM:@"botId"]] forKey:@"botId"];

                                                
                                                
                                                NSError * err;
                                                NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
                                                __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                                                [SBDGroupChannel createChannelWithName:self.tf_GroupName.text isDistinct:NO userIds:@[str_UserId] coverUrl:str_CoverUrl data:str_Dic customType:@"chatBot"
                                                                     completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                                         
                                                                         if (error != nil)
                                                                         {
                                                                             NSLog(@"Error: %@", error);
                                                                             if( error.code == 400201 )
                                                                             {
                                                                                 UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                                                 [window makeToast:@"가입된 회원이 아닙니다" withPosition:kPositionCenter];
                                                                             }
                                                                             return;
                                                                         }
                                                                         
                                                                         SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                                                         NSLog(@"%@", baseChannel.channelUrl);
                                                                         [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                                                         
                                                                         //https://sites.google.com/site/thotingapi/api/api-jeong-ui/api-list/chaetingbangsendbirdchannelurlbyeongyeong
                                                                         //여기에 채널url 등록

//                                                                         NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
//                                                                         [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"questionId"]] forKey:@"questionId"];
//
//                                                                         UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
//                                                                         ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
//                                                                         vc.str_RId = str_RId;
//                                                                         vc.dic_Info = dicM;
//                                                                         vc.str_RoomName = self.tf_GroupName.text;
//                                                                         vc.str_RoomTitle = nil;
//                                                                         vc.str_RoomThumb = str_ImageUrl;
//                                                                         vc.ar_UserIds = [NSArray arrayWithObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]]];
//                                                                         vc.channel = channel;
//                                                                         vc.str_ChannelIdTmp = nil;
//                                                                         vc.dic_BotInfo = @{@"userId":str_UserId};
//                                                                         [self.navigationController pushViewController:vc animated:YES];

                                                                         KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
                                                                         vc.channel = channel;
                                                                         vc.str_QuestionId = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"questionId"]];
                                                                         vc.str_BotId = str_UserId;
                                                                         vc.roomType = kBot;
                                                                         vc.str_ChannelUrl = baseChannel.channelUrl;
                                                                         vc.str_ChatBotThumUrl = channel.coverUrl;
                                                                         [self.navigationController pushViewController:vc animated:YES];
                                                                     }];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        weakSelf.btn_Start.userInteractionEnabled = YES;
                                    }];
}

- (void)makePublicSendbird:(NSDictionary *)dic withCover:(NSString *)coverUrl
{
    NSString *str_SBDChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];
    
    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if( self.iv_Thumb.image )
    {
        //20170926 새로 추가한 부분
        //그룹방 개설시 이미지가 있으면 이미지를 샌드버드로 전송
        [dicM setObject:coverUrl forKey:@"roomCoverUrl"];
    }
    
//    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM options:0 error:&err];
    __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if( str_SBDChannelUrl && str_SBDChannelUrl.length > 0 )
    {
        [SBDGroupChannel getChannelWithUrl:str_SBDChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            
//            BOOL isHave = NO;
//            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//            NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
//            id tmp = [dic objectForKey_YM:@"channelIds"];
//            NSMutableArray *arM_ChannelIds;
//            if( [tmp isKindOfClass:[NSArray class]] == NO )
//            {
//                arM_ChannelIds = [NSMutableArray array];
//            }
//            else
//            {
//                arM_ChannelIds = [NSMutableArray arrayWithArray:[dic objectForKey:@"channelIds"]];
//            }
//
//            if( arM_ChannelIds == nil )
//            {
//                [dicM setObject:[NSArray array] forKey:@"channelIds"];
//            }
//            else
//            {
//                [dicM setObject:arM_ChannelIds forKey:@"channelIds"];
//            }
            
            
//            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM options:0 error:&err];
            str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [channel updateChannelWithName:channel.name isDistinct:NO coverUrl:@"" data:str_Dic customType:nil completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                
                NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
                //                             NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];
                
                SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                NSLog(@"%@", baseChannel.channelUrl);
                [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                
                KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
                vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]];    //2494
                vc.roomType = kBot;
                vc.str_ChannelUrl = baseChannel.channelUrl;
                vc.str_ChatBotThumUrl = coverUrl;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }];
    }
    else
    {
        //그룹방은 신규 방으로 개설
        //138,213,541
        NSMutableArray *arM_ChannelId = [NSMutableArray array];
        //        if( self.str_ChannelId && self.str_ChannelId.length > 0 )
        //        {
        //            [arM_ChannelId addObject:self.str_ChannelId];
        //        }
        
        [dicM setObject:arM_ChannelId forKey:@"channelIds"];
        
        NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
        

        
        
        
        
        
        
        
        
        
        if( coverUrl )
        {
            if( coverUrl == nil || coverUrl.length <= 0 )
            {
                coverUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"];
            }

            coverUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl];
        }

        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey:@"botUserId"]] forKey:@"botUserId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey:@"botOwnerId"]] forKey:@"botOwnerId"];

        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
        __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        
        [SBDGroupChannel createChannelWithName:strM_RoomName isDistinct:NO userIds:[strM_UserIds componentsSeparatedByString:@","] coverUrl:coverUrl data:str_Dic customType:@"chatBot"
                             completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                 
                                 if (error != nil)
                                 {
                                     NSLog(@"Error: %@", error);
                                     if( error.code == 400201 )
                                     {
                                         UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                         [window makeToast:@"가입된 회원이 아닙니다" withPosition:kPositionCenter];
                                     }
                                     return;
                                 }
                                 
                                 //채널질문방_{사용자가입력한질문방이름}_questionId
                                 NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
                                 //                             NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                                 //                                 NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];
                                 
                                 SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                 NSLog(@"%@", baseChannel.channelUrl);
                                 [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                 
                                 KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
                                 vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]];    //2494
                                 vc.roomType = kBot;
                                 vc.str_ChannelUrl = baseChannel.channelUrl;
                                 vc.str_ChatBotThumUrl = coverUrl;
                                 [self.navigationController pushViewController:vc animated:YES];
                             }];
    }
}


- (IBAction)goThumb:(id)sender
{
    [self.view endEditing:YES];
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"라이브러리", @"사진(카메라)"]
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = NO;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 //                 [self addSubview:imagePickerController.view];
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 1 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = NO;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
     }];
}


@end
