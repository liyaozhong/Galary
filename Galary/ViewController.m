//
//  ViewController.m
//  Galary
//
//  Created by joshuali on 16/6/14.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "ViewController.h"
#import "GalaryHelper.h"
#import "TextViewController.h"

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
    [[GalaryHelper sharedInstance] presentGalary:self withIncrementalCount:NO withPickComplete:^(NSArray<PHAsset *> *assets) {
        NSLog(@"xxxxx %lu selected", (unsigned long)assets.count);
    } withCustomPicker:@[[UIImage imageNamed:@"take_photo"]] withCustomPickerHandler:^(NSUInteger index) {
        [[[GalaryHelper sharedInstance] getCurNav] pushViewController:[TextViewController new] animated:YES];
    }];
}

@end
