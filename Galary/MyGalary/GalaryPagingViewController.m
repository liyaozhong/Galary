//
//  GalaryPagingViewController.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryPagingViewController.h"
#import "CheckView.h"

typedef void(^PickCompleteBlock)(NSArray<PHAsset*>* assets);

@interface GalaryPagingViewController ()<PHPhotoLibraryChangeObserver, UIScrollViewDelegate>
{
    PHImageRequestOptions *fastOptions;
    PHImageRequestOptions *highQualityOptions;
    UIImageView * curCenterImageView;
    PickCompleteBlock mPickComplete;
    BOOL mIncrementalCount;
}
@property (nonatomic, strong) UIScrollView * pagingSrollView;
@property (nonatomic, strong) UIImageView * imageView1;
@property (nonatomic, strong) UIImageView * imageView2;
@property (nonatomic, strong) UIImageView * imageView3;
@property (nonatomic, strong) CheckView * checkBtn;
@end

@implementation GalaryPagingViewController

- (instancetype) initWithIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete
{
    self = [super init];
    if(self){
        mPickComplete = pickComplete;
        mIncrementalCount = incrementalCount;
    }
    return self;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    [self setupView];
    fastOptions = [[PHImageRequestOptions alloc] init];
    fastOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    fastOptions.networkAccessAllowed = YES;
    
    highQualityOptions = [[PHImageRequestOptions alloc] init];
    highQualityOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    highQualityOptions.networkAccessAllowed = YES;
}

- (void) setupView
{
    UIControl * bg = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [bg addTarget:self action:@selector(onRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    bg.backgroundColor = [UIColor clearColor];
    _checkBtn = [[CheckView alloc] initWithFrame:CGRectMake(20, 10, 20, 20)];
    [_checkBtn setShowIndex:mIncrementalCount];
    _checkBtn.userInteractionEnabled = NO;
    [bg addSubview:_checkBtn];
    _checkBtn.backgroundColor = [UIColor clearColor];
    UIBarButtonItem * rightTitleBtn = [[UIBarButtonItem alloc] initWithCustomView:bg];
    [self updateTitle];
    self.navigationItem.rightBarButtonItem = rightTitleBtn;
    _pagingSrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _pagingSrollView.delegate = self;
    _pagingSrollView.contentSize = CGSizeMake(self.view.bounds.size.width * self.assetsFetchResults.count, 0);
    _pagingSrollView.showsHorizontalScrollIndicator = NO;
    _pagingSrollView.pagingEnabled = YES;
    _pagingSrollView.contentOffset = CGPointMake(self.view.bounds.size.width * self.index, 0);
    [self.view addSubview:_pagingSrollView];
    NSInteger position = self.index;
    if(self.index == 0){
        position = 1;
    }else if(self.index == self.assetsFetchResults.count - 1){
        position = self.assetsFetchResults.count - 2;
    }
    _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * (position - 1), 0, self.view.bounds.size.width, self.pagingSrollView.bounds.size.height)];
    _imageView1.contentMode = UIViewContentModeScaleAspectFit;
    _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * position, 0, self.view.bounds.size.width, self.pagingSrollView.bounds.size.height)];
    _imageView2.contentMode = UIViewContentModeScaleAspectFit;
    _imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width * (position + 1), 0, self.view.bounds.size.width, self.pagingSrollView.bounds.size.height)];
    _imageView3.contentMode = UIViewContentModeScaleAspectFit;
    [_pagingSrollView addSubview:_imageView1];
    [_pagingSrollView addSubview:_imageView2];
    [_pagingSrollView addSubview:_imageView3];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.index == 0){
        [self requestTargetImage:self.imageView1 index:self.index];
        [self requestTargetImage:self.imageView2 index:self.index+1];
        [self requestTargetImage:self.imageView3 index:self.index+2];
    }else if(self.index == self.assetsFetchResults.count - 1){
        [self requestTargetImage:self.imageView3 index:self.index];
        [self requestTargetImage:self.imageView2 index:self.index-1];
        [self requestTargetImage:self.imageView1 index:self.index-2];
    }else{
        [self requestTargetImage:self.imageView1 index:self.index-1];
        [self requestTargetImage:self.imageView2 index:self.index];
        [self requestTargetImage:self.imageView3 index:self.index+1];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.index == 0){
        [self showHighQualityImage:self.imageView1 index:self.index];
    }else if(self.index == self.assetsFetchResults.count - 1){
        [self showHighQualityImage:self.imageView3 index:self.index];
    }else{
        [self showHighQualityImage:self.imageView2 index:self.index];
    }
}

- (void) updateTitle
{
    if([self.checkedImgs containsObject:[NSNumber numberWithInteger:self.index]]){
        [_checkBtn setIndex:[self.checkedImgs indexOfObject:[NSNumber numberWithInteger:self.index]]+1];
        if(_checkBtn.hidden){
            _checkBtn.bounds = CGRectMake(0, 0, 10, 10);
            _checkBtn.alpha = 0.5f;
            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:0 animations:^{
                _checkBtn.bounds = CGRectMake(0, 0, 20, 20);
                _checkBtn.alpha = 1;
            } completion:nil];
            _checkBtn.hidden = NO;
        }
    }else{
        _checkBtn.hidden = YES;
    }
}

- (void) onRightBtnClick
{
    if([self.checkedImgs containsObject:[NSNumber numberWithInteger:self.index]]){
        [self.checkedImgs removeObject:[NSNumber numberWithInteger:self.index]];
    }else{
        [self.checkedImgs addObject:[NSNumber numberWithInteger:self.index]];
    }
    [self updateTitle];
}

- (void) requestTargetImage : (UIImageView *) imageView index : (NSInteger) index
{
    if(index < 0 || self.assetsFetchResults.count <= index){
        return;
    }
    imageView.image = nil;
    imageView.tag = 0;
    [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)(imageView.tag)];
    __block PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:[self.assetsFetchResults objectAtIndex:index] targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:fastOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result) {
            return;
        }
        if(imageView.tag == requestID){
            imageView.image = result;
        }
    }];
    imageView.tag = requestID;
}

- (void) showHighQualityImage : (UIImageView *) imageView index : (NSInteger) index
{
    if(index < 0 || self.assetsFetchResults.count <= index){
        return;
    }
    [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)(imageView.tag)];
    __block PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:[self.assetsFetchResults objectAtIndex:index] targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:highQualityOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result) {
            return;
        }
        if(imageView.tag == requestID){
            imageView.image = result;
        }
    }];
    imageView.tag = requestID;
}

- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.pagingSrollView.bounds) * scale, CGRectGetHeight(self.pagingSrollView.bounds) * scale);
    return targetSize;
}

- (void) checkToSwapImageView
{
    NSInteger curIndex = self.pagingSrollView.contentOffset.x / self.pagingSrollView.bounds.size.width + 0.5f;
    if(curIndex == self.index){
        return;
    }
    BOOL edge = self.index == 0 || self.index == self.assetsFetchResults.count - 1;
    self.index = curIndex;
    [self updateTitle];
    CGFloat img1CenterGap = ABS(_imageView1.frame.origin.x - self.pagingSrollView.contentOffset.x);
    CGFloat img2CenterGap = ABS(_imageView2.frame.origin.x - self.pagingSrollView.contentOffset.x);
    CGFloat img3CenterGap = ABS(_imageView3.frame.origin.x - self.pagingSrollView.contentOffset.x);
    if(img1CenterGap > self.pagingSrollView.bounds.size.width){
        if(_imageView1.frame.origin.x < _imageView2.frame.origin.x){
            if(self.index >= self.assetsFetchResults.count - 1){
                self.index = self.assetsFetchResults.count - 1;
            }else if(!edge){
                CGRect frame = _imageView1.frame;
                _imageView1.frame = CGRectMake(frame.origin.x + self.pagingSrollView.bounds.size.width * 3, frame.origin.y, frame.size.width, frame.size.height);
                [self requestTargetImage:self.imageView1 index:self.index+1];
            }
        }else{
            if(self.index <= 0){
                self.index = 0;
            }else if(!edge){
                CGRect frame = _imageView1.frame;
                _imageView1.frame = CGRectMake(frame.origin.x - self.pagingSrollView.bounds.size.width * 3, frame.origin.y, frame.size.width, frame.size.height);
                [self requestTargetImage:self.imageView1 index:self.index-1];
            }
        }
    }else if(img2CenterGap > self.pagingSrollView.bounds.size.width){
        if(_imageView2.frame.origin.x < _imageView1.frame.origin.x){
            if(self.index >= self.assetsFetchResults.count - 1){
                self.index = self.assetsFetchResults.count - 1;
            }else if(!edge){
                CGRect frame = _imageView2.frame;
                _imageView2.frame = CGRectMake(frame.origin.x + self.pagingSrollView.bounds.size.width * 3, frame.origin.y, frame.size.width, frame.size.height);
                [self requestTargetImage:self.imageView2 index:self.index+1];
            }
        }else{
            if(self.index <= 0){
                self.index = 0;
            }else if(!edge){
                CGRect frame = _imageView2.frame;
                _imageView2.frame = CGRectMake(frame.origin.x - self.pagingSrollView.bounds.size.width * 3, frame.origin.y, frame.size.width, frame.size.height);
                [self requestTargetImage:self.imageView2 index:self.index-1];
            }
        }
    }else if(img3CenterGap > self.pagingSrollView.bounds.size.width){
        if(_imageView3.frame.origin.x < _imageView1.frame.origin.x){
            if(self.index >= self.assetsFetchResults.count - 1){
                self.index = self.assetsFetchResults.count - 1;
            }else if(!edge){
                CGRect frame = _imageView3.frame;
                _imageView3.frame = CGRectMake(frame.origin.x + self.pagingSrollView.bounds.size.width * 3, frame.origin.y, frame.size.width, frame.size.height);
                [self requestTargetImage:self.imageView3 index:self.index+1];
            }
        }else{
            if(self.index <= 0){
                self.index = 0;
            }else if(!edge){
                CGRect frame = _imageView3.frame;
                _imageView3.frame = CGRectMake(frame.origin.x - self.pagingSrollView.bounds.size.width * 3, frame.origin.y, frame.size.width, frame.size.height);
                [self requestTargetImage:self.imageView3 index:self.index-1];
            }
        }
    }
    if(img1CenterGap < img2CenterGap && img1CenterGap < img3CenterGap){
        curCenterImageView = self.imageView1;
    }else if(img2CenterGap < img1CenterGap && img2CenterGap < img3CenterGap){
        curCenterImageView = self.imageView2;
    }else if(img3CenterGap < img1CenterGap && img3CenterGap < img2CenterGap){
        curCenterImageView = self.imageView3;
    }
}

- (void)scrollingStop
{
    [self showHighQualityImage:curCenterImageView index:self.index];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self checkToSwapImageView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollingStop];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollingStop];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self scrollingStop];
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        [self checkToSwapImageView];
    });
}

@end