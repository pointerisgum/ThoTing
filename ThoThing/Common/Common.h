//
//  Common.h
//  Pari
//
//  Created by KimYoung-Min on 2014. 12. 27..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReaderDocument.h"

@interface Common : NSObject

+ (Common *)sharedData;

+ (void)setCntButton:(NSString *)aString withObj:(UIButton *)btn;

+ (void)setUserInfo:(NSDictionary *)dic;

+ (NSDictionary *)getUserInfo;

+ (void)removeUserInfo;


//스크랩 등록
+ (void)addScrapWithAucId:(NSString *)aAucId withLotNum:(NSString *)aLotNum withBlock:(void(^)(BOOL isSuccess))completion;

//스크랩 삭제
+ (void)deleteScrapWithAucId:(NSString *)aAucId withLotNum:(NSString *)aLotNum withBlock:(void(^)(BOOL isSuccess))completion;

+ (id)getAreaList;

+ (id)getStyleList;

+ (id)getInterestList;

+ (id)getFaithList;

+ (id)getCharmList;

+ (ReaderDocument *)getPdfDocument;

+ (void)setPdfDocument:(ReaderDocument *)doc;

//토팅 푸시 레지스터 함수
+ (void)registToken;

//노티 상세화면
+ (void)showDetailNoti:(UIViewController *)vcParent withInfo:(NSDictionary *)dic;

//패브릭
+ (void)logUser;

+ (void)removeAllPdfFile;

@end
