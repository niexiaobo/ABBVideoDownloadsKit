//
//  DownLoadListCell.m
//  ABBVideoDownloadPlayer
//
//  Created by beyondsoft-聂小波 on 16/9/19.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "DownLoadListCell.h"



@interface DownLoadListCell ()<WHC_DownloadDelegate>

@property (nonatomic , strong)IBOutlet UILabel *titleLabel;
@property (nonatomic , strong)IBOutlet UILabel *downloadValueLabel;
@property (nonatomic , strong)IBOutlet UILabel  *speedLabel;
@property (nonatomic , strong)IBOutlet UIProgressView *progressBar;
@property (nonatomic , strong)IBOutlet UIButton *downloadButton;

@property (nonatomic , strong)UIButton *downloadArrowButton;
@property (nonatomic , strong)WHC_DownloadObject *downloadObject;
@property (nonatomic , assign)BOOL hasDownloadAnimation;

@end

@implementation DownLoadListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _downloadButton.clipsToBounds = true;
    [_downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

- (void)addDownloadAnimation {
    if(_downloadArrowButton){
        [UIView animateWithDuration:1.2 animations:^{
            _downloadArrowButton.y = _downloadArrowButton.height;
        }completion:^(BOOL finished) {
            _downloadArrowButton.y = -_downloadArrowButton.height;
            [self addDownloadAnimation];
        }];
    }
}

- (void)startDownloadAnimation {
    if (_downloadArrowButton == nil) {
        _downloadArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _downloadArrowButton.enabled = false;
        _downloadArrowButton.frame = _downloadButton.bounds;
        [_downloadArrowButton setTitle:@"↓" forState:UIControlStateNormal];
        [_downloadArrowButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        _downloadArrowButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    if (!_hasDownloadAnimation) {
        _hasDownloadAnimation = true;
        _downloadArrowButton.y = -_downloadArrowButton.height;
        [_downloadButton addSubview:_downloadArrowButton];
        [self addDownloadAnimation];
    }
}

- (void)removeDownloadAnimtion {
    _hasDownloadAnimation = false;
    if (_downloadArrowButton != nil) {
        [_downloadArrowButton removeFromSuperview];
        _downloadArrowButton = nil;
    }
}

- (void)updateDownloadValue {
    _titleLabel.text = _downloadObject.fileName;
    _progressBar.progress = _downloadObject.downloadProcessValue;
    _downloadValueLabel.text = _downloadObject.downloadProcessText;
    NSString * strSpeed = _downloadObject.downloadSpeed;
    if (_downloadObject.downloadState != WHCDownloading) {
        [self removeDownloadAnimtion];
    }else {
        
        [_downloadObject writeDiskCache];
        [self startDownloadAnimation];
    }
    switch (_downloadObject.downloadState) {
        case WHCDownloadWaitting:
            [_downloadButton setTitle:@"🕘" forState:UIControlStateNormal];
            strSpeed = @"等待";
            break;
        case WHCDownloading:
            [_downloadButton setTitle:@"" forState:UIControlStateNormal];
            break;
        case WHCDownloadCanceled:
            [_downloadButton setTitle:@"■" forState:UIControlStateNormal];
            strSpeed = @"暂停";
            break;
        case WHCDownloadCompleted:
            [_downloadButton setTitle:@"▶" forState:UIControlStateNormal];
            strSpeed = @"完成";
        case WHCNone:
            break;
    }
    _speedLabel.text = strSpeed;
}

- (void)fetchDataResult {
    
    [self clickDownload:nil];
    
}

- (IBAction)clickDownload:(UIButton *)sender {
    switch (_downloadObject.downloadState) {
        case WHCDownloading:
            _downloadObject.downloadState = WHCDownloadCanceled;
#if WHC_BackgroundDownload
            [[WHC_SessionDownloadManager shared] cancelDownloadWithFileName:_downloadObject.fileName deleteFile:NO];
#else
            [[WHC_HttpManager shared] cancelDownloadWithFileName:_downloadObject.fileName deleteFile:NO];
#endif
            break;
        case WHCDownloadCanceled:{
            _downloadObject.downloadState = WHCDownloadWaitting;
#if WHC_BackgroundDownload
            [[WHC_SessionDownloadManager shared] setBundleIdentifier:@"com.WHC.WHCNetWorkKit.backgroundsession"];
            WHC_DownloadSessionTask * downloadTask = [[WHC_SessionDownloadManager shared] download:_downloadObject.downloadPath
                                                                                          savePath:[WHC_DownloadObject videoDirectory]
                                                                                      saveFileName:_downloadObject.fileName delegate:self];
            downloadTask.index = self.index;
            
            
#else
            WHC_DownloadOperation * operation = [[WHC_HttpManager shared] download:_downloadObject.downloadPath
                                                                          savePath:[WHC_DownloadObject videoDirectory]
                                                                      saveFileName:_downloadObject.fileName delegate:self];
            operation.index = self.index;
#endif
            [self updateDownloadValue];
        }
            break;
        case WHCDownloadWaitting:
            break;
        case WHCDownloadCompleted:
            if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerIndex:)]) {
                [_delegate videoPlayerIndex:_index];
            }
            break;
        default:
            break;
    }
}

- (void)displayCell:(WHC_DownloadObject *)object index:(NSInteger)index {
    self.index = index;
    _downloadObject = object;
    if (_downloadObject.downloadState == WHCNone ||
        _downloadObject.downloadState == WHCDownloading ) {
        
        _downloadObject.downloadState = WHCDownloadWaitting;
    }
#if WHC_BackgroundDownload
    [[WHC_SessionDownloadManager shared] setBundleIdentifier:@"com.WHC.WHCNetWorkKit.backgroundsession"];
    WHC_DownloadSessionTask * downloadTask = [[WHC_SessionDownloadManager shared] replaceCurrentDownloadOperationDelegate:self fileName:_downloadObject.fileName];
    if ([[WHC_SessionDownloadManager shared] existDownloadOperationTaskWithFileName:_downloadObject.fileName]) {
        if (_downloadObject.downloadState == WHCDownloadCanceled) {
            _downloadObject.downloadState = WHCDownloadWaitting;
        }
    }
    downloadTask.index = index;
#else
    WHC_DownloadOperation * operation = [[WHC_HttpManager shared] replaceCurrentDownloadOperationDelegate:self fileName:_downloadObject.fileName];
    if ([[WHC_HttpManager shared] existDownloadOperationTaskWithFileName:_downloadObject.fileName]) {
        if (_downloadObject.downloadState == WHCDownloadCanceled) {
            _downloadObject.downloadState = WHCDownloadWaitting;
        }
    }
    operation.index = index;
#endif
    [self updateDownloadValue];
    [self removeDownloadAnimtion];
}

- (void)saveDownloadState:(WHC_DownloadOperation *)operation {
    _downloadObject.currentDownloadLenght = operation.recvDataLenght;
    _downloadObject.totalLenght = operation.fileTotalLenght;
    [_downloadObject writeDiskCache];
}

//WHC_DownloadSessionTask : WHC_DownloadOperation

#pragma mark - WHC_DownloadDelegate -
- (void)WHCDownloadResponse:(nonnull WHC_DownloadOperation *)operation
                      error:(nullable NSError *)error
                         ok:(BOOL)isOK {
    if (isOK) {
        if (self.index == operation.index) {
            _downloadObject.downloadState = WHCDownloading;
            _downloadObject.currentDownloadLenght = operation.recvDataLenght;
            _downloadObject.totalLenght = operation.fileTotalLenght;
            [self updateDownloadValue];
        }else {
            WHC_DownloadObject * tempDownloadObject = [WHC_DownloadObject readDiskCache:operation.strUrl];
            if (tempDownloadObject != nil) {
                tempDownloadObject.downloadState = WHCDownloading;
                tempDownloadObject.currentDownloadLenght = operation.recvDataLenght;
                tempDownloadObject.totalLenght = operation.fileTotalLenght;
                [tempDownloadObject writeDiskCache];
                if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadValue: index:)]) {
                    [_delegate updateDownloadValue:tempDownloadObject index:operation.index];
                }
            }
        }
    }else {
        _downloadObject.downloadState = WHCNone;
        if (_delegate &&
            [_delegate respondsToSelector:@selector(videoDownload:index:strUrl:)]) {
            [_delegate videoDownload:error index:_index strUrl:operation.strUrl];
        }
    }
}

- (void)WHCDownloadProgress:(nonnull WHC_DownloadOperation *)operation
                       recv:(uint64_t)recvLength
                      total:(uint64_t)totalLength
                      speed:(nullable NSString *)speed {
    if (operation.index == self.index) {
        if (_downloadObject.totalLenght < 10) {
            _downloadObject.totalLenght = totalLength;
        }
        _downloadObject.currentDownloadLenght = recvLength;
        _downloadObject.downloadSpeed = speed;
        _downloadObject.downloadState = WHCDownloading;
        [self updateDownloadValue];
        [self startDownloadAnimation];
    }
}

- (void)WHCDownloadDidFinished:(nonnull WHC_DownloadOperation *)operation
                          data:(nullable NSData *)data
                         error:(nullable NSError *)error
                       success:(BOOL)isSuccess {
    if (isSuccess) {
        if (self.index == operation.index) {
            _downloadObject.downloadState = WHCDownloadCompleted;
            [self saveDownloadState:operation];
        }else {
            WHC_DownloadObject * tempDownloadObject = [WHC_DownloadObject readDiskCache:operation.strUrl];
            if (tempDownloadObject != nil) {
                tempDownloadObject.downloadState = WHCDownloadCompleted;
                tempDownloadObject.currentDownloadLenght = operation.recvDataLenght;
                tempDownloadObject.totalLenght = operation.fileTotalLenght;
                [tempDownloadObject writeDiskCache];
                if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadValue:index:)]) {
                    [_delegate updateDownloadValue:tempDownloadObject index:operation.index];
                }
            }
        }
    }else {
        
        WHC_DownloadObject * tempDownloadObject;
        if (self.index == operation.index) {
            _downloadObject.downloadState = WHCDownloadCanceled;
        }else {
            tempDownloadObject = [WHC_DownloadObject readDiskCache:operation.strUrl];
            if (tempDownloadObject != nil) {
                tempDownloadObject.downloadState = WHCDownloadCanceled;
            }
        }
        if (error != nil &&
            error.code == WHCCancelDownloadError &&
            !operation.isDeleted) {
            if (self.index == operation.index) {
                [self saveDownloadState:operation];
            }else {
                if (tempDownloadObject != nil) {
                    tempDownloadObject.currentDownloadLenght = operation.recvDataLenght;
                    tempDownloadObject.totalLenght = operation.fileTotalLenght;
                    [tempDownloadObject writeDiskCache];
                }
                
            }
            [self saveDownloadState:operation];
        }else {
            [[[UIAlertView alloc] initWithTitle:@"下载失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        if (tempDownloadObject != nil) {
            if (_delegate && [_delegate respondsToSelector:@selector(updateDownloadValue:index:)]) {
                [_delegate updateDownloadValue:tempDownloadObject index:operation.index];
            }
        }
    }
    if (self.index == operation.index) {
        [self updateDownloadValue];
    }
}


@end
