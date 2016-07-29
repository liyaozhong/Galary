//
//  GalaryGridViewController.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryGridViewController.h"
#import "GalaryGridCollectionViewCell.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"
#import "GalaryPagingViewController.h"
#import "GalaryHelper.h"

typedef void(^PickCompleteBlock)(NSArray<PHAsset*>* assets);
typedef void(^CustomPickerHandler)(NSUInteger index);

@interface GalaryGridViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver, GalaryGridCollectionViewCellDelegate>
{
    NSUInteger curAnimIndex;
    PickCompleteBlock mPickComplete;
    BOOL mIncrementalCount;
    NSArray * mCustomPickers;
    CustomPickerHandler mCustomPickerHandler;
    NSUInteger mMaxCount;
}
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) CheckView * bottomCheckView;
@property (nonatomic, strong) UIButton * bottomButton;
@property (nonatomic, strong) NSMutableArray * checkedImgs;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;
@end

@implementation GalaryGridViewController

static CGSize AssetGridThumbnailSize;

- (instancetype) initWithIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete withCustomPicker : (NSArray<UIImage*>*) customPickers withCustomPickerHandler : (void (^)(NSUInteger index)) customPickerHandler maxCount : (NSUInteger) maxCount
{
    self = [super init];
    if(self){
        mPickComplete = pickComplete;
        mIncrementalCount = incrementalCount;
        mCustomPickers = customPickers;
        mCustomPickerHandler = customPickerHandler;
        mMaxCount = maxCount;
    }
    return self;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if(self.centerTitle){
        self.navigationItem.title = self.centerTitle;
    }else{
        self.navigationItem.title = [GalaryHelper convertAlbumName:@"All Photos"];
    }
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightButton;
    if(!_assetsFetchResults){
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        _assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    }
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    AssetGridThumbnailSize = CGSizeMake(self.view.bounds.size.width/4 * [UIScreen mainScreen].scale, self.view.bounds.size.width/4 * [UIScreen mainScreen].scale);
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width/4 - 0.5f, self.view.bounds.size.width/4 - 0.5f);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 1;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40) collectionViewLayout:flowLayout];
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:@"GalaryGridCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"GalaryGridCollectionViewCell"];
    
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    bottomView.backgroundColor = [UIColor colorWithRed:247.0f/255 green:247.0f/255 blue:247.0f/255 alpha:1];
    [self.view addSubview:bottomView];
    
    UIView * topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5f)];
    topLine.backgroundColor = [UIColor colorWithRed:221.0f/255 green:221.0f/255 blue:221.0f/255 alpha:1];
    [bottomView addSubview:topLine];
    _bottomButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 5 - 50, 0, 50, 40)];
    [_bottomButton setTitleColor:[UIColor colorWithRed:74.0f/255 green:74.0f/255 blue:74.0f/255 alpha:1] forState:UIControlStateNormal];
    [_bottomButton setTitle:@"发送" forState:UIControlStateNormal];
    [_bottomButton addTarget:self action:@selector(onSendClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_bottomButton];
    _bottomCheckView = [[CheckView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 5 - 50 - 5 - 20, 10, 20, 20)];
    _bottomCheckView.backgroundColor = [UIColor clearColor];
    _bottomCheckView.hidden = YES;
    [_bottomCheckView setChecked:YES];
    [_bottomCheckView setShowIndex:YES];
    [bottomView addSubview:_bottomCheckView];
}

- (void) cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    [self updateBottomView];
}

- (void) onSendClick
{
    if(mPickComplete){
        NSMutableArray<PHAsset *> * assets = [NSMutableArray new];
        for(NSNumber * index in self.checkedImgs){
            PHAsset *asset = self.assetsFetchResults[index.intValue];
            [assets addObject:asset];
        }
        mPickComplete(assets);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) updateBottomView
{
    NSUInteger count = self.checkedImgs.count;
    _bottomButton.enabled = count > 0;
    if(count > 0){
        _bottomCheckView.hidden = NO;
        [_bottomCheckView setIndex:count];
    }else{
        _bottomCheckView.hidden = YES;
    }
}

- (NSMutableArray *) checkedImgs
{
    if(!_checkedImgs){
        _checkedImgs = [NSMutableArray new];
    }
    return _checkedImgs;
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
        // Get the new fetch result.
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = self.collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
        
        [self resetCachedAssets];
    });
}

#pragma mark - GalaryGridCollectionViewCellDelegate

- (void) galaryGridCell:(GalaryGridCollectionViewCell *)cell onCheckButtonClick:(NSIndexPath *)indexPath
{
    if([self.checkedImgs containsObject:[NSNumber numberWithInteger:indexPath.item - mCustomPickers.count]]){
        [self.checkedImgs removeObject:[NSNumber numberWithInteger:indexPath.item - mCustomPickers.count]];
        curAnimIndex = NSNotFound;
    }else if(self.checkedImgs.count >= mMaxCount){
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"最多选%lu张图片", (unsigned long)mMaxCount] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [self.checkedImgs addObject:[NSNumber numberWithInteger:indexPath.item - mCustomPickers.count]];
        curAnimIndex = indexPath.item - mCustomPickers.count;
    }
    [self.collectionView reloadData];
    [self updateBottomView];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.item < mCustomPickers.count){
        if(mCustomPickerHandler){
            mCustomPickerHandler(indexPath.item);
        }
    }else{
        GalaryPagingViewController * galaryPaging = [[GalaryPagingViewController alloc] initWithIncrementalCount:mIncrementalCount withPickComplete:^(NSArray<PHAsset *> *assets) {
            [self onSendClick];
        } maxCount:mMaxCount];
        galaryPaging.assetsFetchResults = self.assetsFetchResults;
        galaryPaging.index = indexPath.item - mCustomPickers.count;
        galaryPaging.checkedImgs = self.checkedImgs;
        [self.navigationController pushViewController:galaryPaging animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return mCustomPickers.count + self.assetsFetchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalaryGridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalaryGridCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.representedAssetIdentifier = nil;
    if(indexPath.item < mCustomPickers.count){
        [cell setChecked:NSNotFound withAnimation:NO withIncrementalCount:NO shouldShowCheck:NO];
        cell.thumbnailImage = [mCustomPickers objectAtIndex:indexPath.item];
    }else{
        BOOL isAnimCell = curAnimIndex == (indexPath.item - mCustomPickers.count);
        if(isAnimCell){
            curAnimIndex = NSNotFound;
        }
        PHAsset *asset = self.assetsFetchResults[indexPath.item - mCustomPickers.count];
        
        [cell setChecked:[self.checkedImgs indexOfObject:[NSNumber numberWithInteger:indexPath.item - mCustomPickers.count]] withAnimation:isAnimCell withIncrementalCount:mIncrementalCount shouldShowCheck:YES];
        cell.representedAssetIdentifier = asset.localIdentifier;
        
        // Request an image for the asset from the PHCachingImageManager.
        [self.imageManager requestImageForAsset:asset
                                     targetSize:AssetGridThumbnailSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      // Set the cell's thumbnail image if it's still showing the same asset.
                                      if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                          cell.thumbnailImage = result;
                                      }
                                  }];
    }
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if(indexPath.item >= mCustomPickers.count){
            PHAsset *asset = self.assetsFetchResults[indexPath.item - mCustomPickers.count];
            [assets addObject:asset];
        }
    }
    
    return assets;
}

@end
