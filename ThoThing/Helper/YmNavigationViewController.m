//
//  YmNavigationViewController.m
//  PB
//
//  Created by KimYoung-Min on 2014. 12. 7..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import "YmNavigationViewController.h"
#import "ChatFeedViewController.h"

@interface YmNavigationViewController ()

@end

@implementation YmNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
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

- (BOOL)shouldAutorotate
{
    return [super shouldAutorotate];
    
//    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"%ld", interfaceOrientation);
    //[[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
//    id lastVc = [self.viewControllers lastObject];
//    if( [lastVc isKindOfClass:[ChatFeedViewController class]] )
//    {
//        [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
////        return YES;
//    }
    
    [[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    id lastVc = [self.viewControllers lastObject];
    [lastVc supportedInterfaceOrientations];

    NSString *str_ClassName = NSStringFromClass([lastVc class]);

    if( [str_ClassName isEqualToString:@"ChatFeedViewController"] )
//    if( [lastVc isKindOfClass:[ChatFeedViewController class]] )
    {
//        [lastVc supportedInterfaceOrientations];
        
//        return [super supportedInterfaceOrientations];
        
//        return UIInterfaceOrientationMaskPortrait;
//        return UIInterfaceOrientationMaskAll;
    }
    else if( [str_ClassName isEqualToString:@"AVFullScreenViewController"] )
    {
//        return UIInterfaceOrientationMaskAll;
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    id lastVc = [self.viewControllers lastObject];

    if( [lastVc isKindOfClass:[ChatFeedViewController class]] )
    {
        return UIInterfaceOrientationMaskAll;
    }

    return UIInterfaceOrientationMaskPortrait;
}

@end
