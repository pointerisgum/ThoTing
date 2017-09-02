//
//  InputChannelInfoViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 8. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "InputChannelInfoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface InputChannelInfoViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSString *str_ImageUrl;
@property (nonatomic, weak) IBOutlet UITextField *tf_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_Picture;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Thumb;
@property (nonatomic, weak) IBOutlet UIButton *btn_Done;
@end

@implementation InputChannelInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tf_Title.delegate = self;
    self.btn_Done.userInteractionEnabled = NO;
    
    self.btn_Picture.layer.cornerRadius = 4.f;
    
    [self.tf_Title becomeFirstResponder];
    
    self.str_ImageUrl = @"";
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


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(onTextFiledUpdateInterval:) withObject:textField afterDelay:0.1f];
    
    return YES;
}

- (void)onTextFiledUpdateInterval:(UITextField *)tf
{
    if( self.tf_Title.text.length > 0 )
    {
        self.btn_Done.userInteractionEnabled = YES;
        [self.btn_Done setTitleColor:[UIColor colorWithHexString:@"39D37C"] forState:UIControlStateNormal];
    }
    else
    {
        self.btn_Done.userInteractionEnabled = NO;
        [self.btn_Done setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (IBAction)goPicture:(id)sender
{
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
    
    self.iv_Thumb.image = outputImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self imageUpload];
}

- (void)imageUpload
{
    if( self.iv_Thumb.image == nil ) return;

    __weak __typeof__(self) weakSelf = self;

    self.btn_Done.userInteractionEnabled = NO;
    
    NSData *imagedata = UIImagePNGRepresentation(self.iv_Thumb.image);

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"channel", @"type",
                                        nil];
    
    [[WebAPI sharedData] imageUpload:@"v1/upload/channel/image/uploader"
                               param:dicM_Params
                          withImages:[NSDictionary dictionaryWithObject:imagedata forKey:@"file"]
                           withBlock:^(id resulte, NSError *error) {
                               
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                   if( nCode == 200 )
                                   {
                                       weakSelf.str_ImageUrl = [resulte objectForKey_YM:@"serviceUrl"];
                                   }
                               }
                               
                               weakSelf.btn_Done.userInteractionEnabled = YES;
                           }];
}


- (IBAction)goDone:(id)sender
{
    if( self.tf_Title.text.length <= 0 )
    {
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.tf_Title.text, @"channelName",
                                        @"", @"channelDesc",
                                        self.str_ImageUrl, @"channelImgUrl",
                                        @"manager", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/create/my/channel"
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
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateNewChannel"
                                                                                                    object:[NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"channelId"]]];

                                                [weakSelf dismissViewControllerAnimated:YES completion:^{
                                                    
                                                }];
                                            }
                                        }
                                    }];
}

@end


