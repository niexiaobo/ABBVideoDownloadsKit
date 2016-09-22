//
//  DownLoadListViewController.m
//  ABBVideoDownloadPlayer
//
//  Created by beyondsoft-聂小波 on 16/9/19.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "DownLoadListViewController.h"
#import "UIView+WHC_Toast.h"
#import "DetailViewController.h"


@interface DownLoadListViewController ()<DownLoadListCellDelegate>
@property (nonatomic , strong)NSMutableArray *downloadObjectArr;
//@property (nonatomic , strong)MPMoviePlayerViewController *playerViewController;
@property (nonatomic , strong)NSString *plistPath;
@end

@implementation DownLoadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"离线视频中心";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initData];
    [self layoutUI];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)layoutUI{
    [self.tableView registerNib:[UINib nibWithNibName:kCellName bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellName];
}

- (void)initData{
    _downloadObjectArr = [NSMutableArray arrayWithArray:[WHC_DownloadObject readDiskAllCache]];
    [self.tableView reloadData];
}

#pragma mark - WHC_OffLineVideoCellDelegate
- (void)videoDownload:(NSError *)error index:(NSInteger)index strUrl:(NSString *)strUrl {
    if (error != nil) {
        [self.view toast:error.userInfo[NSLocalizedDescriptionKey]];
    }
    WHC_DownloadObject * downloadObject = _downloadObjectArr[index];
    [downloadObject removeFromDisk];
    [_downloadObjectArr removeObjectAtIndex:index];
    [self.tableView reloadData];
}

- (void)updateDownloadValue:(WHC_DownloadObject *)downloadObject index:(NSInteger)index {
    if (downloadObject != nil) {
        WHC_DownloadObject * tempDownloadObject = _downloadObjectArr[index];
        tempDownloadObject.currentDownloadLenght = downloadObject.currentDownloadLenght;
        tempDownloadObject.totalLenght = downloadObject.totalLenght;
        tempDownloadObject.downloadSpeed = downloadObject.downloadSpeed;
        tempDownloadObject.downloadState = downloadObject.downloadState;
        
    }
}

- (void)videoPlayerIndex:(NSInteger)index {
    WHC_DownloadObject * downloadObject = _downloadObjectArr[index];
    NSString *playUrl = [NSString stringWithFormat:@"%@%@",[WHC_DownloadObject videoDirectory],downloadObject.fileName];
    
    [self playMp4:playUrl fileName:downloadObject.fileName];
}

-(void) playMp4:(NSString*)url fileName:(NSString*)fileName{
    //播放器
    DetailViewController *detailVC = [[DetailViewController alloc]init];
    detailVC.URLString = url;
    detailVC.title = fileName;
    detailVC.isLocalURLString = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}
- (void)movieFinishedCallback:(NSNotification *)notifiy{
}

#pragma mark - table 代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return _downloadObjectArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return kCellHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DownLoadListCell  * cell = [tableView dequeueReusableCellWithIdentifier:kCellName];
    NSInteger row = indexPath.row;
    cell.delegate = self;
    [cell displayCell:_downloadObjectArr[row] index:row];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = indexPath.row;
    WHC_DownloadObject * downloadObject = _downloadObjectArr[row];
#if WHC_BackgroundDownload
    [[WHC_SessionDownloadManager shared] cancelDownloadWithFileName:downloadObject.fileName deleteFile:YES];
#else
    [[WHC_HttpManager shared] cancelDownloadWithFileName:downloadObject.fileName deleteFile:YES];
#endif
    [downloadObject removeFromDisk];
    [_downloadObjectArr removeObjectAtIndex:row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
