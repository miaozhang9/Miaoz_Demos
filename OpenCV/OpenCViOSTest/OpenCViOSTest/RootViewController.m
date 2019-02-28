//
//  RootViewController.m
//  OpenCViOSTest
//
//  Created by Miaoz on 2017/6/18.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "RootViewController.h"

#import "ViewController.h"
#import "VideoViewController.h"

#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "DBCameraLibraryViewController.h"

#import "DBCameraGridView.h"
#import "GRCameraViewController.h"

@interface RootViewController ()<UITableViewDelegate, UITableViewDataSource,DBCameraViewControllerDelegate>

@property (nonatomic, strong) UITableView *defaultTableView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Opencv";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.defaultTableView];
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CVHomeListTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CVHomeListTableViewCell"];
    }
    if (indexPath.row == 0) {
         cell.textLabel.text = [NSString stringWithFormat:@"%@--%ld",self.dataArr[indexPath.row],indexPath.row];
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@--%ld",self.dataArr[indexPath.row],indexPath.row];
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@--%ld",self.dataArr[indexPath.row],indexPath.row];
    }
   
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {

        DBCameraContainerViewController *cameraContainer = [[DBCameraContainerViewController alloc] initWithDelegate:self];
        [cameraContainer setFullScreenMode];
        
//        [self.navigationController pushViewController:cameraContainer animated:YES];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cameraContainer];
        [nav setNavigationBarHidden:YES];
        [self presentViewController:nav animated:YES completion:nil];
        
    } else if (indexPath.row == 1) {
        VideoViewController * testVc = [VideoViewController new];
        testVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:testVc animated:YES];
    } else {
        GRCameraViewController *grCameraVC = [GRCameraViewController new];
        [self.navigationController pushViewController:grCameraVC animated:YES];
    
    }
    
    
}
//Use your captured image
#pragma mark - DBCameraViewControllerDelegate

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{  
    ViewController *detail = [[ViewController alloc] init];
     detail.getImage = image;
    [self.navigationController pushViewController:detail animated:NO];
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) dismissCamera:(id)cameraViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

#pragma mark - getter

- (UITableView *)defaultTableView {
    if (!_defaultTableView) {
        self.defaultTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _defaultTableView.delegate = self;
        _defaultTableView.dataSource = self;
        _defaultTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _defaultTableView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        self.dataArr = [NSMutableArray arrayWithObjects:@"opencv图片",@"opencv视频", @"GRCamera",nil];
    }
    return _dataArr;
}

@end
