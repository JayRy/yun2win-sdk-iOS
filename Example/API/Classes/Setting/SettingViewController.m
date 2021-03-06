//
//  SettingViewController.m
//  API
//
//  Created by ShingHo on 16/1/19.
//  Copyright © 2016年 SayGeronimo. All rights reserved.
//

#import "MainViewController.h"
#import "SettingViewController.h"
#import "SettingTableViewUserCell.h"
#import "SettingTableViewCellModel.h"

#import "GroupVideoCommunicationViewController.h"
#import <Y2W_RTC_SDK/Y2WRTCManager.h>
#import "HttpRequest.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, strong) NSArray *data;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavItem];
    [self.view addSubview:self.tableView];
    
    [self reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (void)setUpNavItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"导航栏_logo"] style:UIBarButtonItemStylePlain target:nil action:nil];
}




#pragma mark - ———— UITableViewDataSource ———— -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.data[section];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCellModel *model = self.data[indexPath.section][indexPath.row];
    SettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(model.cellClass)];
    
    [cell relodData:model tableView:tableView];
    
    return cell;
}


#pragma mark - ———— UITableViewDelegate ———— -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCellModel *model = self.data[indexPath.section][indexPath.row];
    return model.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingTableViewCellModel *model = self.data[indexPath.section][indexPath.row];
    
    if ([self respondsToSelector:model.cellAction]) {
        [self y2w_performSelector:model.cellAction];
    }
}



#pragma mark - ———— Response ———— -

- (void)clickUserInfo {
    NSLog(@"用户信息");
    RLMResults *user = [UserBase allObjects];
    RLMResults *contact = [ContactBase allObjects];
    RLMResults *userconversation = [UserConversationBase allObjects];
    NSLog(@"UserBase : %@\nContactBase : %@\nUserConversationBase : %@",user,contact,userconversation);
}

- (void)clickChangePassword {
    NSLog(@"改密码");
    
    [HttpRequest GETWithURL:@"http://192.168.0.109:8080/get" parameters:nil success:^(id data) {
       
        Y2WRTCManager *manager = [[Y2WRTCManager alloc] init];
        manager.channelId = data[@"id"];
        manager.memberId = [Y2WUsers getInstance].getCurrentUser.userId; //uid
        manager.token = [Y2WUsers getInstance].getCurrentUser.token; //token
        [manager getChannel:^(NSError *error, Y2WRTCChannel *channel) {
            
            if (error) {
                // 加入失败，返回错误
                return;
            }
            // 使用channel对象管理连接
            
            //            if (self.model.) {
            
            //            }
            AVCallModel *tempModel = [[AVCallModel alloc]init];
            GroupVideoCommunicationViewController *communication = [[GroupVideoCommunicationViewController alloc]initWithAVCallModel:tempModel withChannel:channel];
            [self presentViewController:communication animated:YES completion:nil];
            
            
            //            [self.presentingViewController presentViewController:communication animated:YES completion:nil];
            //
            //            [self dismissViewControllerAnimated:YES completion:^{
            //
            //            }];
            
            
        }];
    
    } failure:^(NSError *error) {
        NSLog(@"error : %@",error);
    }];

    
}


- (void)clickAbout {
    NSLog(@"关于");
}

- (void)clickLogout {
    NSLog(@"退出");
    [[IMClient shareY2WIMClient] disconnect];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    LoginViewController * lvc = [[LoginViewController alloc]init];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:appDelegate.window cache:YES];
    appDelegate.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:lvc];
    
    [UIView commitAnimations];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}



- (void)reloadData {
    NSMutableArray *sectons = [NSMutableArray array];
    
    Y2WCurrentUser *user = [Y2WUsers getInstance].getCurrentUser;
    
    SettingTableViewCellModel *userInfo = [[SettingTableViewCellModel alloc] init];
    userInfo.title = user.name;
    userInfo.detailTitle = [@"账号 : " stringByAppendingString:user.account];
    userInfo.uid = user.userId;
    userInfo.avatarUrl = user.avatarUrl;
    userInfo.image = [UIImage imageNamed:@"Contact"];
    userInfo.cellClass = [SettingTableViewUserCell class];
    userInfo.cellAction = @selector(clickUserInfo);
    userInfo.rowHeight = 80;
    userInfo.showAccessory = YES;
    [sectons addObject:@[userInfo]];
    
    SettingTableViewCellModel *changePsw = [[SettingTableViewCellModel alloc] init];
    changePsw.title = @"修改密码";
    changePsw.cellClass = [SettingTableViewCell class];
    changePsw.cellAction = @selector(clickChangePassword);
    changePsw.rowHeight = 50;
    changePsw.showAccessory = YES;
    [sectons addObject:@[changePsw]];
    
    SettingTableViewCellModel *about = [[SettingTableViewCellModel alloc] init];
    about.title = @"关于";
    about.cellClass = [SettingTableViewCell class];
    about.cellAction = @selector(clickAbout);
    about.rowHeight = 50;
    about.showAccessory = YES;
    [sectons addObject:@[about]];

    SettingTableViewCellModel *logout = [[SettingTableViewCellModel alloc] init];
    logout.title = @"退出";
    logout.cellClass = [SettingTableViewCell class];
    logout.cellAction = @selector(clickLogout);
    logout.rowHeight = 50;
    logout.showAccessory = NO;
    [sectons addObject:@[logout]];

    self.data = sectons;

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
