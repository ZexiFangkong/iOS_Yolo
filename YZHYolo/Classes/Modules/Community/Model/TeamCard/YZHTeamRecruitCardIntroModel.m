//
//  YZHTeamRecruitCardIntroModel.m
//  YZHYolo
//
//  Created by Jersey on 2018/12/12.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "YZHTeamRecruitCardIntroModel.h"

@implementation YZHTeamRecruitCardIntroModel

- (instancetype)initWithTeam:(NIMTeam *)team {
    
    self = [super init];
    if (self) {
        if (team) {
            _teamId = team.teamId;
            _team = team;
            [self configuration];
            _haveTeamData = YES;
        } else {
            _haveTeamData = NO;
        }
    }
    return self;
}

- (void)configuration {
    
    YZHTeamInfoExtManage* teamInfoExtManage = [YZHTeamInfoExtManage YZH_objectWithKeyValues:_team.clientCustomInfo];
    self.teamOwner = _team.owner;
    NIMUser* teamOwner = [[[NIMSDK sharedSDK] userManager] userInfo:self.teamOwner];
    self.teamOwnerAvatarUrl = teamOwner.userInfo.avatarUrl;
    self.teamOwnerName = teamOwner.userInfo.nickName;
    
    YZHTeamHeaderModel* headerModel = [[YZHTeamHeaderModel alloc] init];
    headerModel.teamName = _team.teamName;
    headerModel.teamSynopsis = _team.intro;
    headerModel.avatarImageName = _team.avatarUrl;
    headerModel.labelArray = teamInfoExtManage.labelArray;
    headerModel.canEdit = NO;
    headerModel.viewClass = @"YZHTeamCardHeaderView";
    headerModel.teamId = _teamId;
    
    self.headerModel = headerModel;
    
    self.recruitModel = teamInfoExtManage.recruit;
    if (!self.recruitModel) {
        self.recruitModel = [[YZHTeamRecruit alloc] init];
    }
}

- (void)updataHeaderModel {
    
    NIMTeam* team = [[[NIMSDK sharedSDK] teamManager] teamById:_teamId];
    YZHTeamInfoExtManage* teamInfoExtManage = [YZHTeamInfoExtManage YZH_objectWithKeyValues:team.clientCustomInfo];
    self.headerModel.teamName = team.teamName;
    self.headerModel.teamSynopsis = team.intro;
    self.headerModel.avatarImageName = team.avatarUrl;
    self.headerModel.labelArray = teamInfoExtManage.labelArray;
    self.headerModel.canEdit = NO;
    self.headerModel.viewClass = @"YZHTeamCardHeaderView";
    self.headerModel.teamId = _teamId;
}

- (void)updataTeamOwnerData {
    
    NIMUser* teamOwner = [[[NIMSDK sharedSDK] userManager] userInfo:self.teamOwnerName];
    self.teamOwnerName = teamOwner.userInfo.nickName;
    self.teamOwnerAvatarUrl = teamOwner.userInfo.avatarUrl;
}

@end