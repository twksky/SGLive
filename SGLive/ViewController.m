//
//  ViewController.m
//  SGLive
//
//  Created by twksky on 2017/2/3.
//  Copyright © 2017年 twksky. All rights reserved.
//

#import "ViewController.h"
#import "SGHttpRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)btnclick:(id)sender{
    NSLog(@"点击");
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  @"1236568", @"uid",
                                  @1, @"type",
                                  nil];
    
    [[SGHttpRequest instance] asyncPostRequestWithEncrypt:RequestionGetLiveList content:dictM successBlock:^(NSData *data) {
        
        NSDictionary *resultDict = [self JsonDataToObject:data];
        
        NSLog(@"%@",resultDict);
        
    } failedBlock:^(NSError *error) {
        
        NSLog(@"");
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)JsonDataToObject:(NSData *)jsonData
{
    
    if ((jsonData == nil) || ([jsonData length] == 0)) {
        
        return nil;
    }
    
    NSError *error = nil;
    id      jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if ((jsonObject != nil) && (error == nil)) {
        return jsonObject;
    } else {
        
        return nil;
    }
}


@end
