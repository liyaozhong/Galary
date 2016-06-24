//
//  GalaryHelper.m
//  Galary
//
//  Created by joshuali on 16/6/24.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "GalaryHelper.h"
#import "GalaryRootTableViewController.h"
#import "GalaryGridViewController.h"

@implementation GalaryHelper

+ (void) presentGalary : (UIViewController *) viewController
{
    UINavigationController * nav = [[UINavigationController alloc] init];
    [nav setViewControllers:@[[GalaryRootTableViewController new], [GalaryGridViewController new]]];
    [viewController presentViewController:nav animated:YES completion:nil];
}

@end
