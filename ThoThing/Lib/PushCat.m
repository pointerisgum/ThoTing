//
//  PushCat.m
//  push
//
//  Created by administrator on 13. 3. 2..
//  Copyright (c) 2013년 administrator. All rights reserved.
//

#import "Pushcat.h"
#import "SBJsonParser.h"

//#import "sbjson/SBJson.h"

// NSString* APP_DOMAIN = @"ntopgolf";
// NSString* SERVER_HOST = @"http://218.238.66.226:4001";  // ntopkorea

NSString* APP_DOMAIN = @"skinfood";
NSString* SERVER_HOST = @"http://182.162.136.237:4001";


static Pushcat* gPushCat = nil;

@implementation Pushcat

@synthesize Reserves;

+ (Pushcat*) get
{
    if ( gPushCat == nil ) {
        gPushCat = [[Pushcat alloc] init];
    }
    
    return gPushCat;
}

- (void) saveMemberId: (NSString*) aMemberId;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:aMemberId forKey:@"member_id"];
}

- (NSString*) loadMemberId;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* lMemberId = [prefs stringForKey:@"member_id"];
    
    if (lMemberId == nil) {
        lMemberId = @"0";
    }
    
    return lMemberId;
}

-(void) saveRecvOn: (NSString*) aRecvOn
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:aRecvOn forKey:@"recv_on"];
}

- (NSString*) loadRecvOn;
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString* lRecvOn = [prefs stringForKey:@"recv_on"];
    
    if (lRecvOn == nil) {
        lRecvOn = @"1";
    }
    
    return lRecvOn;
}


- (NSString*) registerPushcatWithTag: (NSString*) aTag Token: (NSString*) aToken;
{
    NSLog(@"Register tag: %@, token: %@", aTag, aToken);
    
    NSURL* lUrl = [NSURL URLWithString: [NSString stringWithFormat: @"%@/Register", SERVER_HOST]];
    NSMutableURLRequest* lReq = [NSMutableURLRequest requestWithURL: lUrl
                                                        cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval: 10.0];
    
    NSString* lOldMemberId = [self loadMemberId];
    
    NSString* lBody = [NSString stringWithFormat: @"member_id=%@&tag=%@&token=%@&os_type=1&recv_on=1&domain=%@", lOldMemberId, aTag, aToken, APP_DOMAIN];
    
    [lReq setHTTPMethod: @"POST"];
    [lReq setHTTPBody: [lBody dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSURLResponse* lResponse;
    NSError* lError = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:lReq returningResponse:&lResponse error:&lError];
    
    NSString* lResultString = [[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding];

    NSLog(@"register result : %@", lResultString);
    
    // set member_id
    SBJsonParser* lJsonParser = [[SBJsonParser alloc] init];
    NSDictionary* lDic = [lJsonParser objectWithString: lResultString];
    
    NSString* lMemberId = [lDic valueForKey: @"mMemberId"];
    [self saveMemberId: lMemberId];
    
    NSString* lRecvOn = [lDic valueForKey: @"mRecvOn"];
    [self saveRecvOn: lRecvOn];
    
    return lResultString;
}

- (NSString*) recvReserve
{
    NSLog(@"recvMsg");
    
    NSURL* lUrl = [NSURL URLWithString: [NSString stringWithFormat: @"%@/RecvReserve", SERVER_HOST]];
    NSMutableURLRequest* lReq = [NSMutableURLRequest requestWithURL: lUrl
                                                        cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval: 10.0];
    
    NSString* lMemberId = [self loadMemberId];
    NSString* lBody = [NSString stringWithFormat: @"member_id=%@", lMemberId];
    
    [lReq setHTTPMethod: @"POST"];
    [lReq setHTTPBody: [lBody dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSURLResponse* lResponse;
    NSError* lError = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:lReq returningResponse:&lResponse error:&lError];
    
    NSString* lResultString = [[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding];
    
    NSLog(@"recvReserve result : %@", lResultString);
    
    // set content
    int lTaskId = 0;
    NSString* lContent = @"";
    SBJsonParser* lJsonParser = [[SBJsonParser alloc] init];
    NSDictionary* lDic = [lJsonParser objectWithString: lResultString];
    
    NSInteger lResultCode = [[lDic valueForKey: @"mResultCode"] intValue];
    if (0 == lResultCode) {
        
        self.Reserves = [lDic valueForKey: @"mReserves"];
        for (NSDictionary* iDic in self.Reserves) {
            
            lTaskId = (int)[[iDic valueForKey: @"mTaskId"] integerValue];
            lContent = [iDic valueForKey: @"mContent"];
            
            NSLog(@"task_id: %d, content: %@", lTaskId, lContent);
        }
    }
    //
    
    return lContent;
}

- (NSString*) recvContent: (NSString*) aTaskId
{
    NSLog(@"recvContent");
    
    NSURL* lUrl = [NSURL URLWithString: [NSString stringWithFormat: @"%@/RecvContent", SERVER_HOST]];
    NSMutableURLRequest* lReq = [NSMutableURLRequest requestWithURL: lUrl
                                                        cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval: 10.0];
    
    NSString* lMemberId = [self loadMemberId];
    NSString* lBody = [NSString stringWithFormat: @"member_id=%@&task_id=%@", lMemberId, aTaskId];
    
    [lReq setHTTPMethod: @"POST"];
    [lReq setHTTPBody: [lBody dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSURLResponse* lResponse;
    NSError* lError = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:lReq returningResponse:&lResponse error:&lError];
    
    NSString* lResultString = [[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding];
    
    NSLog(@"recvContent result : %@", lResultString);
    
    // set content
    SBJsonParser* lJsonParser = [[SBJsonParser alloc] init];
    NSDictionary* lDic = [lJsonParser objectWithString: lResultString];
    
    // NSInteger lResultCode = [[lDic valueForKey: @"mResultCode"] intValue];
    NSString* lContent = [lDic valueForKey: @"mContent"];
    //
    
    return lContent;
    
}

- (NSString*) findContent: (int) aTaskId
{
    NSString *lContent = @"";
    int lTaskId = 0;
    
    for (NSDictionary* iDic in self.Reserves) {
        
        lTaskId = (int) [[iDic valueForKey: @"mTaskId"] integerValue];
        if (lTaskId == aTaskId) {
            lContent = [iDic valueForKey: @"mContent"];
            break;
        }        
    }
    
    return lContent;
}

- (NSString*) updateOption: (NSString*) aName :(NSString*) aValue;
{
    NSLog(@"updateOption");
    
    NSURL* lUrl = [NSURL URLWithString: [NSString stringWithFormat: @"%@/UpdateOption", SERVER_HOST]];
    NSMutableURLRequest* lReq = [NSMutableURLRequest requestWithURL: lUrl
                                                        cachePolicy: NSURLRequestUseProtocolCachePolicy
                                                    timeoutInterval: 10.0];
    
    NSString* lMemberId = [self loadMemberId];
    NSString* lBody = [NSString stringWithFormat: @"member_id=%@&name=%@&value=%@", lMemberId, aName, aValue];
    
    [lReq setHTTPMethod: @"POST"];
    [lReq setHTTPBody: [lBody dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSURLResponse* lResponse;
    NSError* lError = nil;
    NSData* result = [NSURLConnection sendSynchronousRequest:lReq returningResponse:&lResponse error:&lError];
    
    NSString* lResultString = [[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding];
    
    NSLog(@"updateOption result : %@", lResultString);
    
    SBJsonParser* lJsonParser = [[SBJsonParser alloc] init];
    NSDictionary* lDic = [lJsonParser objectWithString: lResultString];
    
    NSString* lRecvOn = [lDic valueForKey: @"mValue"];
    [self saveRecvOn: lRecvOn];
    
    return lRecvOn;
}

@end
