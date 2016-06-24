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
@property (weak, nonatomic) IBOutlet CheckView *checkView;
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

- (void) setChecked : (NSUInteger) index withAnimation : (BOOL) withAnimation withIncrementalCount : (BOOL) incrementalCout
{
    if(index != NSNotFound)
    {
        self.checkView.hidden = NO;
        [self.checkView setShowIndex:incrementalCout];
        [self.checkView setIndex:index+1];
        if(withAnimation){
            self.checkView.bounds = CGRectMake(0, 0, CHECK_IMAGE_SIZE/2, CHECK_IMAGE_SIZE/2);
            self.checkView.alpha = 0.5f;
            [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:0 animations:^{
                self.checkView.bounds = CGRectMake(0, 0, CHECK_IMAGE_SIZE, CHECK_IMAGE_SIZE);
                self.checkView.alpha = 1;
            } completion:nil];
        }
    }else{
        self.checkView.hidden = YES;
    }
}

- (IBAction)onCheckBtnClick:(id)sender
{
    if(self.delegate){
        [self.delegate galaryGridCell:self onCheckButtonClick:self.indexPath];
    }
}

@end
