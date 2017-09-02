//
//  UIWebView+JavascriptAlert.m
//  ASKing
//
//  Created by Kim Young-Min on 2013. 12. 27..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import "UIWebView+JavascriptAlert.h"

static BOOL clicked;
static BOOL confirmed;

@implementation UIWebView (JavascriptAlert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
    [alert show];
 
    if( [message isEqualToString:@"방문보고서 저장에 실패하였습니다."] )
    {
        //보고서 저장 실패시
        
    }
    
    [self waitForClick];
}

- (void)waitForClick
{
    clicked = NO;
    while (!clicked && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
    {
        NSLog(@"Wait");
    }
}

- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
    [alert show];
    
    [self waitForClick];
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    alertView.delegate = nil;
    clicked = YES;
    confirmed = (buttonIndex == alertView.firstOtherButtonIndex);
}

@end
