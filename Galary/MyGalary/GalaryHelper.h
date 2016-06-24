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
+ (void) presentGalary : (UIViewController *) viewController withIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete;
@end
