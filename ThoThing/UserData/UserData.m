//
//  UserData.m
//  ELearning
//
//  Created by Kim Young-Min on 2014. 2. 18..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import "UserData.h"

static UserData *shared = nil;

@implementation UserData

+ (void)initialize
{
    NSAssert(self == [UserData class], @"Singleton is not designed to be subclassed.");
    shared = [UserData new];
    [UserData sharedData].dic_UserInfo = [NSDictionary dictionary];
}

+ (UserData *)sharedData
{
    return shared;
}

@end
