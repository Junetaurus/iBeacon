//
//  ViewController.m
//  iBeaconDemo
//
//  Created by LaiYoung_ on 2018/2/4.
//  Copyright © 2018年 LaiYoung_. All rights reserved.
//

#import "ViewController.h"
#import "ConfigurationBeaconViewController.h"
#import "SimulationBeaconViewController.h"
#import "DiscoverBeaconViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"iBeacon";
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = (id)self;
        _tableView.dataSource = (id)self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"配置 Beacon";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"模拟 Beacon";
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"扫描 Beacon";
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIStoryboard *storeboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    if (indexPath.row == 0) {
        ConfigurationBeaconViewController *vc = [storeboard instantiateViewControllerWithIdentifier:@"ConfigurationBeaconViewController"];
        vc.title = cell.textLabel.text;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        SimulationBeaconViewController *vc = [storeboard instantiateViewControllerWithIdentifier:@"SimulationBeaconViewController"];
        vc.title = cell.textLabel.text;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 2) {
        DiscoverBeaconViewController *vc = [[DiscoverBeaconViewController alloc] init];
        vc.title = cell.textLabel.text;
        vc.tag = ScanBeacon;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

