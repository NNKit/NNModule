//
//  NNViewController.m
//  NNModule
//
//  Created by ws00801526 on 12/22/2017.
//  Copyright (c) 2017 ws00801526. All rights reserved.
//

#import "NNViewController.h"

@interface NNViewController ()

@end

@implementation NNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSURL *URL = [NSURL URLWithString:@"icare://call.service.selector.router/NNMockServiceModel.NNMockService.serviceInstanceCode?params=%7b%5c%22title%5c%22%3a%5c%22name%5c%22%7d"];
//    [NNRouter openURL:URL userInfo:nil completionHandler:^(id  _Nullable target, id  _Nullable result) {
//        NSLog(@"this is target :%@", target);
//        NSLog(@"this is result :%@", result);
//    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)printHelloWorld {
    NSLog(@"Hello World");
}

@end
