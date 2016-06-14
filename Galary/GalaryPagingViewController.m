//
//  GalaryPagingViewController.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryPagingViewController.h"
#import "CheckView.h"

@interface GalaryPagingViewController ()<PHPhotoLibraryChangeObserver, UIScrollViewDelegate>
{
    PHImageRequestOptions *fastOptions;
    PHImageRequestOptions *highQualityOptions;
}
@property (nonatomic, strong) UIScrollView * pagingSrollView;
@property (nonatomic, strong) UIImageView * leftImageView;
@property (nonatomic, strong) UIImageView * centerImageView;
@property (nonatomic, strong) UIImageView * rightImageView;
@property (nonatomic, strong) CheckView * checkBtn;
@end

@implementation GalaryPagingViewController

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
    _checkBtn.userInteractionEnabled = NO;
    [bg addSubview:_checkBtn];
    _checkBtn.backgroundColor = [UIColor clearColor];
    UIBarButtonItem * rightTitleBtn = [[UIBarButtonItem alloc] initWithCustomView:bg];
    [self updateTitle];
    self.navigationItem.rightBarButtonItem = rightTitleBtn;
    _pagingSrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _pagingSrollView.delegate = self;
    _pagingSrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 3, 0);
    _pagingSrollView.showsHorizontalScrollIndicator = NO;
    _pagingSrollView.pagingEnabled = YES;
    _pagingSrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    [self.view addSubview:_pagingSrollView];
    _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.pagingSrollView.bounds.size.height)];
    _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.pagingSrollView.bounds.size.height)];
    _centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width*2, 0, self.view.bounds.size.width, self.pagingSrollView.bounds.size.height)];
    _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_pagingSrollView addSubview:_leftImageView];
    [_pagingSrollView addSubview:_centerImageView];
    [_pagingSrollView addSubview:_rightImageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateImgs];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showHighQualityImage:self.centerImageView index:self.index];
}

- (void) updateImgs
{
    if(self.index > 0){
        [self requestTargetImage:self.leftImageView index:self.index-1];
    }
    [self requestTargetImage:self.centerImageView index:self.index];
    if(self.index < self.assetsFetchResults.count - 1){
        [self requestTargetImage:self.rightImageView index:self.index+1];
    }
}

- (void) updateTitle
{
    if([self.checkedImgs containsObject:[NSNumber numberWithInteger:self.index]]){
        [_checkBtn setIndex:[self.checkedImgs indexOfObject:[NSNumber numberWithInteger:self.index]]];
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

- (void) requestTargetImage : (UIImageView *) imageView index : (NSUInteger) index
{
    imageView.image = nil;
    imageView.tag = 0;
    [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)(imageView.tag)];
    __block PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:[self.assetsFetchResults objectAtIndex:index] targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:fastOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result) {
            return;
        }
        if(self.leftImageView.tag == requestID){
            self.leftImageView.image = result;
        }else if(self.centerImageView.tag == requestID){
            self.centerImageView.image = result;
        }else if(self.rightImageView.tag == requestID){
            self.rightImageView.image = result;
        }
    }];
    imageView.tag = requestID;
}

- (void) showHighQualityImage : (UIImageView *) imageView index : (NSUInteger) index
{
    [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)(imageView.tag)];
    __block PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:[self.assetsFetchResults objectAtIndex:index] targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:highQualityOptions resultHandler:^(UIImage *result, NSDictionary *info) {
        if (!result) {
            return;
        }
        if(self.leftImageView.tag == requestID){
            self.leftImageView.image = result;
        }else if(self.centerImageView.tag == requestID){
            self.centerImageView.image = result;
        }else if(self.rightImageView.tag == requestID){
            self.rightImageView.image = result;
        }
    }];
    imageView.tag = requestID;
}

- (void) resetScrollPosition
{
    if(_pagingSrollView.contentOffset.x == 0){
        self.index --;
        if(self.index <= 0){
            self.index = 0;
            [self showHighQualityImage:self.leftImageView index:self.index];
            return;
        }
        self.rightImageView.tag = self.centerImageView.tag;
        self.rightImageView.image = self.centerImageView.image;
        self.centerImageView.tag = self.leftImageView.tag;
        self.centerImageView.image = self.leftImageView.image;
        if(self.index > 0){
            [self requestTargetImage:self.leftImageView index:self.index-1];
        }else{
            self.leftImageView.tag = 0;
            self.leftImageView.image = nil;
        }
        [self showHighQualityImage:self.centerImageView index:self.index];
        _pagingSrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    }else if(_pagingSrollView.contentOffset.x == self.view.bounds.size.width * 2){
        self.index ++;
        if(self.index >= self.assetsFetchResults.count - 1){
            self.index = self.assetsFetchResults.count - 1;
            [self showHighQualityImage:self.rightImageView index:self.index];
            return;
        }
        self.leftImageView.tag = self.centerImageView.tag;
        self.leftImageView.image = self.centerImageView.image;
        self.centerImageView.tag = self.rightImageView.tag;
        self.centerImageView.image = self.rightImageView.image;
        if(self.index < self.assetsFetchResults.count - 1){
            [self requestTargetImage:self.rightImageView index:self.index+1];
        }else{
            self.rightImageView.tag = 0;
            self.rightImageView.image = nil;
        }
        [self showHighQualityImage:self.centerImageView index:self.index];
        _pagingSrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    }else if(_pagingSrollView.contentOffset.x == self.view.bounds.size.width){
        if(self.index == 0){
            self.index = 1;
        }else if(self.index == self.assetsFetchResults.count - 1){
            self.index = self.assetsFetchResults.count - 2;
        }
    }
}

- (CGSize)targetSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.pagingSrollView.bounds) * scale, CGRectGetHeight(self.pagingSrollView.bounds) * scale);
    return targetSize;
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self resetScrollPosition];
        [self updateTitle];
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self resetScrollPosition];
    [self updateTitle];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetScrollPosition];
    [self updateTitle];
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
        [self updateImgs];
    });
}

@end
