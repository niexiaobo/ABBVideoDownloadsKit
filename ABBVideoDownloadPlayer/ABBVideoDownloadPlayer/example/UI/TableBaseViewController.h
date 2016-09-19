//
//  TableBaseViewController.h
//  ABBVideoDownloadPlayer
//
//  Created by beyondsoft-聂小波 on 16/9/19.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Screen_height  [[UIScreen mainScreen] bounds].size.height
#define Screen_width  [[UIScreen mainScreen] bounds].size.width

@interface TableBaseViewController : UIViewController
@property(nonatomic, strong) UITableView *tableView;
@end
