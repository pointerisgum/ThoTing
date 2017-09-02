//
//  PushCat.h
//  push
//
//  Created by administrator on 13. 3. 2..
//  Copyright (c) 2013년 administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pushcat : NSObject
{

}

+ (Pushcat*) get;

@property (nonatomic) NSArray* Reserves;

- (NSString*) registerPushcatWithTag: (NSString*) aTag Token: (NSString*) aToken;
- (NSString*) recvReserve;
- (NSString*) recvContent: (NSString*) aTaskId;
- (NSString*) findContent: (int) aTaskId;
- (NSString*) updateOption: (NSString*) aName :(NSString*) aValue;

- (NSString*) loadMemberId;
- (NSString*) loadRecvOn;

@end
