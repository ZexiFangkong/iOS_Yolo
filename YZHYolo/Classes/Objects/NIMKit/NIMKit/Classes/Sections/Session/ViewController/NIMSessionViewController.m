//
//  NIMSessionViewController.m
//  NIMKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NIMSessionConfigurateProtocol.h"
#import "NIMKit.h"
#import "NIMMessageCellProtocol.h"
#import "NIMMessageModel.h"
#import "NIMKitUtil.h"
#import "NIMCustomLeftBarView.h"
#import "NIMBadgeView.h"
#import "UITableView+NIMScrollToBottom.h"
#import "NIMMessageMaker.h"
#import "UIView+NIM.h"
#import "NIMSessionConfigurator.h"
#import "NIMKitInfoFetchOption.h"
#import "NIMKitTitleView.h"
#import "NIMKitKeyboardInfo.h"
#import "YZHAlertManage.h"
#import "UIActionSheet+YZHBlock.h"
#import "YZHUserCardAttachment.h"
#import "YZHTeamCardAttachment.h"
#import "YZHSessionMsgConverter.h"
#import <AVFoundation/AVFoundation.h>
#import "YZHChatContentUtil.h"

@interface NIMSessionViewController ()<NIMMediaManagerDelegate,NIMInputDelegate>

@property (nonatomic,readwrite) NIMMessage *messageForMenu;

@property (nonatomic,strong)    UILabel *titleLabel;

@property (nonatomic,strong)    UILabel *subTitleLabel;

@property (nonatomic,strong)    NSIndexPath *lastVisibleIndexPathBeforeRotation;

@property (nonatomic,strong)  NIMSessionConfigurator *configurator;

@property (nonatomic, copy) void (^sharedPersonageCardHandle)(YZHUserCardAttachment*);
@property (nonatomic, copy) void (^sharedTeamCardHandle)(YZHTeamCardAttachment*);

@property (nonatomic, copy) void (^forwardPersonageCardHandle)(NSString*);
@property (nonatomic, copy) void (^forwardTeamCardHandle)(NSString*);
@property (nonatomic, strong) NIMMessage* audioMessage;

@end

@implementation NIMSessionViewController

- (instancetype)initWitRecentSession:(NIMRecentSession *)recentSession {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _recentSession = recentSession;
        _session = recentSession.session;
    }
    return self;
}

- (instancetype)initWithSession:(NIMSession *)session{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)dealloc
{
    [self removeListener];
    [[NIMKit sharedKit].robotTemplateParser clean];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏
    [self setupNav];
    //消息 tableView
    [self setupTableView];
    //输入框 inputView
    [self setupInputView];
    //会话相关逻辑配置器安装
    [self setupConfigurator];
    //添加监听
    [self addListener];
    //进入会话时，标记所有消息已读，并发送已读回执
    [self markRead];
    //更新已读位置
    [self uiCheckReceipts:nil];
}

- (void)setupNav
{
    [self setUpTitleView];
    NIMCustomLeftBarView *leftBarView = [[NIMCustomLeftBarView alloc] init];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarView];
    if (@available(iOS 11.0, *)) {
        leftBarView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    self.navigationItem.leftBarButtonItems = @[leftItem];
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)setupTableView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = NIMKit_UIColorFromRGB(0xe4e7ec);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([self.sessionConfig respondsToSelector:@selector(sessionBackgroundImage)] && [self.sessionConfig sessionBackgroundImage]) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imgView.image = [self.sessionConfig sessionBackgroundImage];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.tableView.backgroundView = imgView;
    }
    [self.view addSubview:self.tableView];
}

- (void)setupInputView
{
    if ([self shouldShowInputView])
    {
        self.sessionInputView = [[NIMInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.nim_width,0) config:self.sessionConfig];
        self.sessionInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.sessionInputView setSession:self.session];
        [self.sessionInputView setInputDelegate:self];
        [self.sessionInputView setInputActionDelegate:self];
        [self.sessionInputView refreshStatus:NIMInputStatusText];
        [self.view addSubview:_sessionInputView];
    }
}

- (void)setupConfigurator
{
    _configurator = [[NIMSessionConfigurator alloc] init];
    [_configurator setup:self];
    
    BOOL needProximityMonitor = [self needProximityMonitor];
    [[NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:needProximityMonitor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.interactor onViewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.sessionInputView endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.interactor onViewDidDisappear];
}
//销毁未读小红点, 刷新页面. //Jersey 位置矫正, TableView 和 输入框  最终调用 LayoutImpl resetLayout
- (void)viewDidLayoutSubviews
{
    [self changeLeftBarBadge:self.conversationManager.allUnreadCount];
    [self.interactor resetLayout];
}

#pragma mark - 消息收发接口
- (void)sendMessage:(NIMMessage *)message
{
    [self.interactor sendMessage:message];
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_sessionInputView endEditing:YES];
}

#pragma mark - NIMSessionConfiguratorDelegate

- (void)didFetchMessageData
{
    [self uiCheckReceipts:nil];
    [self.tableView reloadData];
    [self.tableView nim_scrollToBottom:NO];
}

- (void)didRefreshMessageData
{
    [self refreshSessionTitle:self.sessionTitle];
    [self refreshSessionSubTitle:self.sessionSubTitle];
    [self.tableView reloadData];
}

- (void)didPullUpMessageData {}

#pragma mark - 会话title
- (NSString *)sessionTitle
{
    NSString *title = @"";
    NIMSessionType type = self.session.sessionType;
    switch (type) {
        case NIMSessionTypeTeam:{
            NIMTeam *team = [[[NIMSDK sharedSDK] teamManager] teamById:self.session.sessionId];
            title = [NSString stringWithFormat:@"%@(%zd)",[team teamName],[team memberNumber]];
        }
            break;
        case NIMSessionTypeP2P:{
            title = [NIMKitUtil showNick:self.session.sessionId inSession:self.session];
        }
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)sessionSubTitle{return @"";};

#pragma mark - NIMChatManagerDelegate
//开始发送
- (void)willSendMessage:(NIMMessage *)message
{
    id<NIMSessionInteractor> interactor = self.interactor;
    
    if ([message.session isEqual:self.session]) {
        if ([interactor findMessageModel:message]) {
            [interactor updateMessage:message];
        }else{
            [interactor addMessages:@[message]];
        }
    }
}

//上传资源文件成功
- (void)uploadAttachmentSuccess:(NSString *)urlString
                     forMessage:(NIMMessage *)message
{
    //如果需要使用富文本推送，可以在这里进行 message apns payload 的设置
}

//发送结果
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session])
    {
        [self.interactor updateMessage:message];
        if (message.session.sessionType == NIMSessionTypeTeam)
        {
            //如果是群的话需要检查一下回执显示情况
            NIMMessageReceipt *receipt = [[NIMMessageReceipt alloc] initWithMessage:message];
            [self.interactor checkReceipts:@[receipt]];
        }
    }    
}

//发送进度
-(void)sendMessage:(NIMMessage *)message progress:(float)progress
{
    if ([message.session isEqual:_session]) {
        [self.interactor updateMessage:message];
    }
}

//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    if ([self shouldAddListenerForNewMsg])
    {
        NIMMessage *message = messages.firstObject;
        NIMSession *session = message.session;
        if (![session isEqual:self.session] || !messages.count)
        {
            return;
        }
        
        [self uiAddMessages:messages];
        [self.interactor markRead];
    }
}


- (void)fetchMessageAttachment:(NIMMessage *)message progress:(float)progress
{
    if ([message.session isEqual:_session])
    {
        [self.interactor updateMessage:message];
        
    }
}

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session])
    {
        NIMMessageModel *model = [self.interactor findMessageModel:message];
        //下完缩略图之后，因为比例有变化，重新刷下宽高。
        [model cleanCache];
        [self.interactor updateMessage:message];
    }
}

- (void)onRecvMessageReceipts:(NSArray<NIMMessageReceipt *> *)receipts
{
    if ([self shouldAddListenerForNewMsg])
    {
        NSMutableArray *handledReceipts = [[NSMutableArray alloc] init];
        for (NIMMessageReceipt *receipt in receipts) {
            if ([receipt.session isEqual:self.session])
            {
                [handledReceipts addObject:receipt];
            }
        }
        if (handledReceipts.count)
        {
            [self uiCheckReceipts:handledReceipts];
        }
    }
}

#pragma mark - NIMConversationManagerDelegate
- (void)messagesDeletedInSession:(NIMSession *)session{
    [self.interactor resetMessages:nil];
    [self.tableView reloadData];
}

- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}


- (void)changeUnreadCount:(NIMRecentSession *)recentSession
         totalUnreadCount:(NSInteger)totalUnreadCount{
    if ([recentSession.session isEqual:self.session]) {
        return;
    }
    [self changeLeftBarBadge:totalUnreadCount];
}

#pragma mark - NIMMediaManagerDelegate
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if (!filePath || error) {
        _sessionInputView.recording = NO;
        [self onRecordFailed:error];
    }
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error {
    if(!error) {
        if ([self recordFileCanBeSend:filePath]) {
            [self sendMessage:[NIMMessageMaker msgWithAudio:filePath]];
        }else{
            [self showRecordFileNotSendReason];
        }
    } else {
        [self onRecordFailed:error];
    }
    _sessionInputView.recording = NO;
}

- (void)recordAudioDidCancelled {
    _sessionInputView.recording = NO;
}

- (void)recordAudioProgress:(NSTimeInterval)currentTime {
    [_sessionInputView updateAudioRecordTime:currentTime];
}

- (void)recordAudioInterruptionBegin {
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

#pragma mark - 录音相关接口
#pragma mark - 录音事件

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    NSURL    *URL = [NSURL fileURLWithPath:filepath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:URL options:nil];
    CMTime time = urlAsset.duration;
    CGFloat mediaLength = CMTimeGetSeconds(time);
    return mediaLength > 1;
}

- (void)onRecordFailed:(NSError *)error
{
    [self.view makeToast:@"录音失败" duration:2 position:CSToastPositionCenter];
}

- (void)showRecordFileNotSendReason
{
    [self.view makeToast:@"录音时间太短" duration:0.2f position:CSToastPositionCenter];
}

#pragma mark - NIMInputDelegate

- (void)didChangeInputHeight:(CGFloat)inputHeight
{
    [self.interactor changeLayout:inputHeight];
}

#pragma mark - NIMInputActionDelegate
- (BOOL)onTapMediaItem:(NIMMediaItem *)item{
    SEL sel = item.selctor;
    BOOL handled = sel && [self respondsToSelector:sel];
    if (handled) {
        NIMKit_SuppressPerformSelectorLeakWarning([self performSelector:sel withObject:item]);
        handled = YES;
    }
    return handled;
}

- (void)onTextChanged:(id)sender{}

- (void)onSendText:(NSString *)text atUsers:(NSArray *)atUsers
{
    NSMutableArray *users = [NSMutableArray arrayWithArray:atUsers];
    if (self.session.sessionType == NIMSessionTypeP2P)
    {
        [users addObject:self.session.sessionId];
    }
    NSString *robotsToSend = [self robotsToSend:users];
    
    __block NIMMessage *message = nil;
    if (robotsToSend.length)
    {
        message = [NIMMessageMaker msgWithRobotQuery:text toRobot:robotsToSend];
    }
    else
    {
        message = [NIMMessageMaker msgWithText:text];
    }
    
    if (atUsers.count)
    {
        NIMMessageApnsMemberOption *apnsOption = [[NIMMessageApnsMemberOption alloc] init];
        apnsOption.userIds = atUsers;
        apnsOption.forcePush = YES;
        
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = self.session;
        
        NSString *me = [[NIMKit sharedKit].provider infoByUser:[NIMSDK sharedSDK].loginManager.currentAccount option:option].showName;
        apnsOption.apnsContent = [NSString stringWithFormat:@"%@在群里@了你",me];
        message.apnsMemberOption = apnsOption;
    } else {
        [YZHChatContentUtil checkoutContentContentTeamId:text completion:^(NIMTeam * _Nonnull team) {
            if (team) {
                YZHTeamCardAttachment* teamCardAttachment = [[YZHTeamCardAttachment alloc] init];
                teamCardAttachment.groupName = team.teamName;
                teamCardAttachment.groupID = team.teamId;
                teamCardAttachment.groupSynopsis = [YZHChatContentUtil createTeamURLWithTeamId:team.teamId];
                teamCardAttachment.groupUrl = team.intro;
                teamCardAttachment.avatarUrl = team.avatarUrl ? team.avatarUrl : @"team_cell_photoImage_default";
                message = [YZHSessionMsgConverter msgWithTeamCard:teamCardAttachment];
                [self sendMessage:message];
            } else {
                [self sendMessage:message];
            }
        }];
    }
}

- (NSString *)robotsToSend:(NSArray *)atUsers
{
    for (NSString *userId in atUsers)
    {
        if ([[NIMSDK sharedSDK].robotManager isValidRobot:userId])
        {
            return userId;
        }
    }
    return nil;
}


- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId{}

- (void)onCancelRecording
{
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

- (void)onStopRecording
{
    [[NIMSDK sharedSDK].mediaManager stopRecord];
}

- (void)onStartRecording
{
    _sessionInputView.recording = YES;
    
    NIMAudioType type = [self recordAudioType];
    NSTimeInterval duration = [NIMKit sharedKit].config.recordMaxDuration;
    
    [[NIMSDK sharedSDK].mediaManager addDelegate:self];
    
    [[NIMSDK sharedSDK].mediaManager record:type
                                     duration:duration];
}

#pragma mark - NIMMessageCellDelegate
- (BOOL)onTapCell:(NIMKitEvent *)event{
    BOOL handle = NO;
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapAudio])
    {
        [self.interactor mediaAudioPressed:event.messageModel];
        handle = YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapRobotBlock]) {
        NSDictionary *param = event.data;
        NIMMessage *message = [NIMMessageMaker msgWithRobotSelect:param[@"text"] target:param[@"target"] params:param[@"param"] toRobot:param[@"robotId"]];
        [self sendMessage:message];
        handle = YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapRobotContinueSession]) {
        NIMRobotObject *robotObject = (NIMRobotObject *)event.messageModel.message.messageObject;
        NIMRobot *robot = [[NIMSDK sharedSDK].robotManager robotInfo:robotObject.robotId];
        NSString *text = [NSString stringWithFormat:@"%@%@%@",NIMInputAtStartChar,robot.nickname,NIMInputAtEndChar];

        NIMInputAtItem *item = [[NIMInputAtItem alloc] init];
        item.uid  = robot.userId;
        item.name = robot.nickname;
        [self.sessionInputView.atCache addAtItem:item];

        [self.sessionInputView.toolBar insertText:text];

        handle = YES;
    }

    return handle;
}

- (void)onRetryMessage:(NIMMessage *)message
{
    if (message.isReceivedMsg) {
        [[[NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message
                                                           error:nil];
    }else{
        [[[NIMSDK sharedSDK] chatManager] resendMessage:message
                                                  error:nil];
    }
}

- (BOOL)onLongPressCell:(NIMMessage *)message
                 inView:(UIView *)view
{
    BOOL handle = NO;
    NSArray *items = [self menusItems:message];
    if ([items count] && [self becomeFirstResponder]) {
        UIMenuController *controller = [UIMenuController sharedMenuController];
        controller.menuItems = items;
        _messageForMenu = message;
        [controller setTargetRect:view.bounds inView:view];
        [controller setMenuVisible:YES animated:YES];
        handle = YES;
    }
    return handle;
}

- (BOOL)disableAudioPlayedStatusIcon:(NIMMessage *)message
{
    BOOL disable = NO;
    if ([self.sessionConfig respondsToSelector:@selector(disableAudioPlayedStatusIcon)])
    {
        disable = [self.sessionConfig disableAudioPlayedStatusIcon];
    }
    return disable;
}

#pragma mark - 配置项
- (id<NIMSessionConfig>)sessionConfig
{
    return nil; //使用默认配置
}

#pragma mark - 配置项列表
//是否需要监听新消息通知 : 某些场景不需要监听新消息，如浏览服务器消息历史界面
- (BOOL)shouldAddListenerForNewMsg
{
    BOOL should = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableReceiveNewMessages)]) {
        should = ![self.sessionConfig disableReceiveNewMessages];
    }
    return should;
}

//是否需要显示输入框 : 某些场景不需要显示输入框，如使用 3D touch 的场景预览会话界面内容
- (BOOL)shouldShowInputView
{
    BOOL should = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableInputView)]) {
        should = ![self.sessionConfig disableInputView];
    }
    return should;
}

//当前录音格式 : NIMSDK 支持 aac 和 amr 两种格式
- (NIMAudioType)recordAudioType
{
    NIMAudioType type = NIMAudioTypeAAC;
    if ([self.sessionConfig respondsToSelector:@selector(recordType)]) {
        type = [self.sessionConfig recordType];
    }
    return type;
}

//是否需要监听感应器事件
- (BOOL)needProximityMonitor
{
    BOOL needProximityMonitor = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableProximityMonitor)]) {
        needProximityMonitor = !self.sessionConfig.disableProximityMonitor;
    }
    return needProximityMonitor;
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    
    BOOL copyText = NO;
    if (message.messageType == NIMMessageTypeText)
    {
        copyText = YES;
    }
    if (message.messageType == NIMMessageTypeRobot)
    {
        NIMRobotObject *robotObject = (NIMRobotObject *)message.messageObject;
        copyText = !robotObject.isFromRobot;
    }
    if (message.messageType == NIMMessageTypeAudio) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"听筒播放"
                                                    action:@selector(mutePlayAudio:)]];
        self.audioMessage = message;
        
    }
    if (copyText) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                action:@selector(copyText:)]];
    }
    if (message.messageType == NIMMessageTypeCustom) {
        NIMCustomObject *customObject = (NIMCustomObject*)message.messageObject;
        if ([customObject.attachment isKindOfClass:NSClassFromString(@"YZHUserCardAttachment")] || [customObject.attachment isKindOfClass:NSClassFromString(@"YZHTeamCardAttachment")]) {
            [items addObject:[[UIMenuItem alloc] initWithTitle:@"转发"
                                                        action:@selector(forwardMessage:)]];
        }
    }
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                action:@selector(deleteMsg:)]];
    return items;
    
}

- (NIMMessage *)messageForMenu
{
    return _messageForMenu;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *items = [[UIMenuController sharedMenuController] menuItems];
    for (UIMenuItem *item in items) {
        if (action == [item action]){
            return YES;
        }
    }
    return NO;
}
//JerseyYolo: 听筒播放
- (void)mutePlayAudio:(id)sender {
    
    NIMMessageModel* audioModel = [[NIMMessageModel alloc] init];
    audioModel.message = self.audioMessage;
    [self.interactor mediaAudioTelephonePressed:audioModel];
}

- (void)copyText:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    if (message.text.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:message.text];
    }
}
//转发事件
- (void)forwardMessage:(id)sender
{
    [YZHAlertManage showAlertMessage:@"暂时不支持此功能"];
    return;
    NIMMessage *message = [self messageForMenu];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择会话类型" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"个人",@"群组", nil];
    @weakify(self)
    message.setting.teamReceiptEnabled = NO;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                @strongify(self)
                self.forwardPersonageCardHandle = ^(NSString *userId) {
                    @strongify(self)
                    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
                    [self forwardMessage:message toSession:session];
                };
                [YZHRouter openURL:kYZHRouterSessionSharedCard info:@{
                                                                      @"forwardType": @(0),
                                                                      @"sharedType": @(0),                 kYZHRouteSegue: kYZHRouteSegueModal,
                                                                      kYZHRouteSegueNewNavigation: @(YES),
                                                                      @"forwardMessageToUserBlock": self.forwardPersonageCardHandle,
                                                                      @"isForward": @(YES)
                                                                      }];
                
            }
                break;
            case 1:{
                @strongify(self)
                self.forwardTeamCardHandle = ^(NSString *teamId) {
                    @strongify(self)
                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                    [self forwardMessage:message toSession:session];
                };
                [YZHRouter openURL:kYZHRouterSessionSharedCard info:@{
                                                                      @"forwardType": @(1),
                                                    @"sharedType": @(1),               kYZHRouteSegue: kYZHRouteSegueModal,
                                                                      kYZHRouteSegueNewNavigation: @(YES),
                                                                      @"forwardMessageToTeamBlock": self.forwardTeamCardHandle,@"isForward": @(YES)
                                                                      }];
            }
                break;
            case 2:
                break;
            default:
                break;
        }
    }];
}

- (void)deleteMsg:(id)sender
{
    NIMMessage *message    = [self messageForMenu];
    [self uiDeleteMessage:message];
    [self.conversationManager deleteMessage:message];
}

- (void)menuDidHide:(NSNotification *)notification
{
    [UIMenuController sharedMenuController].menuItems = nil;
}

- (void)forwardMessage:(NIMMessage *)message toSession:(NIMSession *)session
{
    NSString *name;
    if (session.sessionType == NIMSessionTypeP2P)
    {
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = session;
        name = [[NIMKit sharedKit] infoByUser:session.sessionId option:option].showName;
    }
    else
    {
        name = [[NIMKit sharedKit] infoByTeam:session.sessionId option:nil].showName;
    }
    __weak typeof(self) weakSelf = self;
    [YZHAlertManage showAlertTitle:@"温馨提示" message:[NSString stringWithFormat:@"确认转发给 %@ ?",name] actionButtons:@[@"取消",@"确认"] actionHandler:^(UIAlertController *alertController, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[NIMSDK sharedSDK].chatManager forwardMessage:message toSession:session error:nil];
            [weakSelf.view makeToast:@"已发送" duration:2.0 position:CSToastPositionCenter];
        }
    }];
    
}



#pragma mark - 操作接口
- (void)uiAddMessages:(NSArray *)messages
{
    [self.interactor addMessages:messages];
}

- (void)uiInsertMessages:(NSArray *)messages
{
    [self.interactor insertMessages:messages];
}

- (NIMMessageModel *)uiDeleteMessage:(NIMMessage *)message{
    NIMMessageModel *model = [self.interactor deleteMessage:message];
    if (model.shouldShowReadLabel && model.message.session.sessionType == NIMSessionTypeP2P)
    {
        [self uiCheckReceipts:nil];
    }
    return model;
}

- (void)uiUpdateMessage:(NIMMessage *)message{
    [self.interactor updateMessage:message];
}

- (void)uiCheckReceipts:(NSArray<NIMMessageReceipt *> *)receipts
{
    [self.interactor checkReceipts:receipts];
}

- (NSInteger)uiReadUnreadMessage:(NSInteger)number {
    
    // 20 为一页
    NSInteger messageCount = (number / 20 + 1) * 20;
    NSInteger count = number - 20;
//    [self.interactor resetLayoutNumber:messageCount];
    //滚动到指定条数.
    [self.interactor resetLayoutNumber:count];
    
    return messageCount;
}

#pragma mark - NIMMeidaButton
- (void)onTapMediaItemPicture:(NIMMediaItem *)item
{
    [self.interactor mediaPicturePressed];
}

- (void)onTapMediaItemShoot:(NIMMediaItem *)item
{
    [self.interactor mediaShootPressed];
}

- (void)onTapMediaItemLocation:(NIMMediaItem *)item
{
    [self.interactor mediaLocationPressed];
}

// 联系人
- (void)onTapMediaItemContact:(NIMMediaItem *)item {
    
    [YZHRouter openURL:kYZHRouterSessionSharedCard info:@{
                                                          @"sharedType": @(1),
                                                          kYZHRouteSegue: kYZHRouteSegueModal,
                                                          kYZHRouteSegueNewNavigation: @(YES),
                                                          @"sharedPersonageCardBlock": self.sharedPersonageCardHandle
                                                          }];
}
// 我的社群
- (void)onTapMediaItemMyGroup:(NIMMediaItem *)item {
    // 弹出联系人页面
    [YZHRouter openURL:kYZHRouterSessionSharedCard info:@{
                                                          @"sharedType": @(2),
                                                          kYZHRouteSegue: kYZHRouteSegueModal,
                                                          kYZHRouteSegueNewNavigation: @(YES),
                                                          @"sharedTeamCardBlock": self.sharedTeamCardHandle
                                                          }];
}


#pragma mark - 旋转处理 (iOS8 or above)
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.lastVisibleIndexPathBeforeRotation = [self.tableView indexPathsForVisibleRows].lastObject;
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.view.window) {
        __weak typeof(self) wself = self;
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
         {
             [[NIMSDK sharedSDK].mediaManager cancelRecord];
             [wself.interactor cleanCache];
             [wself.sessionInputView reset];
             [wself.tableView reloadData];
             [wself.tableView scrollToRowAtIndexPath:wself.lastVisibleIndexPathBeforeRotation atScrollPosition:UITableViewScrollPositionBottom animated:NO];
         } completion:nil];
    }
}


#pragma mark - 标记已读
- (void)markRead
{
    [self.interactor markRead];
}


#pragma mark - Private

- (void)addListener
{
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
}

- (void)removeListener
{
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}

- (void)changeLeftBarBadge:(NSInteger)unreadCount
{
    NIMCustomLeftBarView *leftBarView = (NIMCustomLeftBarView *)self.navigationItem.leftBarButtonItem.customView;
    leftBarView.badgeView.badgeValue = @(unreadCount).stringValue;
    leftBarView.badgeView.hidden = !unreadCount;
}


- (id<NIMConversationManager>)conversationManager{
    switch (self.session.sessionType) {
        case NIMSessionTypeChatroom:
            return nil;
            break;
        case NIMSessionTypeP2P:
        case NIMSessionTypeTeam:
        default:
            return [NIMSDK sharedSDK].conversationManager;
    }
}


- (void)setUpTitleView
{
    NIMKitTitleView *titleView = (NIMKitTitleView *)self.navigationItem.titleView;
    if (!titleView || ![titleView isKindOfClass:[NIMKitTitleView class]])
    {
        titleView = [[NIMKitTitleView alloc] initWithFrame:CGRectZero];
        self.navigationItem.titleView = titleView;
        
        titleView.titleLabel.text = self.sessionTitle;
        titleView.subtitleLabel.text = self.sessionSubTitle;
        
        self.titleLabel    = titleView.titleLabel;
        self.subTitleLabel = titleView.subtitleLabel;
    }

    [titleView sizeToFit];
}

- (void)refreshSessionTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self setUpTitleView];
}


- (void)refreshSessionSubTitle:(NSString *)title
{
    self.subTitleLabel.text = title;
    [self setUpTitleView];
}

#pragma GET -- SET

- (void (^)(YZHUserCardAttachment *))sharedPersonageCardHandle {
    
    if (!_sharedPersonageCardHandle) {
        @weakify(self)
        _sharedPersonageCardHandle = ^(YZHUserCardAttachment *userCard) {
            @strongify(self)
            [self sendMessage:[YZHSessionMsgConverter msgWithUserCard:userCard]];
        };
    }
    return _sharedPersonageCardHandle;
}

- (void (^)(YZHTeamCardAttachment *))sharedTeamCardHandle {
    
    if (!_sharedTeamCardHandle) {
        @weakify(self)
        _sharedTeamCardHandle = ^(YZHTeamCardAttachment *teamCard) {
            @strongify(self)
            [self sendMessage:[YZHSessionMsgConverter msgWithTeamCard:teamCard]];
        };
    }
    return _sharedTeamCardHandle;
}

@end

