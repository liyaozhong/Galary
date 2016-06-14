//
//  CheckView.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "CheckView.h"

@interface CheckView ()
{
    NSUInteger index;
}
@end

@implementation CheckView

- (void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:71.0f/255 green:179.0f/255 blue:255.0f/255 alpha:1].CGColor);
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, MIN(rect.size.width/2, rect.size.height/2), 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    NSDictionary * atr = @{NSFontAttributeName : [UIFont systemFontOfSize:10], NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSString * indexStr = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    CGSize size = [indexStr sizeWithAttributes:atr];
    [indexStr drawInRect:CGRectMake((rect.size.width - size.width)/2, (rect.size.height - size.height)/2, size.width + 0.5f, size.height) withAttributes:atr];
}

- (void) setIndex : (NSUInteger) i
{
    index = i;
    [self setNeedsDisplay];
}

@end
