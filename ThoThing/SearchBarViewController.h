//
//  SearchBarViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 29..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchBarViewController : UIViewController
@property (nonatomic, assign) BOOL isLibraryMode;
@property (nonatomic, strong) NSString *str_Type;
@property (nonatomic, strong) NSString *str_SearchWord;
@end
