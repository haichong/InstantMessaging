//
//  ChatViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/27.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "ChatViewController.h"
#import "InputView.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface ChatViewController ()<UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    NSFetchedResultsController *_fetchResultsVC;
    UITableView *_tableView;
    UIImagePickerController *_picker;
}
@property (nonatomic,strong) NSLayoutConstraint *inputViewHeightConstrait;//InputView 的高度
@property (nonatomic,strong) NSLayoutConstraint *inputViewBottomConstrait;//InputView 底部的约束
@property (nonatomic,strong) HttpTool *httpTool;
@end

@implementation ChatViewController
- (HttpTool *)httpTool {
    if (!_httpTool) {
        _httpTool = [HttpTool new];
    }
    return _httpTool;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self loadMsgs];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)kbWillShow : (NSNotification *)notification{
    CGRect kbEndFrm = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbEndY = kbEndFrm.size.height;
    self.inputViewBottomConstrait.constant = kbEndY;
    [self scrollToTableBottom];
}
- (void)kbWillHide : (NSNotification *)notification{
    self.inputViewBottomConstrait.constant = 0;
    [self scrollToTableBottom];
}
- (void)setupView {
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];
    
    InputView *inputView = [InputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.textView.delegate = self;
    [inputView.addButton addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputView];
    _tableView = tableView;
    
    // 自动布局
    // 水平方向的约束
    NSDictionary *views = @{@"tableView":tableView,@"inputView":inputView};
    NSArray *tableViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-64-[tableView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableViewHConstraints];
    
    NSArray *inputViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewHConstraints];
    
    // 垂直方向的约束
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    self.inputViewHeightConstrait = vConstraints[2];
    self.inputViewBottomConstrait = [vConstraints lastObject];
    [self.view addConstraints:vConstraints];
}
- (void)loadMsgs {
    
    NSManagedObjectContext *context = [XMPPTool shareXMPPTool].msgStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[XMPPTool shareXMPPTool].jid,self.friendId.bare];
    request.predicate = pre;
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    _fetchResultsVC = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchResultsVC.delegate = self;
    NSError *err = nil;
    [_fetchResultsVC performFetch:&err];
    if (err) {
        WCLog(@"%@",err);
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchResultsVC.fetchedObjects.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *iden =@"ChatCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
    }
    XMPPMessageArchiving_Message_CoreDataObject *msg = _fetchResultsVC.fetchedObjects[indexPath.row];
    NSString *chatType = [msg.message attributeStringValueForName:@"chatType"];
    if ([chatType isEqualToString:@"image"]) {
         cell.textLabel.text = msg.body;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:msg.body] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        cell.textLabel.text = nil;
    }else {
        if (msg.outgoing.boolValue) {
            // 自己发
        }else {
            cell.imageView.image = nil;
            // 别人发
            cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",self.friendId.user,msg.body];
            cell.textLabel.textColor = [UIColor blueColor];
        }
    }
    return cell;
}
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = textView.text;
    CGFloat contenH = textView.contentSize.height;
    // 通过测试，知道一行高度33
     // 三行以内
    if (contenH > 33 && contenH <= 68) {
        self.inputViewHeightConstrait.constant = contenH + 20;
    }
    if ([text rangeOfString:@"\n"].length != 0) {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self sendMsgWithText:text bodyType:@"text"];
        textView.text = @"";
        self.inputViewHeightConstrait.constant = 50;
    }
}
#pragma mark - 发送聊天消息
- (void)sendMsgWithText: (NSString *)text bodyType: (NSString *)bodyType{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendId];
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    [msg addBody:text];
    [[XMPPTool shareXMPPTool].xmppStream sendElement:msg];
}
/*
 发送文件（图片、音频）的方法
 1. 在XMPPMessage里放文件。把文件经base编码后成字符串，然后把字符串放入body中，比较小的可以，大得不行，因为字符串太长了。
 2.先把文件上传到服务器，body里放文件的地址。一般用这种解决方案。
 **/
- (void)addAction{
    _picker = [UIImagePickerController new];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    [self presentViewController:_picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    /*
     put的上传路径就是下载路径
     文件上传路径 http://localhost:8080/imfileserver/Upload/Image/+“图片名（程序员自己定义）”
     **/
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:User];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [dateFormat stringFromDate:[NSDate date]];
    NSString *fileName = [user stringByAppendingString:timeStr];
    NSString *uploadUrl = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    [self.httpTool uploadData:data url:[NSURL URLWithString:uploadUrl] progressBlock:^(CGFloat progress) {
        
    } completion:^(NSError *error) {
        if (!error) {
            NSLog(@"上传成功");
            [self sendMsgWithText:uploadUrl bodyType:@"image"];
        }
    }];
    
}
#pragma mark - 滚动到tableview底部
- (void)scrollToTableBottom {
    
    NSUInteger count =  _fetchResultsVC.fetchedObjects.count;
    if (count > 0) {
        [_tableView reloadData];
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [_tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self scrollToTableBottom];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
