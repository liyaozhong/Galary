//
//  ViewController.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "ViewController.h"
#import "GalaryGridViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoGalary:(id)sender
{
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[GalaryGridViewController new]];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
