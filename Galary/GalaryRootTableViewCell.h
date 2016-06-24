//
//  GalaryRootTableViewCell.h
//  Galary
//
//  Created by joshuali on 16/6/24.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalaryRootTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView * thumb;
@property (nonatomic, weak) IBOutlet UILabel * title;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@end
