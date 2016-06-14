//
//  GalaryGridCollectionViewCell.h
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GalaryGridCollectionViewCell;
@protocol GalaryGridCollectionViewCellDelegate <NSObject>

- (void) galaryGridCell : (GalaryGridCollectionViewCell *) cell onCheckButtonClick : (NSIndexPath *) indexPath;

@end

@interface GalaryGridCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id<GalaryGridCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
- (void) setChecked : (BOOL) checked withAnimation : (BOOL) withAnimation;
@end
