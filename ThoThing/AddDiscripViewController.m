//
//  AddDiscripViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "AddDiscripViewController.h"
#import "CommentKeyboardAccView.h"
#import "AddDiscriptionTextCell.h"
#import "AddDiscriptionContentsCell.h"
#import "MWPhotoBrowser.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

static NSInteger snUploadCnt = 0;

@interface AddDiscripViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate>
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) AddDiscriptionTextCell *v_AddDiscriptionTextCell;
@property (nonatomic, strong) AddDiscriptionContentsCell *v_AddDiscriptionContentsCell;
@property (nonatomic, weak) IBOutlet CommentKeyboardAccView *v_CommentKeyboardAccView;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_Done;
@end
 
@implementation AddDiscripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.isQuestionMode )
    {
        if( self.str_QnAId == nil )
        {
            self.lb_Title.text = @"질문하기";
            self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"질문하기..";
        }
        else
        {
            self.lb_Title.text = @"답글쓰기";
            self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"답글쓰기..";
        }
    }
    else
    {
        self.lb_Title.text = @"문제풀이";
        self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"문제풀이 추가..";
    }
    
    self.arM_List = [NSMutableArray array];
    
    [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
    
    self.v_AddDiscriptionTextCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([AddDiscriptionTextCell class])];
    self.v_AddDiscriptionContentsCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([AddDiscriptionContentsCell class])];
    
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

- (void)viewDidLayoutSubviews
{

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


#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            self.v_CommentKeyboardAccView.lc_Bottom.constant = keyboardBounds.size.height;
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
        }
    }completion:^(BOOL finished) {
        
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    NSString *str_Type = [dic objectForKey:@"type"];
    if( [str_Type isEqualToString:@"text"] )
    {
        AddDiscriptionTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddDiscriptionTextCell"];
        [self configureTextCell:cell forRowAtIndexPath:indexPath];

        return cell;
    }
    
    AddDiscriptionContentsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddDiscriptionContentsCell"];
    [self configureContentsCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_List[indexPath.row];
    NSString *str_Type = [dic objectForKey:@"type"];
    if( [str_Type isEqualToString:@"text"] )
    {
        [self configureTextCell:self.v_AddDiscriptionTextCell forRowAtIndexPath:indexPath];
        [self.v_AddDiscriptionTextCell updateConstraintsIfNeeded];
        [self.v_AddDiscriptionTextCell layoutIfNeeded];
        
        self.v_AddDiscriptionTextCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.v_AddDiscriptionTextCell.bounds));
        
        return [self.v_AddDiscriptionTextCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    else
    {
        UIImage *image = [dic objectForKey:@"thumb"];
        return image.size.height + 16;
    }
    
    return 0;
}

- (void)configureTextCell:(AddDiscriptionTextCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_List[indexPath.row];
    cell.lb_Text.text = [dic objectForKey:@"obj"];
}

- (void)configureContentsCell:(AddDiscriptionContentsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_List[indexPath.row];
    UIImage *image = [dic objectForKey:@"thumb"];
    
    CGRect frame = cell.iv_Contents.frame;
    frame.size.height = image.size.height;
    cell.iv_Contents.frame = frame;
    
    cell.iv_Contents.image = image;
    
    if( [[dic objectForKey:@"type"] isEqualToString:@"video"] )
    {
        cell.iv_Play.hidden = NO;
    }
    else
    {
        cell.iv_Play.hidden = YES;
    }
}



- (IBAction)goSend:(id)sender
{
    if( self.v_CommentKeyboardAccView.tv_Contents.text.length > 0 )
    {
        [self.arM_List addObject:@{@"type":@"text", @"obj":self.v_CommentKeyboardAccView.tv_Contents.text}];
        [self.tbv_List reloadData];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.tbv_List scrollRectToVisible:CGRectMake(self.tbv_List.contentSize.width - 1, self.tbv_List.contentSize.height - 1, 1, 1) animated:YES];
        }];
        
        [self.v_CommentKeyboardAccView removeContents];
    }
}

- (IBAction)goAddContents:(id)sender
{
    [self.view endEditing:YES];
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"라이브러리", @"사진(카메라)", @"동영상(카메라)"]
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, kUTTypeImage, nil];
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
         else if( buttonIndex == 2 )
         {
             UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
             imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
             imagePickerController.delegate = self;

//             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//             imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
//             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
////             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
//             imagePickerController.delegate = self;
//             imagePickerController.allowsEditing = YES;
             
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
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];

        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 1);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];

        UIImage *resizeImage = [Util imageWithImage:thumb convertToWidth:self.view.bounds.size.width - 30];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        [self.arM_List addObject:@{@"type":@"video", @"obj":videoData, @"thumb":resizeImage}];
        [self.tbv_List reloadData];
    }
    else
    {
        UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIImage *resizeImage = [Util imageWithImage:outputImage convertToWidth:self.view.bounds.size.width - 30];
        
        [self.arM_List addObject:@{@"type":@"image", @"obj":UIImageJPEGRepresentation(resizeImage, 0.3f), @"thumb":resizeImage}];
        [self.tbv_List reloadData];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.tbv_List scrollRectToVisible:CGRectMake(self.tbv_List.contentSize.width - 1, self.tbv_List.contentSize.height - 1, 1, 1) animated:YES];
    }];
}

- (IBAction)goDone:(id)sender
{
    if( self.arM_List == nil || self.arM_List.count <= 0 )
    {
        return;
    }
    
    self.btn_Done.userInteractionEnabled = NO;
    
    BOOL isOnlyText = YES;
    
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        NSDictionary *dic = self.arM_List[i];
        if( [[dic objectForKey:@"type"] isEqualToString:@"text"] == NO )
        {
            isOnlyText = NO;
            
            [self uploadData:i];
        }
    }
    
    if( isOnlyText )
    {
        [self upLoadContents];
    }
}

- (void)uploadData:(NSInteger)nIdx
{
    __weak __typeof__(self) weakSelf = self;

    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[nIdx]];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_Idx, @"questionId",
                                        self.isQuestionMode ? @"reply" : @"explain", @"uploadItem",
                                        [dicM objectForKey:@"type"], @"type",
                                        nil];
    
    [[WebAPI sharedData] imageUpload:@"v1/attach/file/uploader"
                               param:dicM_Params
                          withImages:[NSDictionary dictionaryWithObject:[dicM objectForKey:@"obj"] forKey:@"file"]
                           withBlock:^(id resulte, NSError *error) {
                               
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                   if( nCode == 200 )
                                   {
                                       /*
                                        "error_code" = success;
                                        "error_message" = success;
                                        fileName = "/usr/local/tomcat-NEW-THOTING-JM-MOBILE-DEMO/webapps/c_edujm/temp/108";
                                        filePath = "/usr/local/tomcat-NEW-THOTING-JM-MOBILE-DEMO/webapps/c_edujm/temp/108/ed08d72c8d583c859e2555e98dea2332.jpg";
                                        "response_code" = 200;
                                        serviceUrl = "/c_edujm/temp/108/ed08d72c8d583c859e2555e98dea2332.jpg";
                                        success = success;
                                        tempUploadId = 38;
                                        */
                                       
                                       [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
                                       [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
                                       [weakSelf.arM_List replaceObjectAtIndex:nIdx withObject:dicM];
                                       
                                       snUploadCnt++;
                                       
                                       NSInteger nContentsCnt = 0;
                                       
                                       for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                       {
                                           NSDictionary *dic = self.arM_List[i];
                                           if( [[dic objectForKey:@"type"] isEqualToString:@"text"] == NO )
                                           {
                                               nContentsCnt++;
                                           }
                                       }
                                       
                                       if( snUploadCnt == nContentsCnt )
                                       {
                                           //최종 데이터 전송
                                           snUploadCnt = 0;
                                           [self upLoadContents];
                                       }
                                   }
                                   else
                                   {
                                       [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                       self.btn_Done.userInteractionEnabled = YES;
                                   }
                               }
                               else
                               {
                                   [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                               }
                           }];
}

- (void)upLoadContents
{
    NSMutableString *strM = [NSMutableString string];
    for( NSInteger i = 0; i < self.arM_List.count; i++ )
    {
        NSDictionary *dic = self.arM_List[i];

        if( [[dic objectForKey:@"type"] isEqualToString:@"text"] )
        {
            [strM appendString:@"0"];
            [strM appendString:@"-"];
            
            [strM appendString:[dic objectForKey:@"type"]];
            [strM appendString:@"-"];
            
            [strM appendString:@"0"];
            [strM appendString:@"-"];
            
            [strM appendString:@"N"];
            [strM appendString:@"-"];
            
//            [strM appendString:[dic objectForKey:@"obj"]];

            NSString *str_Tmp = [dic objectForKey:@"obj"];
            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

            //[]{}#%^*+=_/
            [strM appendString:str_Tmp];

//            NSString *str_Text = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            if( str_Text == nil )
//            {
//                [strM appendString:str_Tmp];
//            }
//            else
//            {
//                [strM appendString:str_Text];
//            }
        }
        else
        {
            [strM appendString:@"0"];
            [strM appendString:@"-"];
            
            [strM appendString:[dic objectForKey:@"type"]];
            [strM appendString:@"-"];
            
            [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tempUploadId"]]];
            [strM appendString:@"-"];
            
            [strM appendString:@"N"];
            [strM appendString:@"-"];
            
            [strM appendString:[dic objectForKey:@"serviceUrl"]];
        }
        
        [strM appendString:@","];
    }
    
    if( [strM hasSuffix:@","] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }

    //stringByAddingPercentEscapesUsingEncoding
    //stringByReplacingPercentEscapesUsingEncoding
    NSString *str_Contents = [NSString stringWithString:strM];
//    NSString *str_Contents = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    if( str_Contents == nil )
//    {
//        str_Contents = str_Tmp;
//    }
    
    NSString *str_Path = @"";
    NSMutableDictionary *dicM_Params = nil;
    
    if( self.isQuestionMode )
    {
        str_Path = @"v1/add/reply/question";
        dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                       [Util getUUID], @"uuid",
                       self.str_Idx, @"questionId",
                       str_Contents, @"replyContents",
                       self.str_QnAId ? @"replay" : @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                       self.str_QnAId ? self.str_QnAId : @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
//                       self.str_GroupId ? self.str_GroupId : @"0", @"groupId",  //groupId: 답변인 경우 첫 질문의 eId값 (질문인 경우 0)
                       nil];
        
        if( self.str_GroupId )
        {
            [dicM_Params setObject:self.str_GroupId forKey:@"groupId"];
        }
        
        /*
         vc.str_QnAId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]];
         vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
         vc.str_GroupId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"groupId"]];
         */
    }
    else if( self.isFeedMode )
    {
        str_Path = @"v1/add/board/question";
        dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                       [Util getUUID], @"uuid",
                       self.str_Idx, @"questionId",
                       str_Contents, @"explainContents",
                       nil];
    }
    else
    {
        str_Path = @"v1/add/explain/question";
        dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                       [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                       [Util getUUID], @"uuid",
                       self.str_Idx, @"questionId",
                       str_Contents, @"explainContents",
                       nil];
    }

    
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
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
                                                //전송완료 후 센드버드 메세지 호출
                                                if( self.isQuestionMode )
                                                {
                                                    if( self.str_QnAId == nil )
                                                    {
                                                        //새로운 질문
                                                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                                                                                     @"eId":[resulte objectForKey:@"qnaId"]}
                                                                                                           options:NSJSONWritingPrettyPrinted
                                                                                                             error:&error];
                                                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        
//                                                        [SendBird sendMessage:@"regist-qna" withData:jsonString];
                                                    }
                                                    else
                                                    {
                                                        //새로운 답글
                                                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                                                                                     @"eId":[resulte objectForKey:@"qnaId"],
                                                                                                                     @"replyId":self.str_QnAId}
                                                                                                           options:NSJSONWritingPrettyPrinted
                                                                                                             error:&error];
                                                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                        
//                                                        [SendBird sendMessage:@"regist-reply" withData:jsonString];
                                                    }
                                                }
                                                else if( self.isFeedMode )
                                                {
                                                    /*
                                                     contentId = 35738;
                                                     "error_code" = success;
                                                     "error_message" = success;
                                                     packageId = 1501143889339;
                                                     questionId = 4;
                                                     "response_code" = 200;
                                                     success = success;
                                                     */
                                                }
                                                else
                                                {
                                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                                                                                 @"eId":[resulte objectForKey:@"explainId"]}
                                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                                         error:&error];
                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    
//                                                    [SendBird sendMessage:@"regist-explain" withData:jsonString];
                                                }
                                                
                                                if( self.isLastObj )
                                                {
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LastObjNoti"
                                                                                                        object:nil
                                                                                                      userInfo:nil];
                                                }

                                                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                
                                                if( weakSelf.dismissBlock )
                                                {
                                                    weakSelf.dismissBlock(resulte);
                                                }
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.btn_Done.userInteractionEnabled = YES;
                                    }];
}

@end
