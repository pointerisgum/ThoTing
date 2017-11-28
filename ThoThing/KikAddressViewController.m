//
//  KikAddressViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikAddressViewController.h"
#import <AddressBook/AddressBook.h>
//#import "APAddressBook.h"
//#import "APContact.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface AddressCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_PhoneNumber;
@property (nonatomic, weak) IBOutlet UIButton *btn_Invite;
@end

@implementation AddressCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end


@interface KikAddressViewController () <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_BackUpList;
@property (nonatomic, strong) NSArray *ar_InstallUser;
@property (nonatomic, weak) IBOutlet UITextField *tf_Search;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation KikAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getList];
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

- (void)getList
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //dispatch_release(semaphore);
    }
    else
    { // We are on iOS 5 or Older
        accessGranted = YES;
        [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted)
    {
        [self getContactsWithAddressBook:addressBook];
    }
    
//    self.ar_InstallUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"installUserList"];
//
//    if( self.ar_InstallUser == nil )
//    {
//        [self updateAddressList];
//    }
}

// Get the contacts.
- (void)getContactsWithAddressBook:(ABAddressBookRef )addressBook
{
    self.arM_List = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    for (int i=0;i < nPeople;i++)
    {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        NSMutableString *strM_Name = [NSMutableString string];
        CFStringRef firstName, lastName;
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if( firstName )
        {
            [strM_Name appendString:[NSString stringWithFormat:@"%@", firstName]];
        }
        
        if( lastName )
        {
            if( strM_Name.length > 0 )
            {
                [strM_Name appendString:@" "];
            }
            
            [strM_Name appendString:[NSString stringWithFormat:@"%@", lastName]];
        }

        if( strM_Name == nil || strM_Name.length <= 0 || [strM_Name isEqualToString:@" "] )
        {
            continue;
        }

        [dOfPerson setObject:[NSString stringWithFormat:@"%@", strM_Name] forKey:@"name"];

        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0)
        {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
        }
        
        if( ABMultiValueGetCount(phones) <= 0 )
        {
            continue;
        }
        

        //For Phone number
        NSString* mobileLabel;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++)
        {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
                break ;
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMainLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABHomeLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABWorkLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABOtherLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"phone"];
            }
        }
        
        [self.arM_List addObject:dOfPerson];
    }
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    self.arM_List = [NSMutableArray arrayWithArray:[self.arM_List sortedArrayUsingDescriptors:@[descriptor]]];
    self.arM_BackUpList = [NSMutableArray arrayWithArray:self.arM_List];
    NSLog(@"Contacts = %@",self.arM_List);
}

- (void)updateAddressList
{
    __weak __typeof(&*self)weakSelf = self;

    __block UITextField *tf_Tmp = nil;
    NSString *str_UserPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    if( str_UserPhoneNumber == nil || str_UserPhoneNumber.length <= 0 )
    {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"전화번호"
                                      message:@"전화번호를 입력해 주세요"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       //Do Some action here

                                                       if( tf_Tmp.text && tf_Tmp.text.length > 0 )
                                                       {
                                                           [[NSUserDefaults standardUserDefaults] setObject:tf_Tmp.text forKey:@"phoneNumber"];
                                                           [[NSUserDefaults standardUserDefaults] synchronize];
                                                           [weakSelf updateAddressList];
                                                       }
                                                   }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"01012341234";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            tf_Tmp = textField;
        }];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        //이름|국가코드|전화번호|이메일
        NSMutableArray *arM = [NSMutableArray array];
        
//        NSError * err;
//        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resulte options:0 error:&err];
//        NSString *str_Data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        NSMutableString *strM = [NSMutableString string];
        for( NSInteger i = 0; i < self.arM_BackUpList.count; i++ )
        {
            NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
            
            NSDictionary *dic = self.arM_BackUpList[i];
            
            NSString *str_Name = [dic objectForKey_YM:@"name"];
            NSString *str_PhoneNumber = [dic objectForKey_YM:@"phone"];
            NSString *str_Email = [dic objectForKey_YM:@"email"];
            
            if( str_Name.length <= 0 || str_PhoneNumber.length <= 0 )
            {
                continue;
            }
            
            [dicM setObject:str_Name forKey:@"name"];
//            [strM appendString:str_Name];
//            [strM appendString:@"|"];
            
            if( [str_PhoneNumber hasPrefix:@"82"] )
            {
//                [strM appendString:@"82"];
                [dicM setObject:@"82" forKey:@"code"];
            }
//            [strM appendString:@"|"];
            
            str_PhoneNumber = [str_PhoneNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
            str_PhoneNumber = [str_PhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
            str_PhoneNumber = [str_PhoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            if( [str_PhoneNumber hasPrefix:@"0"] == NO )
            {
                NSString *str_Tmp = [NSString stringWithFormat:@"0%@", str_PhoneNumber];
                str_PhoneNumber = str_Tmp;
            }
            
//            [strM appendString:str_PhoneNumber];
//            [strM appendString:@"|"];
            [dicM setObject:str_PhoneNumber forKey:@"phone"];

            
//            [strM appendString:str_Email];
            [dicM setObject:str_Email forKey:@"email"];

//            [strM appendString:@","];
            [arM addObject:dicM];
        }
        
        if( [strM hasSuffix:@","] )
        {
            [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
        }

        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            str_UserPhoneNumber, @"myPhoneNumber",
//                                            @"kym|||, test||01091810664|plzallyme@gmail.com", @"contactList",
                                            arM, @"contactList",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/uplaod/contact/list"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    /*
                                                     email = "ss25@t.com";
                                                     phoneNumber = "";
                                                     userId = 154;
                                                     userName = "\Uae40\Uc601\Ubbfc25";
                                                     */
                                                    
                                                    NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"installUserList"]];
                                                    [[NSUserDefaults standardUserDefaults] setObject:ar forKey:@"installUserList"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                }
                                            }
                                        }];

    }
    


}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(searchRoom) withObject:nil afterDelay:0.1f];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.arM_List = [NSMutableArray arrayWithArray:self.arM_BackUpList];
    [self.tbv_List reloadData];

    return YES;
}

- (void)searchRoom
{
    [self.arM_List removeAllObjects];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"name contains[c] %@", self.tf_Search.text];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"phone contains[c] %@", self.tf_Search.text];
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[p1, p2]];
    
    NSArray *ar = [self.arM_BackUpList filteredArrayUsingPredicate:predicate];
    
    self.arM_List = [NSMutableArray arrayWithArray:ar];
    
    [self.tbv_List reloadData];
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
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    cell.lb_Name.text = @"";
    cell.lb_PhoneNumber.text = @"";
    
    NSDictionary *dic = self.arM_List[indexPath.row];

    cell.lb_Name.text = [dic objectForKey_YM:@"name"];

    NSString *str_PhoneNumber = [dic objectForKey_YM:@"phone"];
    if( str_PhoneNumber && str_PhoneNumber.length > 0 )
    {
        cell.lb_PhoneNumber.text = str_PhoneNumber;
    }
    else
    {
        NSString *str_Email = [dic objectForKey_YM:@"email"];
        if( str_Email && str_Email.length > 0 )
        {
            cell.lb_PhoneNumber.text = str_Email;
        }
    }

    cell.btn_Invite.tag = indexPath.row;
    [cell.btn_Invite addTarget:self action:@selector(onInvite:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

//    [self invite:indexPath.row];
}


- (void)onInvite:(UIButton *)btn
{
    [self invite:btn.tag];
}

- (void)invite:(NSInteger)idx
{
    NSDictionary *dic = self.arM_List[idx];
    
    NSString *str_UserEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    NSString *str_Body = [NSString stringWithFormat:@"http://app.thoting.com/user?email=%@", str_UserEmail];

    NSString *str_PhoneNumber = [dic objectForKey_YM:@"phone"];
    if( str_PhoneNumber && str_PhoneNumber.length > 0 )
    {
        MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
        picker.messageComposeDelegate = self;
        picker.recipients = [NSArray arrayWithObjects:str_PhoneNumber, nil];
        picker.body = str_Body;
        
        [self presentViewController:picker animated:YES completion:^{
            
        }];
    }
    else
    {
        NSString *str_Email = [dic objectForKey_YM:@"email"];
        if( str_Email && str_Email.length > 0 )
        {
            MFMailComposeViewController* mc = [[MFMailComposeViewController alloc] init];
            //set delegate
            mc.mailComposeDelegate = self;
            
            //set message body
            [mc setMessageBody:str_Body isHTML:NO];
            //set message subject
            [mc setSubject:@"토팅으로 초대 합니다"];
            
            //set message recipients
            [mc setToRecipients:[NSArray arrayWithObject:str_Email]];
            
            [self presentViewController:mc animated:YES completion:^{
                
            }];
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //if result is possible
    if(result == MFMailComposeResultSent || result == MFMailComposeResultSaved || result == MFMailComposeResultCancelled)
    {
        //test result and show alert
        switch (result)
        {
            case MFMailComposeResultCancelled:
//                [self makeAlert:@"Result Cancelled"];
                break;
            case MFMailComposeResultSaved:
//                [self makeAlert:@"Result saved"];
                break;
                //message was sent
            case MFMailComposeResultSent:
//                [self makeAlert:@"Result Sent"];
                break;
            case MFMailComposeResultFailed:
//                [self makeAlert:@"Result Failed"];
                break;
            default:
                break;
        }
    }
    //else exists error
    else if(error != nil)
    {
        //show error
//        [self makeAlert:[error localizedDescription]];
    }
    
    //dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

