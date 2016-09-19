//
//  downloadObject.h
//  ABBVideoDownloadPlayer
//
//  Created by beyondsoft-聂小波 on 16/9/18.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreModel.h"

//typedef NS_OPTIONS(NSUInteger, WHCDownloadState) {
//    WHCNone = 1 << 0,
//    WHCDownloading = 1 << 1,
//    WHCDownloadCompleted = 1 << 2,
//    WHCDownloadCanceled = 1 << 3,
//    WHCDownloadWaitting = 1 << 4
//};

@interface DownloadObject : CoreModel

@property (nonatomic , copy) NSString * fileName;
@property (nonatomic , copy) NSString * downloadSpeed;
@property (nonatomic , copy) NSString * downloadPath;
@property (nonatomic , assign) UInt64 totalLenght;
@property (nonatomic , assign) UInt64 currentDownloadLenght;
@property (nonatomic , assign , readonly) float downloadProcessValue;
@property (nonatomic , assign) NSUInteger downloadState;
@property (nonatomic , copy , readonly)NSString * currentDownloadLenghtToString;
@property (nonatomic , copy , readonly)NSString * totalLenghtToString;
@property (nonatomic , copy , readonly)NSString * downloadProcessText;
@property (nonatomic , copy) NSString * etag;

@end
