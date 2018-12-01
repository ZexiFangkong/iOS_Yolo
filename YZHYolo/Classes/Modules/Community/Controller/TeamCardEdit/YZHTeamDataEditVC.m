//
//  YZHTeamDataEditVC.m
//  YZHYolo
//
//  Created by Jersey on 2018/11/20.
//  Copyright © 2018年 YZHChain. All rights reserved.
//

#import "YZHTeamDataEditVC.h"

#import "YZHImportBoxView.h"
#import "YZHLabelShowView.h"
#import "YZHPhotoManage.h"
#import "UIImageView+YZHImage.h"
#import "NSString+YZHTool.h"
#import "YZHProgressHUD.h"
#import "YZHTeamInfoExtManage.h"
#import "NIMKitDevice.h"
#import "NIMKitFileLocationHelper.h"
#import "NIMInputEmoticonDefine.h"
#import "UIImage+NIMKit.h"

@interface YZHTeamDataEditVC ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *teamNameTextFiled;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *updateAvatarButton;
@property (nonatomic, copy) YZHButtonExecuteBlock updataAvatarBlock;
@property (weak, nonatomic) IBOutlet UIView *teamTagView;
@property (weak, nonatomic) IBOutlet UIView *teamTagTitleView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *teamTagViewLayoutConstraint;
@property (weak, nonatomic) IBOutlet YZHLabelShowView *teamTagShowView;
@property (weak, nonatomic) IBOutlet YZHImportBoxView *synopsisView;
@property (nonatomic, copy) YZHExecuteBlock selectedLabelSaveHandle;
@property (nonatomic, strong) NSMutableArray<NSString *>* selectedLabelArray;
@property (nonatomic, copy) NSString* avatarUrl;

@end

@implementation YZHTeamDataEditVC

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

- (void)setupNavBar {
    self.navigationItem.title = @"群基本信息";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(executeCancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(executeSave:)];
}

- (void)setupView {
    
    self.view.backgroundColor = [UIColor yzh_backgroundThemeGray];
    
    NSMutableAttributedString* nameAttributedString = [[NSMutableAttributedString alloc] initWithString:@"群聊 (默认)"];
    [nameAttributedString addAttributes:@{
                                          NSForegroundColorAttributeName: [UIColor yzh_fontShallowBlack],
                                          NSFontAttributeName: [UIFont yzh_commonStyleWithFontSize:15]
                                          } range:NSMakeRange(0, 2)];
    [nameAttributedString addAttributes:@{
                                          NSForegroundColorAttributeName: [UIColor colorWithRed:125 / 255.0 green:125 / 255.0 blue:125 / 255.0 alpha:1],
                                          NSFontAttributeName: [UIFont yzh_commonStyleWithFontSize:12]
                                          } range:NSMakeRange(2, nameAttributedString.length - 2)];
    self.teamNameTextFiled.attributedPlaceholder = nameAttributedString;
    
    [self.updateAvatarButton addTarget:self action:@selector(selectedAvatar:) forControlEvents:UIControlEventTouchUpInside];
    @weakify(self)
    self.updataAvatarBlock = ^(UIButton* sender) {
        @strongify(self)
        [YZHPhotoManage presentWithViewController:self sourceType:YZHImagePickerSourceTypePhotoLibrary finishPicking:^(UIImage * _Nonnull image) {
            @strongify(self)
            [self updatePhotoToIMDataWithImage:image];
        }];
    };
    
    UIButton* tagViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tagViewButton addTarget:self action:@selector(selectedTeamTag:) forControlEvents:UIControlEventTouchUpInside];
    [self.teamTagView addSubview:tagViewButton];
    [tagViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
}

- (void)reloadView {
    
    self.teamNameTextFiled.text = self.viewModel.teamName;
    self.synopsisView.importTextView.text = self.viewModel.teamSynopsis;
    if (self.viewModel.teamName) {
        [self.avatarImageView yzh_setImageWithString:self.viewModel.teamName placeholder:@"team_createTeam_avatar_icon_normal"];
    } else {
        [self.avatarImageView setImage:[UIImage imageNamed:@"team_createTeam_avatar_icon_normal"]];
    }
}

#pragma mark - 3.Request Data

- (void)setupData {
    
    [self reloadView];
    if (self.viewModel.labelArray) {
        self.selectedLabelArray = [self.viewModel.labelArray mutableCopy];
    } else {
        self.selectedLabelArray = [[NSMutableArray alloc] init];
    }
    [self refresh];
}

#pragma mark - 4.UITableViewDataSource and UITableViewDelegate

#pragma mark - 5.Event Response

- (void)selectedAvatar:(UIButton *)sender {
    
    self.updataAvatarBlock ? self.updataAvatarBlock(sender) : NULL;
}

- (void)executeCancel:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)executeSave:(UIBarButtonItem *)sender {
    
    NSDictionary* teamNameDic;
    NSDictionary* avatarImageDic;
    NSDictionary* synopsisDic;
    NSDictionary* teamExt;
//    NSDictionary<NSNumber *,NSString *> *updateTeamInfos = [[NSMutableDictionary alloc] init];
    if (YZHIsString(self.teamNameTextFiled.text)){
        NSString* newTeamName = [self.teamNameTextFiled.text yzh_clearBeforeAndAfterblankString];
        //加入用户输入名字为空格,则只计算一位。。
        if (!YZHIsString(newTeamName)) {
            newTeamName = @" ";
        }
        if (![self.viewModel.teamName isEqualToString:newTeamName]) {
            teamNameDic = @{
                            @(NIMTeamUpdateTagName): newTeamName
                         };
        }
    }
    //群头像
    if (YZHIsString(self.avatarUrl)) {
        avatarImageDic = @{
                           @(NIMTeamUpdateTagAvatar): self.avatarUrl
                           };
    }
    if (YZHIsString(self.synopsisView.importTextView.text)) {
        NSString* newSynopsis = [self.synopsisView.importTextView.text yzh_clearBeforeAndAfterblankString];
        if (!YZHIsString(newSynopsis)) {
            newSynopsis = @" ";
        }
        if (![self.viewModel.teamSynopsis isEqualToString:newSynopsis]) {
            synopsisDic = @{
                            @(NIMTeamUpdateTagIntro):newSynopsis
                            };
        }
    }
    if (![self.selectedLabelArray isEqualToArray:self.viewModel.labelArray] ) {
        YZHTeamInfoExtManage* teamInfoExt = [[YZHTeamInfoExtManage alloc] initTeamExtWithTeamId:self.viewModel.teamId];
        teamInfoExt.labelArray = self.selectedLabelArray;
        NSString* extString = [teamInfoExt mj_JSONString];
        if (YZHIsString(extString)) {
            teamExt = @{
                        @(NIMTeamUpdateTagClientCustom): extString
                        };
        }
    }
    
    NSMutableDictionary* updateTeamInfos = [[NSMutableDictionary alloc] init];
    if (YZHIsDictionary(teamNameDic)) {
        [updateTeamInfos addEntriesFromDictionary:teamNameDic];
    }
    if (YZHIsDictionary(avatarImageDic)) {
        [updateTeamInfos addEntriesFromDictionary:avatarImageDic];
    }
    if (YZHIsDictionary(synopsisDic)) {
        [updateTeamInfos addEntriesFromDictionary:synopsisDic];
    }
    if (YZHIsDictionary(teamExt)) {
        [updateTeamInfos addEntriesFromDictionary:teamExt];
    }
    if (updateTeamInfos.allKeys.count) {
        YZHProgressHUD* hud = [YZHProgressHUD showLoadingOnView:YZHAppWindow text:nil];
        @weakify(self)
        [[[NIMSDK sharedSDK] teamManager] updateTeamInfos:updateTeamInfos teamId:self.viewModel.teamId completion:^(NSError * _Nullable error) {
            @strongify(self)
            if (!error) {
                [hud hideWithText:@"修改群信息成功"];
                self.teamDataSaveSucceedBlock ? self.teamDataSaveSucceedBlock() : NULL;
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [hud hideWithText:@"修改群信息失败,请重试"];
            }
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
 
}

- (void)selectedTeamTag:(UIButton *)sender {
    
    if (!self.selectedLabelSaveHandle) {
        @weakify(self)
        self.selectedLabelSaveHandle = ^(NSMutableArray* result) {
            // 更新已选群标签展示 View;
            @strongify(self)
            self.selectedLabelArray = result;
            [self refresh];
        };
    }
    
    [YZHRouter openURL:kYZHRouterCommunityCreateTeamTagSelected info:@{
                                                                       kYZHRouteSegue: kYZHRouteSegueModal,
                                                                       kYZHRouteSegueNewNavigation : @(YES),
                                                                       @"selectedLabelSaveHandle": self.selectedLabelSaveHandle,
                                                                       @"selectedLabelArray":self.selectedLabelArray
                                                                       }];
}

- (void)refresh {
    
    CGFloat showViewHeight =  [self.teamTagShowView refreshLabelViewWithLabelArray:self.selectedLabelArray];
    
    self.teamTagViewLayoutConstraint.constant = 80 + showViewHeight;
    
}

#pragma mark - 6.Private Methods

- (void)updatePhotoToIMDataWithImage:(UIImage* )image {
    
    UIImage *imageForAvatarUpload = [image nim_imageForAvatarUpload];
    NSString *fileName = [NIMKitFileLocationHelper genFilenameWithExt:@"jpg"];
    NSString *filePath = [[NIMKitFileLocationHelper getAppDocumentPath] stringByAppendingPathComponent:fileName];
    NSData *data = UIImageJPEGRepresentation(imageForAvatarUpload, 1.0);
    BOOL success = data && [data writeToFile:filePath atomically:YES];
    @weakify(self)
    if (success) {
        [SVProgressHUD show];
        [[NIMSDK sharedSDK].resourceManager upload:filePath progress:nil completion:^(NSString *urlString, NSError *error) {
            [SVProgressHUD dismiss];
            @strongify(self)
            if (!error && self) {
                self.avatarUrl = urlString;
                self.avatarImageView.image = image;
                [self.view makeToast:nil];
            } else {
                [self.view makeToast:@"图片上传失败，请重试"
                            duration:2
                            position:CSToastPositionCenter];
            }
        }];
    } else {
        [self.view makeToast:@"图片上传失败，请重试"
                    duration:2
                    position:CSToastPositionCenter];
    }
}
    
- (void)setupNotification {
    
}

#pragma mark - 7.GET & SET

@end