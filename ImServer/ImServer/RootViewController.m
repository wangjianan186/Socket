//
//  RootViewController.m
//  ImServer
//
//  Created by yang on 3/6/14.
//  Copyright (c) 2014 家里蹲. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _dataArr = [[NSMutableArray alloc] init];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIBarButtonItem *sendItm = [[UIBarButtonItem alloc] initWithTitle:@"发送自己" style:UIBarButtonItemStylePlain target:self action:@selector(sendSmg)];
    self.navigationItem.rightBarButtonItem = sendItm;
    
    // 1. 创建socket 发送socket
    udpSendSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];

    // 接收socket
    udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
    
    // 2. 服务端写接收函数 服务端绑定一个端口
    [udpSocket bindToPort:8989 error:nil];
    // 3. 等待一次发过来的数据 -1表示超时
    [udpSocket receiveWithTimeout:-1 tag:200];
}

// sock表示当前的socket  data表示你们发过来的数据  tag表示这次接收
// host:port表示对方的ip和端口
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    s = [NSString stringWithFormat:@"%@:%d %@", host, port, s];
    NSLog(@"接收到数据了 %@", s);
    
    [_dataArr addObject:s];
    [_tableView reloadData];
    if (_dataArr.count> 0) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArr.count-1 inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // 转发发给你
//    [sock sendData:<#(NSData *)#> toHost:<#(NSString *)#> port:<#(UInt16)#> withTimeout:<#(NSTimeInterval)#> tag:<#(long)#>]
    // 再次来接收一次数据 tag=200这次接收...
    [udpSocket receiveWithTimeout:-1 tag:200];
    return YES;
}
- (void) sendSmg {
    // 开始发送消息
    NSString *msg = @"hello from oyangjian";
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *host = @"192.168.101.132"; // 给谁发的消息ip地址
    NSString *host = @"127.0.0.1";// 这是一个本机特殊的ip地址
    UInt16 port = 8989; // 表示服务器的端口
    [udpSendSocket sendData:msgData toHost:host port:port withTimeout:60 tag:100];
    // 60表示超时 如果60s还发送不了 就出错
    // 上面这个函数表示发送数据服务端 host:port
    // 当时这个函数是异步的 也就是还没有发送完成(只是启动发送 不会真正的发送,后台会真正的发送)
    // 什么时候发送完成呢？使用代理
    // tag:100表示这次发送的标记是100

}
// 已经发送完成的代理函数
- (void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    if (tag == 100) { // 表示tag==100的发送完成了
        NSLog(@"tag=100的 发送完成了");
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArr count];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"cell id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    NSString *s = [_dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text = s;
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
