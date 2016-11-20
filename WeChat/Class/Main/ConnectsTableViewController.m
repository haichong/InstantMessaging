//
//  ConnectsTableViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/26.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "ConnectsTableViewController.h"
#import "ChatViewController.h"

@interface ConnectsTableViewController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultVC;
}
@property (nonatomic, strong) NSArray *friends;
@end

@implementation ConnectsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFriends2];
}
- (void)loadFriends1{
    NSManagedObjectContext *context = [XMPPTool shareXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    // 获得当前登录用户的好友
    NSString *jid = [XMPPTool shareXMPPTool].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@",jid];
    request.predicate = pre;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    _friends = [context executeFetchRequest:request error:nil];
    NSLog(@"_friends=%@",_friends);
}
// 可以事实监听好友数据变化
- (void)loadFriends2{
    NSManagedObjectContext *context = [XMPPTool shareXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    // 获得当前登录用户的好友
    NSString *jid = [XMPPTool shareXMPPTool].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr=%@",jid];
    request.predicate = pre;
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    _resultVC = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultVC.delegate = self;
    NSError *error;
    [_resultVC performFetch:&error];
    if (error) {
        WCLog(@"%@",error);
    }
}
#pragma mark - NSFetchedResultsControllerDelegate 

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultVC.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *iden = @"ConnectsCell";
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:iden];
    // 获取对应的好友
    XMPPUserCoreDataStorageObject *friend = _resultVC.fetchedObjects[indexPath.row];
    cell.textLabel.text = friend.jidStr;
    /*
     sectionNum
     0：在线
     1：离开
     2：离线
     **/
    switch ([friend.sectionNum intValue]) {
        case 0:
            cell.detailTextLabel.text = @"在线";
            break;
        case 1:
            cell.detailTextLabel.text = @"离开";
            break;
        case 2:
            cell.detailTextLabel.text = @"离开";
            break;
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    XMPPUserCoreDataStorageObject *friend = _resultVC.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"ChatSegue" sender:friend.jid];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[ChatViewController class]]) {
        ChatViewController *chatVC = destVC;
        chatVC.friendId = sender;
    }
}
#pragma mark 左滑删除好友
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XMPPUserCoreDataStorageObject *friend = _resultVC.fetchedObjects[indexPath.row];
        XMPPJID *friendJid = friend.jid;
        [[XMPPTool shareXMPPTool].roster removeUser:friendJid];
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    WCLog(@"好友数据发生改变");
    // 刷新表格
    [self .tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
