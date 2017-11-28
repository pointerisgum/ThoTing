//
//  KikGroupMakeViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 26..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikGroupMakeViewController.h"
#import "KikAddMemberAccCell.h"
#import "ChatIngUserCell.h"
#import "MWPhotoBrowser.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ChatFeedViewController.h"

@interface KikGroupMakeViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate, DZImageEditingControllerDelegate>
{
    NSString *str_UserImagePrefix;
    NSMutableString *strM_UserIds;
    NSMutableString *strM_RoomName;
}
@property (nonatomic, strong) NSMutableArray *arM_ListBackup;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_SelectUserList;
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
@property (nonatomic, weak) IBOutlet UICollectionView *cv_AddMember;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AddMemberHeight;

@property (nonatomic, weak) IBOutlet UITextField *tf_Tag;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ImageBgTop;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TopHeight;
@end

@implementation KikGroupMakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIImage *overlayImage = [UIImage imageNamed:@"kik_image_edith.png"];
    CGFloat newX = [UIScreen mainScreen].bounds.size.width / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat newY = [UIScreen mainScreen].bounds.size.height / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    self.frameRect = CGRectMake(newX, newY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self.overlayImageView = [[UIImageView alloc] initWithFrame:self.frameRect];
    self.overlayImageView.image = overlayImage;

    
    
    self.arM_SelectUserList = [NSMutableArray array];
    
    self.v_ThumbBg.layer.cornerRadius = self.v_ThumbBg.frame.size.width / 2;
    self.v_ThumbBg.layer.borderColor = kRoundColor.CGColor;
    self.v_ThumbBg.layer.borderWidth = 1.f;
    
    self.v_AddMemberBg.layer.cornerRadius = 4.f;
    self.v_AddMemberBg.layer.borderColor = kRoundColor.CGColor;
    self.v_AddMemberBg.layer.borderWidth = 1.f;

    if( self.isGroupsMode )
    {
        //태그 모드
        self.lc_ImageBgTop.constant = 34.f;
        self.lc_TopHeight.constant = 163.f;
    }
    else
    {
        self.lc_ImageBgTop.constant = 10.f;
        self.lc_TopHeight.constant = 123.f;
    }
    
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
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exist/chat/room/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                str_UserImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
                                                weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                weakSelf.arM_ListBackup = weakSelf.arM_List;
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
 
- (void)updateAddMemberList
{
    if( self.arM_SelectUserList == nil || self.arM_SelectUserList.count <= 0 )
    {
        self.lc_AddMemberHeight.constant = 0.f;
        self.btn_Start.selected = NO;
    }
    else
    {
        self.lc_AddMemberHeight.constant = 36.f;
        self.btn_Start.selected = YES;
    }
    
    __weak __typeof(&*self)weakSelf = self;

    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];

    [self.tbv_List reloadData];
    [self.cv_AddMember reloadData];
}

- (void)searchMemberName
{
    if( self.tf_AddMember.text.length > 0 )
    {
        NSArray *ar = [self.arM_ListBackup filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.userName contains[c] %@", self.tf_AddMember.text]];
        self.arM_List = [NSMutableArray arrayWithArray:ar];
    }
    else{
        self.arM_List = self.arM_ListBackup;
    }
    
    [self.tbv_List reloadData];
}

- (void)changeInPutTag:(NSString *)aString
{
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
    
    NSArray *ar = [self.tf_Tag.text componentsSeparatedByString:@" "];
    if( ar.count > 3 )
    {
        ALERT_ONE(@"태그는 3개까지 등록 가능합니다");
//        [ALToastView toastKeyboardTop:self.view withText:@"태그는 3개까지 등록 가능합니다"];
        NSMutableString *strM = [NSMutableString string];
        for( NSInteger i = 0; i < 3; i++ )
        {
            [strM appendString:ar[i]];
            [strM appendString:@" "];
        }
        
        if( [strM hasSuffix:@" "] )
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
        [strM appendString:@" "];
    }
    
    if( [strM hasSuffix:@" "] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }

    self.tf_Tag.text = strM;
}


#pragma mark - UITextFiledDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_Tag )
    {
        if( textField.text.length <= 0 )
        {
            self.tf_Tag.text = @"#";
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( textField == self.tf_AddMember )
    {
        [self performSelector:@selector(searchMemberName) withObject:nil afterDelay:0.1f];
    }
    else if( textField == self.tf_Tag )
    {
        [self performSelector:@selector(changeInPutTag:) withObject:string afterDelay:0.1f];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    if( textField == self.tf_AddMember ){
        self.arM_List = self.arM_ListBackup;
        [self.tbv_List reloadData];
    }
    
    return YES;
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
    /*
     rId = 180;
     userAffiliation = "\Uacbd\Ubb38\Uace0\Ub4f1\Ud559\Uad50";
     userId = 99;
     userMajor = 1;
     userName = "\Ud669\Ud76c\Ucc2c";
     userThumbnail = "000/000/noImage12.png";
     userType = user;
     */
    
    NSDictionary *dic = self.arM_List[indexPath.row];

    ChatIngUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIngUserCell"];
    
    cell.btn_Check.selected = NO;
    
    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"userThumbnail"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
    
    cell.lb_Name.text = [dic objectForKey_YM:@"userName"];
    cell.lb_NinkName.text = [dic objectForKey_YM:@"userEmail"];

    NSArray *ar = [self.arM_SelectUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", [dic objectForKey_YM:@"userId"]]];
    if( ar.count > 0 )
    {
        cell.btn_Check.selected = YES;
    }
    

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    NSArray *ar = [self.arM_SelectUserList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %@", [dic objectForKey_YM:@"userId"]]];
    if( ar.count > 0 )
    {
        //이미 선택된건 삭제
        [self.arM_SelectUserList removeObject:dic];
    }
    else
    {
        //선택되지 않았던것은 추가
        [self.arM_SelectUserList addObject:dic];
    }
    
    [self updateAddMemberList];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40.f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    static NSString *CellIdentifier = @"Header";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    return cell;
//}


#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arM_SelectUserList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"KikAddMemberAccCell";
    
    KikAddMemberAccCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dic = self.arM_SelectUserList[indexPath.row];

    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"userThumbnail"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_SelectUserList[indexPath.row];
    [self.arM_SelectUserList removeObject:dic];
    [self.cv_AddMember reloadData];
    [self updateAddMemberList];
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

    if( self.isGroupsMode )
    {
        if( self.tf_GroupName.text.length <= 0 )
        {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@""
                                                 message:@"그룹 이름을 입력해 주세요"
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
        
        if( self.iv_Thumb.image.size.width < 150 || self.iv_Thumb.image.size.height < 150 )
        {
            [UIAlertController showAlertInViewController:self
                                               withTitle:@""
                                                 message:@"이미지 사이즈는 가로 세로 150이상 등록 가능합니다"
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
                                   
                                   [weakSelf makePublicGroup:str_UploadImageUrl];
                               }];
    }
    else
    {
        if( self.tf_GroupName.text.length > 0 )
        {
            if( self.iv_Thumb.image == nil )
            {
                //그룹 이름을 입력 했는데 이미지를 입력하지 않았을때
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
            else
            {
                if( self.iv_Thumb.image.size.width < 150 || self.iv_Thumb.image.size.height < 150 )
                {
                    [UIAlertController showAlertInViewController:self
                                                       withTitle:@""
                                                         message:@"이미지 사이즈는 가로 세로 150이상 등록 가능합니다"
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
                }
            }
        }
        
        if( self.iv_Thumb.image )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                @"user", @"type",
                                                nil];
            
            [[WebAPI sharedData] imageUpload:@"v1/upload/user/image/uploader"
                                       param:dicM_Params
                                  withImages:[NSDictionary dictionaryWithObject:UIImageJPEGRepresentation(self.iv_Thumb.image, 0.1f) forKey:@"file"]
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
                                       
                                       [weakSelf makeGroupChat:str_UploadImageUrl];
                                   }];
        }
        else
        {
            [self makeGroupChat:nil];
        }
    }
}

- (void)makeGroupChat:(NSString *)coverUrl
{
    __weak __typeof(&*self)weakSelf = self;

    self.btn_Start.userInteractionEnabled = NO;

    strM_UserIds = [NSMutableString string];
    for( NSInteger i = 0; i < self.arM_SelectUserList.count; i++ )
    {
        NSDictionary *dic = self.arM_SelectUserList[i];
        [strM_UserIds appendString:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]]];
        [strM_UserIds appendString:@","];
    }
    
    if( [strM_UserIds hasSuffix:@","] )
    {
        [strM_UserIds deleteCharactersInRange:NSMakeRange([strM_UserIds length]-1, 1)];
    }

    /////////////////////////
    NSMutableArray *arM_UserList = [NSMutableArray array];
    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_MyInfo];
    
    //유저 이름 가져오기
    NSArray *ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
    for( NSInteger i = 0; i < ar_UserIds.count; i++ )
    {
        NSString *str_UserId = [ar_UserIds objectAtIndex:i];
        for( NSInteger j = 0; j < self.arM_SelectUserList.count; j++ )
        {
            NSDictionary *dic_Tmp = [self.arM_SelectUserList objectAtIndex:j];
            if( [str_UserId integerValue] == [[dic_Tmp objectForKey:@"userId"] integerValue] )
            {
                NSString *str_UserName = [dic_Tmp objectForKey_YM:@"userName"];
                NSString *str_UserThumb = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
                
                NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                [dicM_MyInfo setObject:str_UserId forKey:@"userId"];
                [dicM_MyInfo setObject:str_UserName forKey:@"userName"];
                [dicM_MyInfo setObject:str_UserThumb forKey:@"imgUrl"];
                [arM_UserList addObject:dicM_MyInfo];
                
                break;
            }
        }
    }

    ///////////////////////////////////
    
    strM_RoomName = [NSMutableString string];
    if( self.tf_GroupName.text.length > 0 )
    {
        [strM_RoomName appendString:self.tf_GroupName.text];
    }
    else
    {
        for( NSInteger i = 0; i < arM_UserList.count; i++ )
        {
            NSDictionary *dic = arM_UserList[i];
            NSString *str_UserName = [dic objectForKey_YM:@"userName"];
            [strM_RoomName appendString:str_UserName];
            [strM_RoomName appendString:@", "];
        }
        
        if( [strM_RoomName hasSuffix:@", "] )
        {
            [strM_RoomName deleteCharactersInRange:NSMakeRange([strM_RoomName length]-1, 1)];
        }
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        strM_RoomName, @"roomName",
                                        strM_UserIds, @"inviteUserIdStr",
                                        @"group", @"channelType",
                                        [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl], @"roomCoverImg",
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
                                                NSDictionary *dic = [resulte objectForKey:@"qnaRoomInfo"];
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                [weakSelf makeSendbird:dic withCover:coverUrl];
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        weakSelf.btn_Start.userInteractionEnabled = YES;
                                    }];

}

- (void)makeSendbird:(NSDictionary *)dic withCover:(NSString *)coverUrl
{
    NSString *str_SBDChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];

    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    if( self.iv_Thumb.image )
    {
        //20170926 새로 추가한 부분
        //그룹방 개설시 이미지가 있으면 이미지를 샌드버드로 전송
        [dicM setObject:coverUrl forKey:@"roomCoverUrl"];
    }
    
//    NSMutableString *strM_RoomName = [NSMutableString string];
//    if( self.tf_GroupName.text.length > 0 )
//    {
//        [strM_RoomName appendString:self.tf_GroupName.text];
//    }
//    else
//    {
//        for( NSInteger i = 0; i < arM_UserList.count; i++ )
//        {
//            NSDictionary *dic = arM_UserList[i];
//            NSString *str_UserName = [dic objectForKey_YM:@"userName"];
//            [strM_RoomName appendString:str_UserName];
//            [strM_RoomName appendString:@", "];
//        }
//
//        if( [strM_RoomName hasSuffix:@", "] )
//        {
//            [strM_RoomName deleteCharactersInRange:NSMakeRange([strM_RoomName length]-1, 1)];
//        }
//    }
//
//    [dicM setObject:strM_RoomName forKey:@"roomName"];

    
    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
    __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if( str_SBDChannelUrl && str_SBDChannelUrl.length > 0 )
    {
        [SBDGroupChannel getChannelWithUrl:str_SBDChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            
            BOOL isHave = NO;
            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
            id tmp = [dic objectForKey_YM:@"channelIds"];
            NSMutableArray *arM_ChannelIds;
            if( [tmp isKindOfClass:[NSArray class]] == NO )
            {
                arM_ChannelIds = [NSMutableArray array];
            }
            else
            {
                arM_ChannelIds = [NSMutableArray arrayWithArray:[dic objectForKey:@"channelIds"]];
            }
            
////            for( NSInteger i = 0; i < arM_ChannelIds.count; i++ )
////            {
////                NSString *str_CurrentChannelId = arM_ChannelIds[i];
////                if( [str_CurrentChannelId isEqualToString:self.str_ChannelId] )
////                {
////                    isHave = YES;
////                    break;
////                }
////            }
//
//            if( isHave == NO && self.str_ChannelId && self.str_ChannelId.length > 0 )
//            {
//                [arM_ChannelIds addObject:self.str_ChannelId];
//            }
            
            if( arM_ChannelIds == nil )
            {
                [dicM setObject:[NSArray array] forKey:@"channelIds"];
            }
            else
            {
                [dicM setObject:arM_ChannelIds forKey:@"channelIds"];
            }
            
            
            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
            str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            
            [channel updateChannelWithName:channel.name isDistinct:NO coverUrl:@"" data:str_Dic customType:nil completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                
                NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
                //                             NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];
                
                SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                NSLog(@"%@", baseChannel.channelUrl);
                [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                vc.str_RId = str_RId;
                vc.dic_Info = dic;
                vc.str_RoomTitle = strM_RoomName;
                vc.ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
                vc.channel = channel;
                vc.str_ChannelIdTmp = nil;
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
        
        
        
        
        
        
        
        
        
        
        
        NSString *str_CustomType = @"";
        if( coverUrl )
        {
            str_CustomType = @"channel";
            coverUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl];
        }
        else
        {
            str_CustomType = @"group";
        }
        
        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
        [dicM_Data setObject:@"" forKey:@"botUserId"];
        [dicM_Data setObject:@"" forKey:@"botOwnerId"];

        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
        __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //이름과 섬네일이 없는 그룹방
        
        if( [strM_RoomName hasSuffix:@","] )
        {
            [strM_RoomName deleteCharactersInRange:NSMakeRange([strM_RoomName length]-1, 1)];
        }

        if( coverUrl == nil )
        {
            coverUrl = @"";
        }
        
        [SBDGroupChannel createChannelWithName:strM_RoomName isDistinct:NO userIds:[strM_UserIds componentsSeparatedByString:@","] coverUrl:coverUrl data:str_Dic customType:str_CustomType
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
                                 
                                 UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                 ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                 vc.str_RId = str_RId;
                                 vc.dic_Info = dic;
                                 vc.str_RoomTitle = strM_RoomName;
                                 vc.ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
                                 vc.channel = channel;
                                 vc.str_ChannelIdTmp = nil;
                                 [self.navigationController pushViewController:vc animated:YES];
                             }];
    }
}

- (void)makePublicGroup:(NSString *)coverUrl
{
    __weak __typeof(&*self)weakSelf = self;
    
    self.btn_Start.userInteractionEnabled = NO;
    
    strM_UserIds = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]];
    [strM_UserIds appendString:@","];
    for( NSInteger i = 0; i < self.arM_SelectUserList.count; i++ )
    {
        NSDictionary *dic = self.arM_SelectUserList[i];
        [strM_UserIds appendString:[NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]]];
        [strM_UserIds appendString:@","];
    }
    
    if( [strM_UserIds hasSuffix:@","] )
    {
        [strM_UserIds deleteCharactersInRange:NSMakeRange([strM_UserIds length]-1, 1)];
    }
    
    /////////////////////////
    NSMutableArray *arM_UserList = [NSMutableArray array];
    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_MyInfo];
    
    //유저 이름 가져오기
    NSArray *ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
    for( NSInteger i = 0; i < ar_UserIds.count; i++ )
    {
        NSString *str_UserId = [ar_UserIds objectAtIndex:i];
        for( NSInteger j = 0; j < self.arM_SelectUserList.count; j++ )
        {
            NSDictionary *dic_Tmp = [self.arM_SelectUserList objectAtIndex:j];
            if( [str_UserId integerValue] == [[dic_Tmp objectForKey:@"userId"] integerValue] )
            {
                NSString *str_UserName = [dic_Tmp objectForKey_YM:@"userName"];
                NSString *str_UserThumb = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic_Tmp objectForKey_YM:@"userThumbnail"]];
                
                NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
                [dicM_MyInfo setObject:str_UserId forKey:@"userId"];
                [dicM_MyInfo setObject:str_UserName forKey:@"userName"];
                [dicM_MyInfo setObject:str_UserThumb forKey:@"imgUrl"];
                [arM_UserList addObject:dicM_MyInfo];
                
                break;
            }
        }
    }
    
    ///////////////////////////////////
    
    strM_RoomName = [NSMutableString stringWithString:self.tf_GroupName.text];
    
//    NSString *str_Tag = [self.tf_Tag.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    NSString* str_Tag = [self.tf_Tag.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;

    if( [self.tf_Tag.text hasSuffix:@"#"] )
    {
        NSMutableString *strM = [NSMutableString stringWithString:self.tf_Tag.text];
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
        self.tf_Tag.text = strM;
    }
    
    if( [self.tf_Tag.text hasSuffix:@"# "] )
    {
        NSMutableString *strM = [NSMutableString stringWithString:self.tf_Tag.text];
        [strM deleteCharactersInRange:NSMakeRange([strM length]-2, 2)];
        self.tf_Tag.text = strM;
    }

    if( [self.tf_Tag.text hasSuffix:@" "] )
    {
        NSMutableString *strM = [NSMutableString stringWithString:self.tf_Tag.text];
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
        self.tf_Tag.text = strM;
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        strM_RoomName, @"roomName",
                                        strM_UserIds, @"inviteUserIdStr",
                                        [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl], @"roomCoverImg",
                                        self.tf_Tag.text, @"hashTagStr",
                                        @"opengroup", @"channelType",
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
                                                NSDictionary *dic = [resulte objectForKey:@"qnaRoomInfo"];
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                [dicM setObject:arM_UserList forKey:@"userThumbnail"];
                                                [weakSelf makePublicSendbird:dic withCover:coverUrl];
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
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

    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
    __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if( str_SBDChannelUrl && str_SBDChannelUrl.length > 0 )
    {
        [SBDGroupChannel getChannelWithUrl:str_SBDChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {

            BOOL isHave = NO;
            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
            id tmp = [dic objectForKey_YM:@"channelIds"];
            NSMutableArray *arM_ChannelIds;
            if( [tmp isKindOfClass:[NSArray class]] == NO )
            {
                arM_ChannelIds = [NSMutableArray array];
            }
            else
            {
                arM_ChannelIds = [NSMutableArray arrayWithArray:[dic objectForKey:@"channelIds"]];
            }

            if( arM_ChannelIds == nil )
            {
                [dicM setObject:[NSArray array] forKey:@"channelIds"];
            }
            else
            {
                [dicM setObject:arM_ChannelIds forKey:@"channelIds"];
            }
            
            
            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
            str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [channel updateChannelWithName:channel.name isDistinct:NO coverUrl:@"" data:str_Dic customType:nil completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {

                NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
                //                             NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
                NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", self.tf_GroupName.text, str_RId];

                SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                NSLog(@"%@", baseChannel.channelUrl);
                [Util addOpenChannelUrl:baseChannel.channelUrl withRId:str_RId];

                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                vc.str_RId = str_RId;
                vc.dic_Info = dic;
                vc.str_RoomTitle = strM_RoomName;
                vc.ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
                vc.channel = channel;
                vc.str_ChannelIdTmp = nil;
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
            coverUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, coverUrl];
        }
        
        NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"rId"]] forKey:@"rId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"questionId"]] forKey:@"questionId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"channelId"]] forKey:@"channelId"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"hashTagStr"]] forKey:@"hashTagStr"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomDesc"]] forKey:@"roomDesc"];
        [dicM_Data setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"ownerId"];
        [dicM_Data setObject:@"" forKey:@"botUserId"];
        [dicM_Data setObject:@"" forKey:@"botOwnerId"];

        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data options:0 error:&err];
        __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [SBDGroupChannel createChannelWithName:strM_RoomName isDistinct:NO userIds:[strM_UserIds componentsSeparatedByString:@","] coverUrl:coverUrl data:str_Dic customType:@"opengroup"
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
            [Util addOpenChannelUrl:baseChannel.channelUrl withRId:str_RId];

            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
            ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
            vc.str_RId = str_RId;
            vc.dic_Info = dic;
            vc.str_RoomTitle = strM_RoomName;
            vc.ar_UserIds = [strM_UserIds componentsSeparatedByString:@","];
            vc.channel = channel;
            vc.str_ChannelIdTmp = nil;
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

- (IBAction)goBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
