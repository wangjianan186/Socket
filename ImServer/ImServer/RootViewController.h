//
//  RootViewController.h
//  ImServer
//
//  Created by yang on 3/6/14.
//  Copyright (c) 2014 家里蹲. All rights reserved.
//

#import <UIKit/UIKit.h>
// socket的udp头文件
#import "AsyncUdpSocket.h"

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AsyncUdpSocketDelegate> {
    NSMutableArray *_dataArr;
    UITableView *_tableView;
    
    // 套接字对象 这个socket对象主要用来收发消息的
    AsyncUdpSocket *udpSocket;
    AsyncUdpSocket *udpSendSocket;
}

@end
