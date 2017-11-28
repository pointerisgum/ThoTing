//
//  KikMainSearchViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 13..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikMainSearchViewController.h"
#import "ChatFeedCell.h"
#import "ChatFeedViewController.h"

@interface KikMainSearchViewController ()
@property (nonatomic, strong) NSMutableArray *arM_SearchTarget;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) SBDGroupChannelListQuery *groupChannelListQuery;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CancelWidth;
@property (nonatomic, weak) IBOutlet UITextField *tf_Search;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation KikMainSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    __weak __typeof__(self) weakSelf = self;

    [self.tf_Search becomeFirstResponder];
    
    self.arM_List = [NSMutableArray array];
    self.arM_SearchTarget = [NSMutableArray array];
    
    self.groupChannelListQuery = [SBDGroupChannel createMyGroupChannelListQuery];
    self.groupChannelListQuery.limit = 100;
    //    self.groupChannelListQuery.order = SBDGroupChannelListOrderChronological;   //시간순
    self.groupChannelListQuery.order = SBDGroupChannelListOrderLatestLastMessage;
    self.groupChannelListQuery.includeEmptyChannel = NO;   //아무 대화가 없는 채널 보일지 말지 (YES는 보이는거)
    //    self.groupChannelListQuery.customTypeFilter = self.str_ChannelId;
    
    NSLog(@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
    [self.groupChannelListQuery loadNextPageWithCompletionHandler:^(NSArray<SBDGroupChannel *> * _Nullable channels, SBDError * _Nullable error) {
        
        if (error != nil)
        {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.refreshControl endRefreshing];
//            });
            
            return;
        }
        
        self.arM_Original = [NSMutableArray arrayWithArray:channels];

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tbv_List reloadData];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                [weakSelf.refreshControl endRefreshing];
            });
        });
        
        for( NSInteger i = 0; i < self.arM_Original.count; i++ )
        {
            SBDGroupChannel *groupChannel = self.arM_Original[i];
            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if( dic_Tmp )
            {
                NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
                if( dic )
                {
                    [self.arM_SearchTarget addObject:dic];
                }
            }
        }
    }];


//    self.arM_List = [NSMutableArray arrayWithArray:self.arM_Original];
//    [self.tbv_List reloadData];
    
//    __weak __typeof__(self) weakSelf = self;
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//            [weakSelf.tbv_List reloadData];
//        });
//    });
//
//    [self.tbv_List reloadData];

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


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    __weak __typeof__(self) weakSelf = self;

    self.lc_CancelWidth.constant = 50.f;
    
    [UIView animateWithDuration:0.25f animations:^{
       
        [weakSelf.view layoutIfNeeded];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(searchRoom) withObject:nil afterDelay:0.1f];

    return YES;
}

- (void)searchRoom
{
    if( self.arM_Original == nil || self.arM_Original.count <= 0 )  return;
    
    [self.arM_List removeAllObjects];
    
    NSMutableArray *arM = [NSMutableArray arrayWithCapacity:self.arM_Original.count];
    for( NSInteger i = 0; i < self.arM_Original.count; i++ )
    {
        SBDGroupChannel *groupChannel = [self.arM_Original objectAtIndex:i];
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        [arM addObject:@{@"name":groupChannel.name, @"obj":groupChannel}];
    }
    
    
    NSArray *ar = [arM filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[c] %@", self.tf_Search.text]];
    
    for( NSInteger i = 0; i < ar.count; i++ )
    {
        NSDictionary *dic_Main = ar[i];
        SBDGroupChannel *groupChannel = [dic_Main objectForKey:@"obj"];
        [self.arM_List addObject:groupChannel];
    }

    [self.tbv_List reloadData];
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField{
//
//    if( textField == self.tf_AddMember ){
//        self.arM_List = self.arM_ListBackup;
//        [self.tbv_List reloadData];
//    }
//
//    return YES;
//}



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
    ChatFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatFeedCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.tag = indexPath.row;
    
    cell.iv_User.backgroundColor = [UIColor clearColor];
    //    cell.iv_User1.backgroundColor = [UIColor clearColor];
    //    cell.iv_User2.backgroundColor = [UIColor clearColor];
    
    SBDGroupChannel *groupChannel = self.arM_List[indexPath.row];
//    SBDBaseChannel *baseChannel = (SBDBaseChannel *)groupChannel;
    SBDUserMessage *lastMessage = (SBDUserMessage *)groupChannel.lastMessage;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[groupChannel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    //    NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
    
    //    NSDictionary *dic_Main = self.arM_DicList[indexPath.row];
    //    NSDictionary *dic = [dic_Main objectForKey:@"info"];
    //    NSString *str_RoomName = [dic_Main objectForKey:@"name"];
    //    NSInteger nMemberCount = [[dic_Main objectForKey:@"memberCount"] integerValue];
    //    NSArray *ar_Members = [NSArray arrayWithArray:[dic_Main objectForKey:@"members"]];
    //    NSInteger nUnreadMessageCount = [[dic_Main objectForKey:@"unreadMessageCount"] integerValue];
    //    NSString *str_CustomType = [dic_Main objectForKey:@"customType"];
    //    NSString *str_LastMessage = [dic_Main objectForKey:@"message"];
    //    NSString *str_LastMessageCreateAt = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastMessageCreatedAt"]];
    //    long long llLastMessageCreatedAt = [str_LastMessageCreateAt longLongValue];
    //    NSString *str_ChannelCreateAt = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"channelCreatedAt"]];
    //    long long llChannelCreatedAt = [str_ChannelCreateAt longLongValue];
    
    
    cell.iv_User.image = BundleImage(@"");
    cell.iv_User1.image = BundleImage(@"");
    cell.iv_User2.image = BundleImage(@"");
    cell.lb_Title.text = @"";
    cell.lb_GroupCount.text = @"";
    
    cell.iv_User.hidden = NO;
    cell.iv_User1.hidden = YES;
    cell.iv_User2.hidden = YES;
    
    if( groupChannel.memberCount <= 2 )
    {
        //1:1chat
        if( groupChannel.memberCount == 1 )
        {
            SBDUser *user = groupChannel.members[0];
            cell.lb_Title.text = user.nickname;
            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
        }
        else
        {
            for( NSInteger i = 0; i < groupChannel.memberCount; i++ )
            {
                SBDUser *user = groupChannel.members[i];
                NSString *str_MyUserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                if( [str_MyUserId isEqualToString:user.userId] == NO )
                {
                    cell.lb_Title.text = user.nickname;
                    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
                    
                    break;
                }
            }
        }
    }
    else
    {
        //group chat
        NSLog(@"groupChannel.customType: %@", groupChannel.customType);
        if( [groupChannel.customType isEqualToString:@"channel"] )
        {
            //섬네일이 있는 그룹방
            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:groupChannel.coverUrl] placeholderImage:BundleImage(@"")];
        }
        else if( [groupChannel.customType isEqualToString:@"opengroup"] )
        {
            //이건 #채널 (항상 이미지와 타이틀이 있음)
            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:groupChannel.coverUrl] placeholderImage:BundleImage(@"")];
        }
        else if( [groupChannel.customType isEqualToString:@"group"] )
        {
            //이름과 섬네일이 없는 그룹방
            cell.iv_User.hidden = YES;
            cell.iv_User1.hidden = NO;
            cell.iv_User2.hidden = NO;
            
            NSMutableArray *arM = [NSMutableArray arrayWithArray:groupChannel.members];
            for( NSInteger i = 0; i < arM.count; i++ )
            {
                //그룹 챗일 경우 내 이미지는 제거한다
                SBDUser *user = arM[i];
                NSString *str_MyId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                if( [str_MyId isEqualToString:user.userId] )
                {
                    [arM removeObjectAtIndex:i];
                    break;
                }
            }
            
            for( NSInteger i = 0; i < 2; i++ )
            {
                SBDUser *user = arM[i];
                if( i == 0 )
                {
                    [cell.iv_User1 sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
                }
                else if( i == 1 )
                {
                    [cell.iv_User2 sd_setImageWithURL:[NSURL URLWithString:user.profileUrl] placeholderImage:BundleImage(@"")];
                }
            }
        }
        
        cell.lb_Title.text = groupChannel.name;
    }

    
    //뱃지 카운트
    if( groupChannel.unreadMessageCount > 0 )
    {
        cell.v_BadgeGuide.hidden = NO;
        cell.lb_Badge.text = [NSString stringWithFormat:@"%ld", groupChannel.unreadMessageCount];
    }
    else
    {
        cell.lb_Badge.text = @"0";
        cell.v_BadgeGuide.hidden = YES;
    }
    
    cell.btn_Type.hidden = YES;
    
    //마지막 메세지 (이미지, 동영상, 텍스트에 대한 구분이 필요함)
    //    SBDUserMessage *lastMessage = (SBDUserMessage *)groupChannel.lastMessage;
    NSLog(@"lastMessage.customType: %@", lastMessage.customType);
    if( [groupChannel.customType isKindOfClass:[NSString class]] == NO )
    {
        //예외처리
        [cell.btn_Type setTitle:@"" forState:UIControlStateNormal];
        cell.btn_Type.hidden = YES;
        cell.lb_Disc2.text = @"";
        
        return cell;
    }
    
    NSString *str_CustomType = lastMessage.customType;
    //    if( [groupChannel.customType isEqualToString:@"chatBot"] )
    //    {
    //        str_CustomType = lastMessage.customType;
    //    }
    //    else
    //    {
    ////        str_CustomType = groupChannel.customType;
    //        str_CustomType = lastMessage.customType;
    //    }
    if( [str_CustomType isEqualToString:@"image"] || [str_CustomType isEqualToString:@"pdfImage"] )
    {
        [cell.btn_Type setImage:BundleImage(@"camera_icon_small.png") forState:UIControlStateNormal];
        [cell.btn_Type setTitle:@"사진" forState:UIControlStateNormal];
        cell.btn_Type.hidden = NO;
        
        cell.lb_Disc2.text = @"";
    }
    else if( [str_CustomType isEqualToString:@"video"] )
    {
        [cell.btn_Type setImage:BundleImage(@"video_icon_samll.png") forState:UIControlStateNormal];
        [cell.btn_Type setTitle:@"동영상" forState:UIControlStateNormal];
        cell.btn_Type.hidden = NO;
        
        cell.lb_Disc2.text = @"";
    }
    else if( [str_CustomType isEqualToString:@"pdf"] )
    {
        [cell.btn_Type setImage:BundleImage(@"camera_icon_small.png") forState:UIControlStateNormal];
        [cell.btn_Type setTitle:@"PDF 문제" forState:UIControlStateNormal];
        cell.btn_Type.hidden = NO;
        
        cell.lb_Disc2.text = @"";
    }
    else if( [str_CustomType isEqualToString:@"audio"] )
    {
        [cell.btn_Type setImage:BundleImage(@"audio_icon_samll.png") forState:UIControlStateNormal];
        [cell.btn_Type setTitle:@"음성" forState:UIControlStateNormal];
        cell.btn_Type.hidden = NO;
        
        cell.lb_Disc2.text = @"";
    }
    else if( [str_CustomType isEqualToString:@"shareExam"] || [str_CustomType isEqualToString:@"shareQuestion"] )
    {
        cell.lb_Disc1.text = [dic objectForKey_YM:@"subjectName"];
        cell.lb_Disc1.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        
        if( cell.lb_Disc1.text.length > 0 )
        {
            cell.lb_Disc2.text = [NSString stringWithFormat:@" %@", [dic objectForKey_YM:@"examTitle"]];
            cell.lb_Disc2.text = [cell.lb_Disc2.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
            NSMutableString *strM = [NSMutableString string];
            [strM appendString:cell.lb_Disc2.text];
            cell.lb_Disc2.text = strM;
        }
        else
        {
            cell.lb_Disc2.text = lastMessage.message;
            
            NSMutableString *strM = [NSMutableString string];
            //            [strM appendString:@"''"];
            [strM appendString:cell.lb_Disc2.text];
            //            [strM appendString:@"''"];
            cell.lb_Disc2.text = strM;
        }
    }
    else if( [str_CustomType isEqualToString:@"pdfQuestion"] || [str_CustomType isEqualToString:@"normalQuestion"] )
    {
        cell.lb_Disc1.text = @"";
        cell.lb_Disc2.text = @"""질문이 등록 되었습니다""";
    }
    else if( [lastMessage.customType isEqualToString:@"videoLink"] )
    {
        [cell.btn_Type setImage:BundleImage(@"video_icon_samll.png") forState:UIControlStateNormal];
        [cell.btn_Type setTitle:@"동영상링크" forState:UIControlStateNormal];
        cell.btn_Type.hidden = NO;
    }
    //    else if( [lastMessage.customType isEqualToString:@"shareQuestion"] )
    //    {
    //
    //    }
    else
    {
        if( lastMessage.message.length > 0 )
        {
            cell.lb_Disc2.text = lastMessage.message;
        }
        else
        {
            cell.lb_Disc2.text = @"";
        }
        //    NSLog(@"lastMessage.createdAt : %lld", lastMessage.createdAt);
    }
    
    NSDate *lastMessageDate = nil;
    if( lastMessage.createdAt <= 0 )
    {
        //마지막 메세지가 없을때
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastMessage.createdAt];
        
    }
    else
    {
        //마지막 메세지가 있을때
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:(double)lastMessage.createdAt / 1000.0f];
    }
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:lastMessageDate];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSString *str_Date = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond];
    cell.lb_Date.text = [Util getMainThotingChatDate:str_Date];

    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SBDGroupChannel *groupChannel = self.arM_List[indexPath.row];

    __weak __typeof__(self) weakSelf = self;
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        if( weakSelf.completionBlock )
        {
            weakSelf.completionBlock(groupChannel);
        }
    }];
}

- (NSString *)getDday:(NSString *)aDay
{
    aDay = [aDay stringByReplacingOccurrencesOfString:@"-" withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@" " withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *str_Year = [aDay substringWithRange:NSMakeRange(0, 4)];
    NSString *str_Month = [aDay substringWithRange:NSMakeRange(4, 2)];
    NSString *str_Day = [aDay substringWithRange:NSMakeRange(6, 2)];
    NSString *str_Hour = [aDay substringWithRange:NSMakeRange(8, 2)];
    NSString *str_Minute = [aDay substringWithRange:NSMakeRange(10, 2)];
    NSString *str_Second = [aDay substringWithRange:NSMakeRange(12, 2)];
    NSString *str_Date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", str_Year, str_Month, str_Day, str_Hour, str_Minute, str_Second];
    
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    
    NSDate *ddayDate = [format1 dateFromString:str_Date];
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSDate *currentTime = [format1 dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond]];
    
    NSTimeInterval diff = [currentTime timeIntervalSinceDate:ddayDate];
    
    NSTimeInterval nWriteTime = diff;
    
    
    
    
    if( nWriteTime > (60 * 60 * 24) )
    {
        //        return [NSString stringWithFormat:@"%@-%@-%@", str_Year, str_Month, str_Day];
        return [NSString stringWithFormat:@"%@월 %@일", str_Month, str_Day];
    }
    else
    {
        if( nWriteTime <= 0 )
        {
            return @"1초전";
        }
        else if( nWriteTime < 60 )
        {
            //1분보다 작을 경우
            return [NSString stringWithFormat:@"%.0f초전", nWriteTime];
        }
        else if( nWriteTime < (60 * 60) )
        {
            //1시간보다 작을 경우
            return [NSString stringWithFormat:@"%.0f분전", nWriteTime / 60];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f시간전", ((nWriteTime / 60) / 60)];
        }
    }
    
    
    return @"";
}


#pragma mark - IBAction
- (IBAction)goCancel:(id)sender
{
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
