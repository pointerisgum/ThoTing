//
//  ProfileModifyViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 19..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

//프로필 이미지 업로드 api도 있네요 https://sites.google.com/site/thotingapi/api/api-jeong-ui/api-list/sayongjapeulopilimijieoblodeu

#import "ProfileModifyViewController.h"
#import "InputUserInfoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ProfileModifyViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (nonatomic, strong) UIImage *i_User;
@property (nonatomic, strong) NSString *str_UploadImageUrl;
@property (nonatomic, weak) IBOutlet UITextField *tf_Email;
@property (nonatomic, weak) IBOutlet UITextField *tf_Name;
@property (nonatomic, weak) IBOutlet UITextField *tf_Tag;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@end

@implementation ProfileModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)viewDidLayoutSubviews
{
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
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
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/profile"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                /*
                                                 userAffiliation = "\Uad00\Uc545\Uace0\Ub4f1\Ud559\Uad50";
                                                 userDesc = "<null>";
                                                 userHashTag = "#\Uad00\Uc545\Uace0\Ub4f1\Ud559\Uad50_2";
                                                 userMajor = 2;
                                                 userName = "\Uae40\Uc601\Ub355";
                                                 userPersonGrade = 2;
                                                 userSchoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
                                                 userSchoolId = 9489;
                                                 userSchoolName = "\Uad00\Uc545\Uace0\Ub4f1\Ud559\Uad50";
                                                 userThumgnail = "http://data.clipnote.co.kr:8282/c_edujm/images/user/000/000/noImage6.png";
                                                 */

                                                self.dic_Info = [NSDictionary dictionaryWithDictionary:resulte];
                                                
                                                NSString *str_Profile = [resulte objectForKey:@"userThumgnail"];
                                                if( self.i_User )
                                                {
                                                    self.iv_User.image = self.i_User;
                                                }
                                                else
                                                {
                                                    [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_Profile]];
                                                }
                                                self.tf_Email.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
                                                self.tf_Name.text = [resulte objectForKey:@"userName"];
                                                self.tf_Tag.text = [resulte objectForKey:@"userHashTag"];
                                            }
                                        }
                                    }];
}



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_Tag )
    {
        NSString *str_SchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
        if( [str_SchoolId integerValue] > 0 )
        {
            //학생인 경우
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            InputUserInfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InputUserInfoViewController"];
            vc.isProfileMode = YES;
            [self presentViewController:vc animated:NO completion:^{
                
            }];
        }
        else
        {
            //학생이 아닌 경우
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            InputUserInfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InputUserInfoViewController"];
            vc.isProfileMode = YES;
            vc.isNotStudent = YES;
            [self presentViewController:vc animated:NO completion:^{
                
            }];
        }
    }
    
    return YES;
}



#pragma mark - IBAction
- (IBAction)goProfile:(id)sender
{
    [self.view endEditing:YES];
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"라이브러리", @"사진 촬영"]
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
             imagePickerController.allowsEditing = YES;
             
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

#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.i_User = outputImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];

//    [self upLoadImage:outputImage];
    
//    UIImage *resizeImage = [Util imageWithImage:outputImage convertToWidth:self.view.bounds.size.width - 30];
    
//    [self.arM_List addObject:@{@"type":@"image", @"obj":UIImageJPEGRepresentation(resizeImage, 0.3), @"thumb":resizeImage}];
//    [self.tbv_List reloadData];
}

- (void)upLoadImage:(UIImage *)image
{
    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"user", @"type",
                                        nil];
    
    [[WebAPI sharedData] imageUpload:@"v1/upload/user/image/uploader"
                               param:dicM_Params
                          withImages:[NSDictionary dictionaryWithObject:UIImageJPEGRepresentation(image, 0.3f) forKey:@"file"]
                           withBlock:^(id resulte, NSError *error) {
                               
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                   if( nCode == 200 )
                                   {
                                       weakSelf.str_UploadImageUrl = [resulte objectForKey:@"ImageUrl"];
                                   }
                               }
                           }];
}

- (IBAction)goDone:(id)sender
{
    if( self.tf_Name.text.length <= 0 )
    {
        [self.navigationController.view makeToast:@"이름을 입력해 주세요" withPosition:kPositionCenter];
        return;
    }
    
    if( self.i_User )
    {
        __weak __typeof__(self) weakSelf = self;
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            @"user", @"type",
                                            nil];
        
        [[WebAPI sharedData] imageUpload:@"v1/upload/user/image/uploader"
                                   param:dicM_Params
                              withImages:[NSDictionary dictionaryWithObject:UIImageJPEGRepresentation(self.i_User, 0.3f) forKey:@"file"]
                               withBlock:^(id resulte, NSError *error) {
                                    
                                   if( resulte )
                                   {
                                       NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                       if( nCode == 200 )
                                       {
                                           weakSelf.str_UploadImageUrl = [resulte objectForKey:@"ImageUrl"];
                                           [self updateData];
                                           
                                           [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"ImageUrl"] forKey:@"userPic"];
                                           [[NSUserDefaults standardUserDefaults] synchronize];

                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"UserTabBarIconUpdate" object:nil];
                                       }
                                   }
                                   else
                                   {
                                       [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                   }
                               }];
    }
    else
    {
        [self updateData];
    }
}

- (void)updateData
{
    __weak __typeof__(self) weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.tf_Name.text, @"userName",
                                        [self.dic_Info objectForKey:@"userAffiliation"], @"userAffiliation",
                                        [self.dic_Info objectForKey:@"userDesc"], @"userDesc",
                                        self.str_UploadImageUrl ? self.str_UploadImageUrl : @"", @"imgUrl",
                                        //                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/change/my/profile"
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
                                                [SBDMain updateCurrentUserInfoWithNickname:[weakSelf.dic_Info objectForKey:@"userName"]
                                                                                profileUrl:[weakSelf.dic_Info objectForKey:@"userThumgnail"]
                                                                         completionHandler:^(SBDError * _Nullable error) {
                                                                             
                                                                         }];

                                                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                [window makeToast:@"프로필이 변경 되었습니다" withPosition:kPositionCenter];
                                                [weakSelf dismissViewControllerAnimated:YES completion:^{
                                                    
                                                }];
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

@end
