//
//  YZHRecentSessionExtManage.h
//  NIM
//
//  Created by Jersey on 2018/10/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZHRecentSessionBadgeExtManage : NSObject

@property (nonatomic, assign) BOOL communityBadge;
@property (nonatomic, assign) BOOL privatelyBadge;

@property (nonatomic, strong) NSMutableArray<NIMRecentSession *>* communityRecents;
@property (nonatomic, strong) NSMutableArray<NIMRecentSession *>* privatelyRecents;
@property (nonatomic, strong) NSMutableArray<NIMRecentSession *>* allRecentSession;

- (void)refreshRecentSession:(NIMRecentSession* )recentSession;
- (void)removeRecentSession:(NIMRecentSession* )recentSession;
- (void)addRecentSession:(NIMRecentSession *)recentSession;
- (void)configuration;

@end

@interface YZHRecentSeesionExtModel : NSObject

@property (nonatomic, copy) NSString* tagName;

@end

@interface YZHRecentSessionExtManage : NSObject

@property (nonatomic, strong) NSMutableArray<NSMutableArray<NIMRecentSession*>* >* tagsRecentSession; //私聊
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NIMRecentSession*>* >* tagsTeamRecentSession; //群聊
@property (nonatomic, strong) NSMutableArray<NIMRecentSession* >* TeamRecentSession; //群聊默认列表回话.
@property (nonatomic, strong) NSMutableArray<NIMRecentSession* >* lockTeamRecentSession;
@property (nonatomic, assign) NSInteger topTeamCount;

//@property (nonatomic, strong) NSArray<NIMUser* >* myFriends;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> * currentSessionTags;
@property (nonatomic, strong) NSArray* defaultTags;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> * teamCurrentSessionTags;
@property (nonatomic, strong) NSArray* teamDefaultTags;

// 对最近回话进行标签分类
- (void)screeningTagSessionAllRecentSession:(NSMutableArray<NIMRecentSession* > *)allRecentSession;
- (void)sortTagRecentSession;
- (void)screeningAllPrivateRecebtSessionRecentSession:(NSMutableArray<NIMRecentSession* > *)allRecentSession;
// 当回话发送变动时,会最近回话进行新增与删除

// 置顶.
//检查当前回话的目标用户是否包含扩展标签,包含则更新到回话本地扩展。
- (void)checkSessionUserTagWithRecentSession:(NIMRecentSession* )recentSession;


// 对群聊最近回话进行标签分类
- (void)screeningTagSessionAllTeamRecentSession:(NSMutableArray<NIMRecentSession* > *)allRecentSession;
- (void)sortTagTeamRecentSession;
- (void)screeningDefaultSessionAllTeamRecentSession:(NSMutableArray<NIMRecentSession* > *)allRecentSession; // 对默认列表进行排序,

- (void)screeningAllTeamRecentSession:(NSMutableArray<NIMRecentSession* > *)allRecentSession;

- (void)checkSessionUserTagWithTeamRecentSession:(NIMRecentSession* )recentSession;//暂时用不着

- (BOOL)checkoutContainLockTeamRecentSessions:(NSMutableArray<NIMRecentSession* >*)recentSessions;
- (BOOL)checkoutContainTopOrLockTeamRecentSession:(NIMRecentSession* )recentSession;
- (BOOL)checkoutContainTopTeamRecentSession:(NIMRecentSession* )recentSession;

@end

NS_ASSUME_NONNULL_END
