//
//  YZHAddBookDetailsVC.h
//  YZHYolo
//
//  Created by Jersey on 2018/9/28.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "YZHBaseViewController.h"

#import "YZHAddBookDetailsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHAddBookDetailsVC : YZHBaseViewController

@property (nonatomic, copy) NSString* userId;
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, assign) BOOL isTeam;
@property (nonatomic, copy) NSString* teamId;
@property (nonatomic, strong) YZHAddBookDetailsModel* userDetailsModel;

@end

NS_ASSUME_NONNULL_END
