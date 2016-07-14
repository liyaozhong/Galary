//
//  GalaryHelper.h
//  Galary
//
//  Created by joshuali on 16/6/24.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@import Photos;

@interface GalaryHelper : NSObject

+ (instancetype) sharedInstance;
+ (NSString *) convertAlbumName : (NSString *) name;

- (void) presentGalary : (UIViewController *) viewController withIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete withCustomPicker : (NSArray<UIImage*>*) customPickers withCustomPickerHandler : (void (^)(NSUInteger index)) customPickerHandler maxCount : (NSUInteger) maxCount;
- (void) presentPagingGalary : (UIViewController *) viewController withIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete withAssets : (NSArray<PHAsset*>*) assets index : (NSInteger) index;

- (void) dismiss;

- (UINavigationController *) getCurNav;

@end
