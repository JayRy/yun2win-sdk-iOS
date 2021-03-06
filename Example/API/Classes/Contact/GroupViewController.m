//
//  GroupViewController.m
//  API
//
//  Created by QS on 16/3/24.
//  Copyright © 2016年 SayGeronimo. All rights reserved.
//

#import "GroupViewController.h"
#import "SessionMembersViewController.h"
#import "SessionsInfoChangedViewController.h"
#import "SettingTableViewUserCell.h"
#import "SettingTableViewCellModel.h"

@interface GroupViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) Y2WSession *session;

@property (nonatomic, retain) NSArray *sections;

@end


@implementation GroupViewController

- (instancetype)initWithSesstion:(Y2WSession *)session {

    if (self = [super init]) {
        self.session = session;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"DAEBEB"];
    [self setUpNavItem];
    [self.view addSubview:self.tableView];
    
    
    [self reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
    self.tableView.top = self.self.navigationController.navigationBar.height;
    self.tableView.height = self.view.height - 70 - self.tableView.top;
}


- (void)setUpNavItem {
    
    self.navigationItem.title = @"群信息";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_返回"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}






#pragma mark - ———— Response ———— -

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSessionMembers {
    SessionMembersViewController *sessionMembersVC = [[SessionMembersViewController alloc] initWithSessionMembers:self.session.members];
    [self pushViewController:sessionMembersVC];
}

- (void)clickSessionsName
{
    NSLog(@"sessionName");
    SessionsInfoChangedViewController *infoChanged = [[SessionsInfoChangedViewController alloc]initWithUserSession:self.session changedType:@"1"];
    [self pushViewController:infoChanged];
}

- (void)clickSessionsDescription
{
    NSLog(@"SessionsDescription");
    SessionsInfoChangedViewController *infoChanged = [[SessionsInfoChangedViewController alloc]init];
    [self pushViewController:infoChanged];
}

- (IBAction)quitSession:(id)sender {
    
    Y2WSessionMember *sessionMember = [self.session.members getMemberWithUserId:self.session.sessions.user.userId];

    // 把自己移除群
    [self.navigationItem startAnimating];
    [self.session.members.remote deleteSessionMember:sessionMember success:^{
        [self.navigationItem stopAnimating];
        
        // 删除用户会话
        Y2WUserConversations *conversations = self.session.sessions.user.userConversations;
        Y2WUserConversation *conversation = [conversations getUserConversationWithTargetId:self.session.sessionId type:self.session.type];
        [self.session.sessions.user.userConversations.remote deleteUserConversation:conversation success:^{
            
            [UIAlertView showTitle:nil message:@"成功退出此群"];
            [self.navigationController popToRootViewControllerAnimated:YES];

        } failure:^(NSError *error) {
            [UIAlertView showTitle:nil message:[[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]];
        }];
        
    } failure:^(NSError *error) {
        [self.navigationItem stopAnimating];
        [UIAlertView showTitle:nil message:[[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding]];
    }];
}





#pragma mark - ———— UITableViewDataSource ———— -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.sections[section];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCellModel *model = self.sections[indexPath.section][indexPath.row];
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(model.cellClass)];
    
    [cell relodData:model tableView:tableView];
    
    return cell;
}


#pragma mark - ———— UITableViewDelegate ———— -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCellModel *model = self.sections[indexPath.section][indexPath.row];
    return model.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingTableViewCellModel *model = self.sections[indexPath.section][indexPath.row];
    
    if ([self respondsToSelector:model.cellAction]) {
        [self y2w_performSelector:model.cellAction];
    }
}




- (void)reloadData {
    NSMutableArray *sectons = [NSMutableArray array];
    
    SettingTableViewCellModel *sessionInfo = [[SettingTableViewCellModel alloc] init];
    sessionInfo.title = self.session.name;
    sessionInfo.detailTitle = [@"群号 : " stringByAppendingString:self.session.sessionId];
    sessionInfo.uid = self.session.sessionId;
    sessionInfo.avatarUrl = self.session.avatarUrl;
    sessionInfo.image = [UIImage imageNamed:@"默认群头像"];
    sessionInfo.cellClass = [SettingTableViewUserCell class];
    sessionInfo.rowHeight = 80;
    sessionInfo.showAccessory = YES;
    
    SettingTableViewCellModel *member = [[SettingTableViewCellModel alloc] init];
    member.title = @"群成员";
    member.detailTitle = [NSString stringWithFormat:@"(%@人)",@([self.session.members getMembers].count)];
    member.cellClass = [SettingTableViewCell class];
    member.cellAction = @selector(clickSessionMembers);
    member.rowHeight = 50;
    member.showAccessory = YES;
    [sectons addObject:@[sessionInfo,member]];
    
    SettingTableViewCellModel *changePsw = [[SettingTableViewCellModel alloc] init];
    changePsw.title = @"群名称";
    changePsw.detailTitle = self.session.name;
    changePsw.cellClass = [SettingTableViewCell class];
    changePsw.cellAction = @selector(clickSessionsName);
    changePsw.rowHeight = 50;
    changePsw.showAccessory = YES;
    [sectons addObject:@[changePsw]];
    
    SettingTableViewCellModel *about = [[SettingTableViewCellModel alloc] init];
    about.title = @"群简介";
    about.cellClass = [SettingTableViewCell class];
    about.cellAction = @selector(clickSessionsDescription);
    about.rowHeight = 50;
    about.showAccessory = YES;
    [sectons addObject:@[about]];
    
    
    self.sections = sectons;
    
    [self.tableView reloadData];
}





#pragma mark - ———— getter ———— -

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"DAEBEB"];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.sectionHeaderHeight = 20;
        _tableView.sectionFooterHeight = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[SettingTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SettingTableViewCell class])];
        [_tableView registerClass:[SettingTableViewUserCell class] forCellReuseIdentifier:NSStringFromClass([SettingTableViewUserCell class])];
    }
    return _tableView;
}

@end
