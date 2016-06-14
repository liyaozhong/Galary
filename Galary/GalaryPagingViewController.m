//
//  GalaryPagingViewController.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryPagingViewController.h"

@interface GalaryPagingViewController ()<PHPhotoLibraryChangeObserver, UIScrollViewDelegate>
{
    PHImageRequestOptions *options;
}
@property (nonatomic, strong) UIScrollView * pagingSrollView;
@property (nonatomic, strong) UIImageView * leftImageView;
@property (nonatomic, strong) UIImageView * centerImageView;
@property (nonatomic, strong) UIImageView * rightImageView;
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
}

- (void) setupView
{
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

- (void) updateImgs
{
    if(!options){
        options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.networkAccessAllowed = YES;
    }
    
    if(self.index > 0){
        [self requestTargetImage:self.leftImageView index:self.index-1];
    }
    [self requestTargetImage:self.centerImageView index:self.index];
    if(self.index < self.assetsFetchResults.count - 1){
        [self requestTargetImage:self.rightImageView index:self.index+1];
    }
}

- (void) requestTargetImage : (UIImageView *) imageView index : (NSUInteger) index
{
    imageView.image = nil;
    imageView.tag = 0;
    [[PHImageManager defaultManager] cancelImageRequest:(PHImageRequestID)(imageView.tag)];
    __block PHImageRequestID requestID = [[PHImageManager defaultManager] requestImageForAsset:[self.assetsFetchResults objectAtIndex:index] targetSize:[self targetSize] contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
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
        _pagingSrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    }else if(_pagingSrollView.contentOffset.x == self.view.bounds.size.width * 2){
        self.index ++;
        if(self.index >= self.assetsFetchResults.count - 1){
            self.index = self.assetsFetchResults.count - 1;
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
        _pagingSrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
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
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self resetScrollPosition];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetScrollPosition];
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
