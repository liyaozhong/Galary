//
//  GalaryRootTableViewController.h
//  Galary
//
//  Created by joshuali on 16/6/24.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface GalaryRootTableViewController : UITableViewController
- (instancetype) initWithIncrementalCount : (BOOL) incrementalCount withPickComplete : (void (^)(NSArray<PHAsset*>* assets)) pickComplete;
@end
