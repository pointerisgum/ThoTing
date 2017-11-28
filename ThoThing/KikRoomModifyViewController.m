//
//  KikRoomModifyViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 24..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikRoomModifyViewController.h"
#import "MWPhotoBrowser.h"
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface KikRoomModifyViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZImageEditingControllerDelegate>
{
    BOOL isOpenGroup;
}
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, assign) CGRect frameRect;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UITextField *tf_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_Save;
@property (nonatomic, weak) IBOutlet UIView *v_Tag;
@property (nonatomic, weak) IBOutlet UITextField *tf_Tag;
@end

@implementation KikRoomModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIImage *overlayImage = [UIImage imageNamed:@"kik_image_edith.png"];
    CGFloat newX = [UIScreen mainScreen].bounds.size.width / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat newY = [UIScreen mainScreen].bounds.size.height / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    self.frameRect = CGRectMake(newX, newY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self.overlayImageView = [[UIImageView alloc] initWithFrame:self.frameRect];
    self.overlayImageView.image = overlayImage;

    isOpenGroup = [self.channel.customType isEqualToString:@"opengroup"];
    if( isOpenGroup )
    {
        //오픈그룹이면 태그 수정하는곳도 추가
        self.tf_Tag.hidden = NO;
        [self setHashTag];
    }
    else
    {
        self.tf_Tag.hidden = YES;
    }
    
    self.iv_Thumb.layer.cornerRadius = self.iv_Thumb.frame.size.width / 2;
    self.iv_Thumb.layer.borderWidth = 1.f;
    self.iv_Thumb.layer.borderColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1].CGColor;
    
    self.btn_Save.selected = YES;
    if( self.channel.coverUrl.length > 0 )
    {
        [self.iv_Thumb sd_setImageWithURL:[NSURL URLWithString:self.channel.coverUrl]];
    }
    else
    {
        self.iv_Thumb.backgroundColor = [UIColor clearColor];
    }
    
    self.tf_Title.text = self.channel.name;
    
    [self.tf_Title becomeFirstResponder];
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



- (void)setHashTag
{
    __weak __typeof(&*self)weakSelf = self;
    
    NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[dic_Data objectForKey:@"rId"] integerValue]], @"rId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/chat/room/header/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSString *str_Tag = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"hashTagStr"]];
                                                weakSelf.tf_Tag.text = str_Tag;
                                            }
                                        }
                                    }];
}



#pragma amrk - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(textChange:) withObject:@{@"obj":textField, @"string":string} afterDelay:0.1f];

    return YES;
}

- (void)textChange:(NSDictionary *)dic
{
    UITextField *tf = [dic objectForKey:@"obj"];
    NSString *aString = [dic objectForKey:@"string"];
    
    if( tf == self.tf_Title )
    {
        if( self.tf_Title.text.length <= 0 )
        {
            self.btn_Save.selected = NO;
        }
        else
        {
            self.btn_Save.selected = YES;
        }
    }
    else if( tf == self.tf_Tag && isOpenGroup )
    {
        if( self.tf_Title.text.length <= 0 || self.tf_Tag.text.length <= 0 )
        {
            self.btn_Save.selected = NO;
        }
        else
        {
            self.btn_Save.selected = YES;
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
    self.iv_Thumb.backgroundColor = [UIColor whiteColor];
    
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
- (IBAction)goChooseImage:(id)sender
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

- (IBAction)goSave:(id)sender
{
    __weak __typeof__(self) weakSelf = self;

    if( self.btn_Save.selected == NO )   return;
    
    if( self.tf_Title.text.length <= 0 )
    {
        [Util showToast:@"제목을 입력해 주세요"];
        return;
    }

    if( isOpenGroup )
    {
        if( self.tf_Tag.text.length <= 0 )
        {
            [Util showToast:@"태그를 입력해 주세요"];
            return;
        }
        
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
    }
    

    if( self.iv_Thumb )
    {
        self.btn_Save.userInteractionEnabled = NO;
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            @"user", @"type",
                                            nil];
        
        [[WebAPI sharedData] imageUpload:@"v1/upload/user/image/uploader"
                                   param:dicM_Params
                              withImages:[NSDictionary dictionaryWithObject:UIImageJPEGRepresentation(self.iv_Thumb.image, 0.3f) forKey:@"file"]
                               withBlock:^(id resulte, NSError *error) {
                                   
                                   if( resulte )
                                   {
                                       NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                       if( nCode == 200 )
                                       {
                                           NSString *str_UserImagePrefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImg_prefix"];

                                           NSString *str_UploadImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [resulte objectForKey:@"ImageUrl"]];
                                           
                                           if( isOpenGroup )
                                           {
                                               [weakSelf updateRoomInfo:str_UploadImageUrl];
                                           }
                                           else
                                           {
                                               [weakSelf.channel updateChannelWithName:self.tf_Title.text coverUrl:str_UploadImageUrl data:self.channel.data completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                                   
                                                   [Util showToast:@"수정 되었습니다"];
                                                   [weakSelf.navigationController popViewControllerAnimated:YES];
                                               }];
                                           }
                                       }
                                   }
                                   
                                   weakSelf.btn_Save.userInteractionEnabled = YES;
                               }];
    }
    else
    {
        [weakSelf.channel updateChannelWithName:self.tf_Title.text coverUrl:self.channel.coverUrl data:self.channel.data completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            
            [Util showToast:@"수정 되었습니다"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)updateRoomInfo:(NSString *)aCoverUrl
{
    __weak __typeof__(self) weakSelf = self;

    NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.tf_Title.text, @"roomName",
                                        [NSString stringWithFormat:@"%ld", [[dic_Data objectForKey:@"rId"] integerValue]], @"rId",
//                                        @"", @"roomDesc",
                                        aCoverUrl, @"roomCoverUrl",
                                        self.tf_Tag.text, @"hashTagStr",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/update/group/chat/info"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {

                                        }
                                        
                                        [weakSelf.channel updateChannelWithName:self.tf_Title.text coverUrl:aCoverUrl data:self.channel.data completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                            
                                            [Util showToast:@"수정 되었습니다"];
                                            [weakSelf.navigationController popViewControllerAnimated:YES];
                                        }];
                                    }];
}

@end
