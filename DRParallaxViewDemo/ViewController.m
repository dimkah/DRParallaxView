//
//  ViewController.m
//  DRParallaxViewDemo
//
//  Created by dimkahr on 10/30/15.
//  Copyright © 2015 Dmitriy Romanov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[self initdrPView1];
    [self initdrPView2];
    
    DRParallaxView *drPRView = [[DRParallaxView alloc] initWithFrame:CGRectMake(10, 10, 300, 200)];
    [drPRView setLayersWithImages:@[@"0", @"1", @"6", @"2", @"3", @"5"]];
    [drPRView setNeedHighlight:false]; // default true
    [drPRView setGyroMotion:true]; // default false
    [self.view addSubview:drPRView];
}

//- (void)initdrPView1{
//    [_drPView1 setLayersWithImages:@[@"0", @"1", @"6", @"2", @"3", @"5"]];
//    [_drPView1 setNeedHighlight:false];
//}

- (void)initdrPView2{
    [_drPView2 setLayersWithImages:@[@"s0", @"s1", @"s2", @"s3"]];
    [_drPView2 setGyroMotion:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
