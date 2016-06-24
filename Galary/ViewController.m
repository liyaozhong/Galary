//
//  ViewController.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "ViewController.h"
#import "GalaryHelper.h"

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
    [GalaryHelper presentGalary:self withIncrementalCount:YES withPickComplete:^(NSArray<PHAsset *> *assets) {
        
    }];
}

@end
