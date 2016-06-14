//
//  GalaryPagingViewController.h
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface GalaryPagingViewController : UIViewController
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property NSInteger index;
@property (nonatomic, strong) NSMutableSet * checkedImgs;
@end
