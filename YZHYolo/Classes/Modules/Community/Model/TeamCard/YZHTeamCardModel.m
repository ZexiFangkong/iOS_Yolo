//
//  YZHTeamCardModel.m
//  YZHYolo
//
//  Created by Jersey on 2018/11/19.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "YZHTeamCardModel.h"

#import "YZHTeamInfoExtManage.h"
#import "YZHTeamExtManage.h"
#import "NTESSessionUtil.h"

@implementation YZHTeamHeaderModel



@end

@implementation YZHTeamDetailModel



@end

@implementation YZHTeamCardModel

- (instancetype)initWithTeamId:(NSString *)teamId isManage:(BOOL)isManage {
    
    self = [super init];
    if (self) {
        _teamId = [teamId copy];
        _isManage = isManage;
        
        [self configuration];
    }
    return self;
}

- (void)configuration {
   
    NIMTeam* team = [[[NIMSDK sharedSDK] teamManager] teamById:_teamId];
    NSString* userId = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    NIMTeamMember* member = [[[NIMSDK sharedSDK] teamManager] teamMember:userId inTeam:_teamId];
    YZHTeamInfoExtManage* teamInfoExtManage = [YZHTeamInfoExtManage YZH_objectWithKeyValues:team.clientCustomInfo];
    
    YZHTeamHeaderModel* headerModel = [[YZHTeamHeaderModel alloc] init];
    headerModel.teamName = team.teamName;
    headerModel.teamSynopsis = team.intro;
    headerModel.avatarImageName = team.avatarUrl;
    headerModel.labelArray = teamInfoExtManage.labelArray;
    headerModel.canEdit = _isManage;
    headerModel.viewClass = @"YZHTeamCardHeaderView";
    headerModel.teamId = _teamId;
    
    YZHTeamDetailModel* sharedQRCodeModel = [[YZHTeamDetailModel alloc] init];
    sharedQRCodeModel.title = @"群分享";
    sharedQRCodeModel.imageName = @"my_informationCell_QRCode";
    sharedQRCodeModel.cellClass = @"YZHTeamCardImageCell";
    sharedQRCodeModel.router = kYZHRouterCommunityCardQRCodeShared;
    sharedQRCodeModel.routetInfo = @{
                                     @"teamId": self.teamId ? self.teamId : NULL
                                     };
    
    YZHTeamDetailModel* memberModel = [[YZHTeamDetailModel alloc] init];
    memberModel.title = @"群成员";
    memberModel.subtitle = [NSString stringWithFormat:@"%ld",team.memberNumber];
    memberModel.cellClass = @"YZHTeamCardTextCell";
    
    YZHTeamDetailModel* chatContentModel = [[YZHTeamDetailModel alloc] init];
    chatContentModel.title = @"群聊内容";
    chatContentModel.subtitle = @"图片、名片链接等聊天记录";
    chatContentModel.cellClass = @"YZHTeamCardTextCell";
    chatContentModel.router = kYZHRouterSessionChatContent;
    //TODO: 空白展示页.
    chatContentModel.routetInfo = @{
                                    @"targetId": self.teamId,
                                    };
    // 群主设置
    YZHTeamDetailModel* publicModel = [[YZHTeamDetailModel alloc] init];
    self.publicModel = publicModel;
    self.publicModel.notInteraction = YES;
    if (self.isManage) {
        publicModel.title = @"是否公开本群";
        publicModel.isOpenStatus = !team.joinMode; //0 为公开, 1 2 都是私密
        publicModel.subtitle = team.joinMode ? @"私密" : @"公开";
        publicModel.cellClass = @"YZHTeamCardSwitchCell";
    } else {
        publicModel.title = !team.joinMode ? @"本群已公开" : @"本群未公开";
        publicModel.subtitle = !team.joinMode ? @"可加好友进群" : nil;
        publicModel.cellClass = @"YZHTeamCardTextCell";
    }

    YZHTeamDetailModel* memberInviteFriendModel = [[YZHTeamDetailModel alloc] init];
    self.memberInviteFriendModel = memberInviteFriendModel;
    memberInviteFriendModel.title = @"允许群成员添加好友进群";
    memberInviteFriendModel.isOpenStatus = team.inviteMode; //0 为群主管理员可邀请, 1 所有好友都可以邀请
    memberInviteFriendModel.subtitle = team.inviteMode ? @"允许" : @"不允许";
    memberInviteFriendModel.cellClass = @"YZHTeamCardSwitchCell";
    
    YZHTeamDetailModel* sharedModel = [[YZHTeamDetailModel alloc] init];
    self.sharedModel = sharedModel;
    sharedModel.title = @"是否可互享";
    sharedModel.isOpenStatus = teamInfoExtManage.isShareTeam;
    sharedModel.subtitle = teamInfoExtManage.isShareTeam ? @"互享": @"不可互享";
    sharedModel.cellClass = @"YZHTeamCardSwitchCell";
    
    YZHTeamDetailModel* findSharedModel = [[YZHTeamDetailModel alloc] init];
    findSharedModel.title = @"寻找互享群";
    findSharedModel.cellClass = @"YZHTeamCardTextCell";
    
    YZHTeamDetailModel* letSharedQRCodeModel = [[YZHTeamDetailModel alloc] init];
    self.letSharedQRCodeModel = letSharedQRCodeModel;
    letSharedQRCodeModel.title = @"允许向群里分享其他群名片";
    letSharedQRCodeModel.isOpenStatus = teamInfoExtManage.sendTeamCard;
    letSharedQRCodeModel.subtitle = teamInfoExtManage.sendTeamCard ? @"允许": @"不允许";
    letSharedQRCodeModel.cellClass = @"YZHTeamCardSwitchCell";
    
    YZHTeamDetailModel* noticeModel = [[YZHTeamDetailModel alloc] init];
    noticeModel.title = @"群公告";
    noticeModel.cellClass = @"YZHTeamCardTextCell";
    noticeModel.router = kYZHRouterCommunityCardTeamNotice;
    noticeModel.routetInfo = @{
                               @"isManage": @(self.isManage),
                               @"teamId": self.teamId
                               };
//    noticeModel.isOpenStatus = teamExtManage.isShareTeam;
    //群功能
    YZHTeamDetailModel* nickNameModel = [[YZHTeamDetailModel alloc] init];
    nickNameModel.title = @"群内昵称设置";
    nickNameModel.subtitle = member.nickname;
    nickNameModel.cellClass = @"YZHTeamCardTextCell";
    nickNameModel.router = kYZHRouterMyInformationSetName;
    nickNameModel.routetInfo = @{
                                     @"teamId": self.teamId ? self.teamId : NULL,
                                     kYZHRouteSegue: kYZHRouteSegueModal,
                                     kYZHRouteSegueNewNavigation: @(YES)
                                     };
    
    //下面的都是针对用户对此群设置的扩展字段信息.
    YZHTeamExtManage* teamExtManage = [YZHTeamExtManage targetTeamExtWithTeamId:_teamId targetId:userId];
    // TODO:静音字段???
    BOOL isOpen = [[[NIMSDK sharedSDK] teamManager] notifyStateForNewMsg:self.teamId];
    YZHTeamDetailModel* informModel = [[YZHTeamDetailModel alloc] init];
    self.informModel = informModel;
    informModel.title = @"群消息免打扰";
    informModel.isOpenStatus = isOpen;
    informModel.cellClass = @"YZHTeamCardSwitchCell";
    
    YZHTeamDetailModel* topModel = [[YZHTeamDetailModel alloc] init];
//    NIMSession* session = [NIMSession session:_teamId type:NIMSessionTypeTeam];
//    NIMRecentSession *recent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
//    BOOL top = [NTESSessionUtil recentSessionIsMark:recent type:NTESRecentSessionMarkTypeTop];
    BOOL top2 = teamExtManage.team_top;
    self.topModel = topModel;
    topModel.title = @"群置顶";
    topModel.isOpenStatus = top2;
    topModel.cellClass = @"YZHTeamCardSwitchCell";
    
    YZHTeamDetailModel* addFriendModel = [[YZHTeamDetailModel alloc] init];
    self.addFriendModel = addFriendModel;
    addFriendModel.title = @"允许群成员加好友";
    addFriendModel.isOpenStatus = teamExtManage.team_add_friend;
    addFriendModel.cellClass = @"YZHTeamCardSwitchCell";
    
    YZHTeamDetailModel* allowChatModel = [[YZHTeamDetailModel alloc] init];
    self.allowChatModel = allowChatModel;
    allowChatModel.title = @"允许群成员和我私聊";
    allowChatModel.isOpenStatus = teamExtManage.team_p2p_chat;
    allowChatModel.cellClass = @"YZHTeamCardSwitchCell";
    
    YZHTeamDetailModel* lockModel = [[YZHTeamDetailModel alloc] init];
    self.lockModel = lockModel;
    lockModel.title = @"群上锁";
    lockModel.titleTip = @"（需要阅读密码才能查看）";
    lockModel.isOpenStatus = teamExtManage.team_lock;
    lockModel.subtitle = lockModel.isOpenStatus ? @"上锁" : @"不上锁";
    lockModel.cellClass = @"YZHTeamCardSwitchCell";
    
    // 其他
    YZHTeamDetailModel* chatDataModel = [[YZHTeamDetailModel alloc] init];
    chatDataModel.title = @"清空聊天记录";
    chatDataModel.cellClass = @"YZHTeamCardTextCell";
    
    NSMutableArray* listArray = [[NSMutableArray alloc] init];
    NSMutableArray* teamShowArray = [[NSMutableArray alloc] init];
    NSMutableArray* managePublickArray = [[NSMutableArray alloc] init];
    NSMutableArray* manageSharedArray = [[NSMutableArray alloc] init];
    NSMutableArray* manageSharedQRCodeArray = [[NSMutableArray alloc] init];
    NSMutableArray* teamFunctionArray = [[NSMutableArray alloc] init];
    NSMutableArray* teamMoreArray = [[NSMutableArray alloc] init];
    if (_isManage) {
        // 拼装分区0 数据
        [teamShowArray addObject:sharedQRCodeModel];
        [teamShowArray addObject:memberModel];
        [teamShowArray addObject:chatContentModel];
        // 拼接群主设置数据
        [managePublickArray addObject:publicModel];
        // 非公开时,需要展示邀请模式
        if (!publicModel.isOpenStatus) {
            [managePublickArray addObject:memberInviteFriendModel];
        }
        [manageSharedArray addObject: sharedModel];
        if (sharedModel.isOpenStatus) {
            [manageSharedArray addObject:findSharedModel];
        }
        [manageSharedQRCodeArray addObject:letSharedQRCodeModel];
        [manageSharedQRCodeArray addObject:noticeModel];
        // 拼装群功能
        [teamFunctionArray addObject:nickNameModel];
        [teamFunctionArray addObject:informModel];
        [teamFunctionArray addObject:topModel];
        [teamFunctionArray addObject:addFriendModel];
        [teamFunctionArray addObject:allowChatModel];
        [teamFunctionArray addObject:lockModel];
        // 拼装其他功能
        [teamMoreArray addObject:chatDataModel];
    } else {
        [teamShowArray addObject:sharedQRCodeModel];
        [teamShowArray addObject:memberModel];
        [teamShowArray addObject:chatContentModel];
        
        // 拼接群成员查看群主设置数据
        [managePublickArray addObject:publicModel];
        [managePublickArray addObject:noticeModel];
        
        // 拼装群功能
        [teamFunctionArray addObject:nickNameModel];
        [teamFunctionArray addObject:informModel];
        [teamFunctionArray addObject:topModel];
        [teamFunctionArray addObject:addFriendModel];
        [teamFunctionArray addObject:allowChatModel];
        [teamFunctionArray addObject:lockModel];
        
        // 拼装其他功能
        [teamMoreArray addObject:chatDataModel];
    }
    
    [listArray addObject:teamShowArray];
    [listArray addObject:managePublickArray];
    [listArray addObject:manageSharedArray];
    [listArray addObject:manageSharedQRCodeArray];
    [listArray addObject:teamFunctionArray];
    [listArray addObject:teamMoreArray];
    
    self.modelList = listArray;
    self.headerModel = headerModel;
}

- (void)updata {
    
    [self configuraTeamInfos];
    // 更新群信息
    [[[NIMSDK sharedSDK] teamManager] updateTeamInfos:self.teamInfos teamId:self.teamId completion:^(NSError * _Nullable error) {
        if (!error) {
            self.updateSucceed = YES;
        } else {
            
        }
    }];
    // 更新个人对群 以及群设置
    [[[NIMSDK sharedSDK] teamManager] updateMyCustomInfo:self.teamExts inTeam:self.teamId completion:^(NSError * _Nullable error) {
        if (!error) {
            self.updateSucceed = YES;
        } else {
            
        }
    }];
    NIMTeamNotifyState state;
    if (self.informModel.isOpenStatus) {
        state = NIMTeamNotifyStateNone;
    } else {
        state = NIMTeamNotifyStateAll;
    }
    //群消息免打扰
    //YES 则是不接受任何消息提醒
    [[[NIMSDK sharedSDK] teamManager] updateNotifyState:state inTeam:self.teamId completion:^(NSError * _Nullable error) {
        if (!error) {
            self.updateSucceed = YES;
        }
    }];
    //群置顶
    NIMSession* session = [NIMSession session:self.teamId type:NIMSessionTypeTeam];
    if (self.topModel.isOpenStatus) {
        [NTESSessionUtil addRecentSessionMark:session type:NTESRecentSessionMarkTypeTop];
    } else {
        [NTESSessionUtil removeRecentSessionMark:session type:NTESRecentSessionMarkTypeTop];
    }
}

- (void)configuraTeamInfos {
    
    //TODO:
    NSString* userId = [[[NIMSDK sharedSDK] loginManager] currentAccount];
    YZHTeamExtManage* teamExt = [YZHTeamExtManage targetTeamExtWithTeamId:self.teamId targetId:userId];
    YZHTeamInfoExtManage* teamInfoExt = [[YZHTeamInfoExtManage alloc] initTeamExtWithTeamId:self.teamId];
    //互享
    teamInfoExt.isShareTeam = self.sharedModel.isOpenStatus;
    //允许群里分享其他群名片
    teamInfoExt.sendTeamCard = self.letSharedQRCodeModel.isOpenStatus;
    
    teamExt.team_add_friend = self.addFriendModel.isOpenStatus;
    teamExt.team_p2p_chat = self.allowChatModel.isOpenStatus;
    teamExt.team_lock = self.lockModel.isOpenStatus;
    teamExt.team_top = self.topModel.isOpenStatus;
    self.teamExts = [teamExt mj_JSONString];
    
    NSString* teamClientExtInfo = [teamInfoExt mj_JSONString];
    
    NSDictionary *teamInfos;
    if (self.isManage) {
        teamInfos = @{
                      @(NIMTeamUpdateTagJoinMode) : @(self.publicModel.isOpenStatus),
                      @(NIMTeamUpdateTagInviteMode): @(self.memberInviteFriendModel.isOpenStatus),
                      @(NIMTeamUpdateTagClientCustom) : teamClientExtInfo ? teamClientExtInfo : nil,
                      
                     };
    } else {
        teamInfos = @{
                      @(NIMTeamUpdateTagJoinMode) : @(self.publicModel.isOpenStatus),
                      @(NIMTeamUpdateTagInviteMode): @(self.memberInviteFriendModel.isOpenStatus),
                      };
    }
    self.teamInfos = teamInfos;
}

@end