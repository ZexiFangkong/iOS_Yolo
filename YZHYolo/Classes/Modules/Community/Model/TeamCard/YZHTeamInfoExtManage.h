//
//  YZHTeamInfoExtManage.h
//  YZHYolo
//
//  Created by Jersey on 2018/11/19.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZHTeamRecruit : NSObject

@property (nonatomic, assign) BOOL isValid;
@property (nonatomic, copy) NSString* sendTime;
@property (nonatomic, copy) NSString* content;

- (instancetype)initWithContent:(NSString *)content;

@end

// 本群组的扩展字段
@interface YZHTeamInfoExtManage : NSObject

@property (nonatomic, strong) NIMTeamMember* teamMember;
@property (nonatomic, assign) BOOL sendTeamCard; //允许发送群名片
@property (nonatomic, assign) BOOL isShareTeam;  //是否开启共享
@property (nonatomic, copy) NSString* addAndChat; //是否允许群成员相互聊天 // 由于在后面版本添加的原因, 所以使用 NSString. 默认 true
@property (nonatomic, copy) NSArray<NSString* >* labelArray;
@property (nonatomic, copy) NSString* function;
@property (nonatomic, copy) NSString* teamId; //
@property (nonatomic, strong) YZHTeamRecruit* recruit;

- (instancetype)initTeamExtWithTeamId:(NSString *)teamId;
- (instancetype)initCreatTeamWithTeamLabel:(NSArray* _Nullable)teamLabel recruit:(YZHTeamRecruit* _Nullable)recruit;

@end

NS_ASSUME_NONNULL_END
