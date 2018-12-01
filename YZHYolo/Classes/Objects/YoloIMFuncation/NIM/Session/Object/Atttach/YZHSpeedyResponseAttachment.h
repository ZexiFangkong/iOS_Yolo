//
//  YZHSpeedyResponseAttachment.h
//  YZHYolo
//
//  Created by Jersey on 2018/11/25.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YZHCustomAttachmentDefines.h"
NS_ASSUME_NONNULL_BEGIN

@interface YZHSpeedyResponseAttachment : NSObject<NIMCustomAttachment, YZHCustomAttachmentInfo>

@property (nonatomic, copy) NSString* titleText;

@property (nonatomic, copy) NSString* senderUserId;

@property (nonatomic, strong) NSString* teamNickName; //此群对应发送者昵称

@property (nonatomic, assign) BOOL isSender; // 是否为发送方

@property (nonatomic, assign) BOOL isReceive; // 已收到

@property (nonatomic, assign) BOOL isResponse;// 已回应

@property (nonatomic, assign) BOOL isHandle; // 已处理

- (instancetype)initWithTitleText:(NSString *)titleText senderUserId:(NSString *)senderUserId teamNickName:(NSString *)teamNickName;

@end

NS_ASSUME_NONNULL_END