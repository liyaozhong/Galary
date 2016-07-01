//
//  GalaryGridViewController.h
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface GalaryGridViewController : UIViewController
- (instancetype) initWithIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete withCustomPicker : (NSArray<UIImage*>*) customPickers withCustomPickerHandler : (void (^)(NSUInteger index)) customPickerHandler maxCount : (int) maxCount;
@property (nonatomic, copy) NSString * centerTitle;
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@end
