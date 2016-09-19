//
//  DownLoadListCell.h
//  ABBVideoDownloadPlayer
//
//  Created by beyondsoft-聂小波 on 16/9/19.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHC_DownloadObject.h"
#import "WHCNetWorkKit.h"
#import "UIView+WHC_ViewProperty.h"

#define kFontSize             (15.0)
#define kCellHeight           (57.0)                   //cell高度
#define kMinPlaySize          (10.0)                   //最小播放尺寸
#define kCellName             (@"DownLoadListCell")//cell名称

#define WHC_BackgroundDownload (1)

@protocol DownLoadListCellDelegate <NSObject>

- (void)videoDownload:(NSError *)error index:(NSInteger)index strUrl:(NSString *)strUrl;
- (void)updateDownloadValue:(WHC_DownloadObject *)downloadObject index:(NSInteger)index;
- (void)videoPlayerIndex:(NSInteger)index;

@end

@interface DownLoadListCell : UITableViewCell
@property (nonatomic , weak)id<DownLoadListCellDelegate> delegate;
@property (nonatomic , assign)NSInteger index;

- (void)displayCell:(WHC_DownloadObject *)object index:(NSInteger)index;

@end
