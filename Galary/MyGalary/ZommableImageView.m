//
//  ZommableImageView.m
//  Galary
//
//  Created by joshuali on 16/6/28.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "ZommableImageView.h"

#define kZoomStep 2

@interface ZommableImageView ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIImageView * imageView;
@end

@implementation ZommableImageView

- (instancetype) init
{
    self = [super init];
    if(self){
        [self setupView];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

- (void) setupView
{
    self.delegate = self;
    self.imageView = nil;
    
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = TRUE;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    
    UITapGestureRecognizer *scrollViewDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewDoubleTap:)];
    [scrollViewDoubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:scrollViewDoubleTap];
    
    UITapGestureRecognizer *scrollViewTwoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScrollViewTwoFingerTap:)];
    [scrollViewTwoFingerTap setNumberOfTouchesRequired:2];
    [self addGestureRecognizer:scrollViewTwoFingerTap];
}

- (void) setUpImage:(UIImage *) image
{
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.userInteractionEnabled = TRUE;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [twoFingerTap setNumberOfTouchesRequired:2];
    
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:twoFingerTap];
    
    self.contentSize = self.imageView.frame.size;
    
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setZoomScale:self.minimumZoomScale animated:FALSE];
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    CGSize boundsSize = self.bounds.size;
    
    CGFloat minScale = 0.25;
    
    if (self.imageView.bounds.size.width > 0.0 && self.imageView.bounds.size.height > 0.0) {
        // calculate min/max zoomscale
        CGFloat xScale = boundsSize.width  / self.imageView.bounds.size.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / self.imageView.bounds.size.height;   // the scale needed to perfectly fit the image height-wise
        
        //        xScale = MIN(1, xScale);
        //        yScale = MIN(1, yScale);
        
        minScale = MIN(xScale, yScale);
    }
    
    CGFloat maxScale = minScale * (kZoomStep * 2);
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

- (CGPoint)adjustPointIntoImageView:(CGPoint)center {
    BOOL contains = CGRectContainsPoint(self.imageView.frame, center);
    if (!contains) {
        center.x = center.x / self.zoomScale;
        center.y = center.y / self.zoomScale;
        
        // adjust center with bounds and scale to be a point within the image view bounds
        CGRect imageViewBounds = self.imageView.bounds;
        
        center.x = MAX(center.x, imageViewBounds.origin.x);
        center.x = MIN(center.x, imageViewBounds.origin.x + imageViewBounds.size.height);
        
        center.y = MAX(center.y, imageViewBounds.origin.y);
        center.y = MIN(center.y, imageViewBounds.origin.y + imageViewBounds.size.width);
        
        return center;
    }
    
    return CGPointZero;
}

- (void)updateZoomScale:(CGFloat)newScale {
    CGPoint center = CGPointMake(self.imageView.bounds.size.width/ 2.0, self.imageView.bounds.size.height / 2.0);
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScaleWithGesture:(UIGestureRecognizer *)gestureRecognizer newScale:(CGFloat)newScale {
    CGPoint center = [gestureRecognizer locationInView:gestureRecognizer.view];
    [self updateZoomScale:newScale withCenter:center];
}

- (void)updateZoomScale:(CGFloat)newScale withCenter:(CGPoint)center {
    assert(newScale >= self.minimumZoomScale);
    assert(newScale <= self.maximumZoomScale);
    
    if (self.zoomScale != newScale) {
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:center];
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    //    assert(scale >= self.minimumZoomScale);
    //    assert(scale <= self.maximumZoomScale);
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    zoomRect.size.width = self.frame.size.width / scale;
    zoomRect.size.height = self.frame.size.height / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

#pragma mark - imageview gestures

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.zoomScale == self.maximumZoomScale) {
        // jump back to minimum scale
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:self.minimumZoomScale];
    }
    else {
        // double tap zooms in
        CGFloat newScale = self.maximumZoomScale;
        [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
    }
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    CGFloat newScale = MAX([self zoomScale] / kZoomStep, self.minimumZoomScale);
    [self updateZoomScaleWithGesture:gestureRecognizer newScale:newScale];
}

#pragma mark - scrollview gestures

- (void)handleScrollViewDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imageView.image == nil) return;
    CGPoint center =[self adjustPointIntoImageView:[gestureRecognizer locationInView:gestureRecognizer.view]];
    
    if (!CGPointEqualToPoint(center, CGPointZero)) {
        CGFloat newScale = MIN([self zoomScale] * kZoomStep, self.maximumZoomScale);
        [self updateZoomScale:newScale withCenter:center];
    }
}

- (void)handleScrollViewTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.imageView.image == nil) return;
    CGPoint center =[self adjustPointIntoImageView:[gestureRecognizer locationInView:gestureRecognizer.view]];
    
    if (!CGPointEqualToPoint(center, CGPointZero)) {
        CGFloat newScale = MAX([self zoomScale] / kZoomStep, self.minimumZoomScale);
        [self updateZoomScale:newScale withCenter:center];
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    if(xcenter > scrollView.frame.size.width){
        xcenter = scrollView.frame.size.width / 2;
    }
    if(ycenter > scrollView.frame.size.height){
        ycenter = scrollView.frame.size.height / 2;
    }
    
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    _imageView.center = CGPointMake(xcenter, ycenter);
}

@end
