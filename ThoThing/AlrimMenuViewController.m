//
//  AlrimMenuViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "AlrimMenuViewController.h"

@interface AlrimMenuViewController ()
@property (nonatomic, weak) IBOutlet UISwitch *sw_Sound;        //소리
@property (nonatomic, weak) IBOutlet UISwitch *sw_Vibrator;     //진동
@property (nonatomic, weak) IBOutlet UISwitch *sw_Bot;          //봇 알람
@property (nonatomic, weak) IBOutlet UISwitch *sw_Preview;      //메세지 미리 보기
@property (nonatomic, weak) IBOutlet UISwitch *sw_Contact;      //기기 연락처 사용
@end

@implementation AlrimMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BOOL isPushSount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushSount"] boolValue];
    self.sw_Sound.on = isPushSount;
    
    BOOL isPushVibrator = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushVibrator"] boolValue];
    self.sw_Vibrator.on = isPushVibrator;
    
    BOOL isPushBot = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushBot"] boolValue];
    self.sw_Bot.on = isPushBot;
    
    BOOL isPushPreview = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushPreview"] boolValue];
    self.sw_Preview.on = isPushPreview;
    
    BOOL isPushContact = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushContact"] boolValue];
    self.sw_Contact.on = isPushContact;
    

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

- (IBAction)goSwValueChange:(id)sender
{
    if( sender == self.sw_Sound )
    {
        if( self.sw_Sound.on )
        {
            UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.sw_Sound.on] forKey:@"PushSount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if( sender == self.sw_Vibrator )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.sw_Vibrator.on] forKey:@"PushVibrator"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if( sender == self.sw_Bot )
    {
        __weak __typeof(&*self)weakSelf = self;
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            self.sw_Bot.on ? @"on" : @"off", @"alarmStatus",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/my/chatbot/alarm"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:weakSelf.sw_Bot.on] forKey:@"PushBot"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                }
                                            }
                                        }];
    }
    else if( sender == self.sw_Preview )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.sw_Preview.on] forKey:@"PushPreview"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if( sender == self.sw_Contact )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.sw_Contact.on] forKey:@"PushContact"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}
@end
