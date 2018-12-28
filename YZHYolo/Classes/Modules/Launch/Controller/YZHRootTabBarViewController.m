//
//  YZHRootTabBarViewController.m
//  YZHYolo
//
//  Created by Jersey on 2018/9/11.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "YZHRootTabBarViewController.h"
#import "YZHTabBarModel.h"
#import "YZHBaseNavigationController.h"
#import "UIColor+YZHColorStyle.h"
#import "YZHDiscoverVC.h"

NSString* const kYZHSelectedDiscoverNotifaction = @"kYZHSelectedDiscoverNotifaction";
@interface YZHRootTabBarViewController ()<UITabBarControllerDelegate>

@end

@implementation YZHRootTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- SetView

- (void)setupView{
    
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor whiteColor];
    //TODO:
    self.tabBar.backgroundImage = [UIImage imageNamed:@""];
    
    YZHTabBarItems *viewModel = [[YZHTabBarItems alloc] init];
    NSMutableArray *vcs = [[NSMutableArray alloc] init];
    for (int i=0; i<viewModel.itemsModel.count; i++) {
        YZHTabBarModel *itemModel = viewModel.itemsModel[i];
        Class clazz = NSClassFromString(itemModel.viewController);
        UIViewController *vc = [[clazz alloc] init];
        if (itemModel.hasNavigation) {
            vc = [[YZHBaseNavigationController alloc] initWithRootViewController:vc];
        }
        [vcs addObject:vc];
    }
    [self setViewControllers:vcs];
    
    for (int i=0; i < self.tabBar.items.count; i++) {
        YZHTabBarModel *itemModel = viewModel.itemsModel[i];
        UITabBarItem *tabBarItem = [self.tabBar.items objectAtIndex:i];
        tabBarItem.title = itemModel.title;
        tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
        //图片
        
        UIImage *defaultImgge = [UIImage imageNamed:itemModel.image];
        UIImage *selectedImgge = [UIImage imageNamed:itemModel.selectedImage];
        tabBarItem.image = [defaultImgge imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem.selectedImage = [selectedImgge imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //文字颜色
        [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor yzh_colorWithHexString:itemModel.color]}
                                  forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor yzh_colorWithHexString:itemModel.selectedColor]}
                                  forState:UIControlStateSelected];
        
    }
    self.selectedIndex = 0;
    self.delegate = self;
    
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if ([item.title isEqualToString:@"广场"]) {
        YZHBaseNavigationController* baseNav = [self.viewControllers objectAtIndex:3];
        YZHDiscoverVC* discover = (YZHDiscoverVC*)baseNav.viewControllers.firstObject;
        if ([discover isKindOfClass:[YZHDiscoverVC class]]) {
            [discover refreshView];
        }
        //TODO: https://www.jianshu.com/p/80939746e48c
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"clickDiscouver" object:nil];
//        }];
    }
    
}
@end
