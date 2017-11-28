//
//  EtcWebViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 21..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "EtcWebViewController.h"

@interface EtcWebViewController ()
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation EtcWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lb_Title.text = self.str_Title;
    
//    NSString *str_Url = [NSString stringWithFormat:@"%@/%@", kBaseWebUrl, self.str_Url];
//    NSLog(@"webview url : %@", str_Url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.str_Url]];
    [self.webView loadRequest:request];
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

@end
