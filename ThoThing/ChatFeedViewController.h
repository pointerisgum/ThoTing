//
//  ChatFeedViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 24..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatFeedViewController : UIViewController
@property (nonatomic, strong) NSString *str_RId;
@property (nonatomic, strong) NSDictionary *dic_Info;
//@property (nonatomic, strong) NSString *str_ChatType;
@property (nonatomic, strong) UIColor *roomColor;
@property (nonatomic, strong) NSURL *channelImageUrl;
@property (nonatomic, strong) NSString *str_RoomName;

@property (nonatomic, strong) NSString *str_RoomTitle;
@property (nonatomic, strong) NSString *str_RoomThumb;
@property (nonatomic, strong) NSArray *ar_UserIds;

//@property (nonatomic, strong) NSString *str_ChannelUrl;

@property (strong, nonatomic) SBDGroupChannel *channel;

@property (nonatomic, strong) NSDictionary *dic_MoveExamInfo;   //푸시로 문제 공유 타고 왔을때

//질문을 통해 들어왔을때 쓰임
@property (nonatomic, assign) BOOL isAskMode;
@property (nonatomic, assign) BOOL isPdfMode;
@property (nonatomic, strong) NSDictionary *dic_PdfQuestionInfo;
@property (nonatomic, strong) NSString *str_PdfImageUrl;    //PDF 이미지 url (질문을 통해 들어왔을때 쓰임)
@property (nonatomic, strong) NSString *str_ExamId;         //문제지 아이디 (질문을 통해 들어왔을때 쓰임)
@property (nonatomic, strong) NSString *str_ExamTitle;      //문제지 제목 (질문을 통해 들어왔을때 쓰임)
@property (nonatomic, strong) NSString *str_ExamNo;         //문제번호 (질문을 통해 들어왔을때 쓰임)
@property (nonatomic, strong) NSString *str_SubjectName;    //과목이름 (질문을 통해 들어왔을때 쓰임)
@property (nonatomic, strong) NSString *str_PdfPage;
@property (nonatomic, strong) NSString *str_QuestinId;


@property (nonatomic, strong) NSDictionary *dic_NormalQuestionInfo;
@property (nonatomic, strong) NSString *str_ChannelIdTmp;

@property (nonatomic, strong) NSDictionary *dic_BotInfo;

@end
