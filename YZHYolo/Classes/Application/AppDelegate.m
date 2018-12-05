//
//  AppDelegate.m
//  YZHYolo
//
//  Created by Jersey on 2018/9/10.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "AppDelegate.h"
#import "YZHLaunchViewController.h"
#import "YZHRootTabBarViewController.h"
#import "YZHCellLayoutConfign.h"
#import "YZHCustomAttachmentDecoder.h"
#import "NTESNotificationCenter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //云信配置
    [self setupNIMSDK];
    [self setupServices];
    
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[YZHLaunchViewController alloc] init];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -- IM Configuration

- (void)setupServices
{
//    [[NTESLogManager sharedManager] start];
    [[NTESNotificationCenter sharedCenter] start];
//    [[NTESSubscribeManager sharedManager] start];
//    [[NTESRedPacketManager sharedManager] start];
}

- (void)setupNIMSDK {
    
    // 初始化云信 NIMSDK  TODO: Packaging
    //   云信45c6af3c98409b18a84451215d0bdd6e, d62461f3a67a1f9eb1d8604b9ebea576 测试   e974623a3785de54fcdc3df292077058 生产
    NSString *appKey        = @"e974623a3785de54fcdc3df292077058";
    NIMSDKOption *option    = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername      = nil;
    option.pkCername        = nil;
    [[NIMSDK sharedSDK] registerWithOption:option];
    
    //注册自定义消息的解析器
    [NIMCustomObject registerCustomDecoder:[YZHCustomAttachmentDecoder new]];
    
    //注册 NIMKit 自定义排版配置
    [[NIMKit sharedKit] registerLayoutConfig:[YZHCellLayoutConfign new]];
    //定制 UI 配置器
    NIMKitConfig* config = [[NIMKitConfig alloc] init];
    config.avatarType = NIMKitAvatarTypeRadiusCorner;
    [NIMKit sharedKit].config = config;
}

@end
