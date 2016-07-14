//
//  GalaryRootTableViewController.m
//  Galary
//
//  Created by joshuali on 16/6/24.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryRootTableViewController.h"
#import "GalaryGridViewController.h"
#import "GalaryRootTableViewCell.h"
#import "GalaryHelper.h"

typedef void(^PickCompleteBlock)(NSArray<PHAsset*>* assets);
typedef void(^CustomPickerHandler)(NSUInteger index);

@interface GalaryRootTableViewController ()<PHPhotoLibraryChangeObserver>
{
    PickCompleteBlock mPickComplete;
    BOOL mIncrementalCount;
    NSArray * mCustomPickers;
    CustomPickerHandler mCustomPickerHandler;
    NSUInteger mMaxCount;
}
@property (nonatomic, strong) NSArray *sectionFetchResults;
@end

@implementation GalaryRootTableViewController

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (instancetype) initWithIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete withCustomPicker : (NSArray<UIImage*>*) customPickers withCustomPickerHandler : (void (^)(NSUInteger index)) customPickerHandler maxCount : (NSUInteger) maxCount
{
    self = [super init];
    if(self){
        mPickComplete = pickComplete;
        mIncrementalCount = incrementalCount;
        mCustomPickers = customPickers;
        mCustomPickerHandler = customPickerHandler;
        mMaxCount = maxCount;
        
        UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:0 target:nil action:nil];
        [self.navigationItem setBackBarButtonItem:bar];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.tableView registerNib:[UINib nibWithNibName:@"GalaryRootTableViewCell" bundle:nil] forCellReuseIdentifier:@"GalaryRootTableViewCell"];
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    
    PHFetchResult *recentAdded = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    
    PHFetchResult *screenShots = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
    
    self.sectionFetchResults = @[allPhotos, recentAdded, screenShots];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void) cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionFetchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        // The "All Photos" section only ever has a single row.
        numberOfRows = 1;
    } else {
        PHFetchResult *fetchResult = self.sectionFetchResults[section];
        numberOfRows = fetchResult.count;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GalaryRootTableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GalaryRootTableViewCell" forIndexPath:indexPath];
        cell.title.text = [GalaryHelper convertAlbumName:@"All Photos"];
        PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        PHAsset * asset = [fetchResult firstObject];
        cell.representedAssetIdentifier = asset.localIdentifier;
        [[[PHCachingImageManager alloc] init] requestImageForAsset:asset
                targetSize:CGSizeMake(80,80) contentMode:PHImageContentModeAspectFill
                    options:nil
                    resultHandler:^(UIImage *result, NSDictionary *info) {
                        if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                                cell.thumb.image = result;
                        }
                    }];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"GalaryRootTableViewCell" forIndexPath:indexPath];
        PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        PHCollection *collection = fetchResult[indexPath.row];
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        PHAsset * asset = [assetsFetchResult firstObject];
        cell.representedAssetIdentifier = asset.localIdentifier;
        [[[PHCachingImageManager alloc] init] requestImageForAsset:asset
             targetSize:CGSizeMake(80,80) contentMode:PHImageContentModeAspectFill
            options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
                if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                    cell.thumb.image = result;
                }
            }];
        cell.title.text = [GalaryHelper convertAlbumName:collection.localizedTitle];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)cell didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GalaryGridViewController *assetGridViewController = [[GalaryGridViewController alloc] initWithIncrementalCount:mIncrementalCount withPickComplete:mPickComplete withCustomPicker:mCustomPickers withCustomPickerHandler:mCustomPickerHandler maxCount:mMaxCount];
    if (indexPath.section == 0) {
        PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        assetGridViewController.centerTitle = [GalaryHelper convertAlbumName:@"All Photos"];
        assetGridViewController.assetsFetchResults = fetchResult;
    }else{
        PHFetchResult *fetchResult = self.sectionFetchResults[indexPath.section];
        PHCollection *collection = fetchResult[indexPath.row];
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        assetGridViewController.centerTitle = [GalaryHelper convertAlbumName:collection.localizedTitle];
        assetGridViewController.assetsFetchResults = assetsFetchResult;
    }
    [self.navigationController pushViewController:assetGridViewController animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [self.sectionFetchResults mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [self.sectionFetchResults enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            
            if (changeDetails != nil) {
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:[changeDetails fetchResultAfterChanges]];
                reloadRequired = YES;
            }
        }];
        
        if (reloadRequired) {
            self.sectionFetchResults = updatedSectionFetchResults;
            [self.tableView reloadData];
        }
        
    });
}

@end
