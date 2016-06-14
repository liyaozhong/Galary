//
//  GalaryGridCollectionViewCell.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryGridCollectionViewCell.h"

#define CHECK_IMAGE_SIZE  20

@interface GalaryGridCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@end

@implementation GalaryGridCollectionViewCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.indexPath = nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}

- (void) setChecked : (BOOL) checked withAnimation : (BOOL) withAnimation
{
    self.checkImageView.image = [UIImage imageNamed:checked ? @"galary_selected":@"galary_unselected"];
    if(withAnimation && checked){
        self.checkImageView.bounds = CGRectMake(0, 0, CHECK_IMAGE_SIZE/2, CHECK_IMAGE_SIZE/2);
        self.checkImageView.alpha = 0.5f;
        [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:0 animations:^{
            self.checkImageView.bounds = CGRectMake(0, 0, CHECK_IMAGE_SIZE, CHECK_IMAGE_SIZE);
            self.checkImageView.alpha = 1;
        } completion:nil];
    }
}

- (IBAction)onCheckBtnClick:(id)sender
{
    if(self.delegate){
        [self.delegate galaryGridCell:self onCheckButtonClick:self.indexPath];
    }
}

@end
