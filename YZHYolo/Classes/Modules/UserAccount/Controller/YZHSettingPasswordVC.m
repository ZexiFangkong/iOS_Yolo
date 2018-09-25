//
//  YZHSettingPasswordVC.m
//  YZHYolo
//
//  Created by Jersey on 2018/9/18.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "YZHSettingPasswordVC.h"

#import "YZHSettingPasswordView.h"
@interface YZHSettingPasswordVC ()<UIGestureRecognizerDelegate>

@property(nonatomic, strong)YZHSettingPasswordView* settingPasswordView;

@end

@implementation YZHSettingPasswordVC

#pragma mark - 1.View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.设置导航栏
    [self setupNavBar];
    //2.设置view
    [self setupView];
    //3.请求数据
    [self setupData];
    //4.设置通知
    [self setupNotification];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - 2.SettingView and Style

- (void)setupNavBar
{
    self.navigationItem.title = @"设置密码";
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.hideNavigationBar = YES;
}

- (void)setupView
{
    self.settingPasswordView = [YZHSettingPasswordView yzh_viewWithFrame:self.view.bounds];
    if (self.hasFindPassword) {
        self.settingPasswordView.navigationTitleLaebl.text = @"忘记密码";
        self.settingPasswordView.tileTextLabel.text = @"设置新密码";
        [self.settingPasswordView.confirmButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.settingPasswordView.confirmButton setTitle:@"完成" forState:UIControlStateDisabled];
    }
    
    [self.view addSubview:self.settingPasswordView];
    
    [self.settingPasswordView.passwordTextField becomeFirstResponder];
}

- (void)reloadView
{
    
}

#pragma mark - 3.Request Data

- (void)setupData
{
    
}

#pragma mark - 4.UITableViewDataSource and UITableViewDelegaten

#pragma mark - 5.Event Response

#pragma mark - 6.Private Methods

- (void)setupNotification
{
    
}

#pragma mark - 7.GET & SET
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
