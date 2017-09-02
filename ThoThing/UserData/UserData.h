//
//  UserData.h
//  ELearning
//
//  Created by Kim Young-Min on 2014. 2. 18..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserData : NSObject
@property (nonatomic, strong) NSDictionary *dic_UserInfo;
+ (UserData *)sharedData;
@end
