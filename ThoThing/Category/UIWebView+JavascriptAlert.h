//
//  UIWebView+JavascriptAlert.h
//  ASKing
//
//  Created by Kim Young-Min on 2013. 12. 27..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebFrame;
@interface UIWebView (JavascriptAlert) <UIAlertViewDelegate>
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
@end
