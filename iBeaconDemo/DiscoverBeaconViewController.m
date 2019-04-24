//
//  DiscoverBeaconViewController.m
//  iBeaconDemo
//
//  Created by LaiYoung_ on 2018/2/4.
//  Copyright © 2018年 LaiYoung_. All rights reserved.
//

#import "DiscoverBeaconViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AIBBeaconRegionAny.h"
#import "AIBUtils.h"
#import "LocalPush.h"

@interface DiscoverBeaconViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSMutableArray *beaconRegionArray;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *dataDict;

@end

@implementation DiscoverBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
    //在开始监控之前，我们需要判断改设备是否支持，和区域权限请求
    BOOL availableMonitor = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    
    if (availableMonitor) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                [self.locationManager requestAlwaysAuthorization];
                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                NSLog(@"受限制或者拒绝");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:{
                if (_tag == DiscoverBeacon) {
                    for (NSDictionary *dic in self.equipmentArray) {
                        CLBeaconRegion *beaconRegion = [self beaconRegionWithUUID:dic[@"UUID"] major:dic[@"Major"] minor:dic[@"Minor"]];
                        if (beaconRegion) {
                            [self.beaconRegionArray addObject:beaconRegion];
                        }
                    }
                }
                //
                if (_tag == ScanBeacon) {
                    AIBBeaconRegionAny *beaconRegionAny = [[AIBBeaconRegionAny alloc] initWithIdentifier:@"Any"];
                    [self.locationManager requestWhenInUseAuthorization];
                    [self.locationManager startRangingBeaconsInRegion:beaconRegionAny];
                }
                
            }
                break;
        }
    } else {
        NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (NSMutableArray *)beaconRegionArray {
    if (!_beaconRegionArray) {
        _beaconRegionArray = [NSMutableArray array];
    }
    return _beaconRegionArray;
}

- (CLBeaconRegion *)beaconRegionWithUUID:(NSString *)uuid major:(NSString *)major minor:(NSString *)minor  {
    CLBeaconRegion *br = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:[major integerValue] minor:[minor integerValue] identifier:@"test"];
    if (br) {
        br.notifyEntryStateOnDisplay = YES;
        [self.locationManager startRangingBeaconsInRegion:br];
        [self.locationManager startMonitoringForRegion:br];
    }
    return br;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataDict.allKeys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataDict[_dataDict.allKeys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass(self.class)];
    }
    
    NSString *key = _dataDict.allKeys[indexPath.section];
    CLBeacon *beacon = [_dataDict valueForKey:key][indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Major:%@         Minor:%@",beacon.major,beacon.minor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"rssi:%ld       accuracy:%.1fm",(long)beacon.rssi,beacon.accuracy? : -1];
    cell.detailTextLabel.font = cell.textLabel.font;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = _dataDict.allKeys[section];
    NSArray *arr = [_dataDict valueForKey:key];
    return [NSString stringWithFormat:@"%lu - %@",(unsigned long)arr.count, key];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //
    NSString *key = _dataDict.allKeys[indexPath.section];
    CLBeacon *beacon = [_dataDict valueForKey:key][indexPath.row];
    //
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tip" message:[NSString stringWithFormat:@"UUID:%@\nMajor:%@\n:Minor:%@",beacon.proximityUUID.UUIDString,beacon.major, beacon.minor] preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    //
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status  {
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        for (CLBeaconRegion *beaconRegion in self.beaconRegionArray) {
            [self.locationManager startRangingBeaconsInRegion:beaconRegion];
            [self.locationManager startMonitoringForRegion:beaconRegion];
        }
    }
}

#pragma mark -- Monitoring
/** 进入区域 */
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region  {
    
}

/** 离开区域 */
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region  {
    
}

/** Monitoring有错误产生时的回调 */
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error {
    
}

/** Monitoring 成功回调 */
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    
}

#pragma mark -- Ranging
/** 1秒钟执行1次 */
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(nonnull NSArray<CLBeacon *> *)beacons inRegion:(nonnull CLBeaconRegion *)region {
    
    if (!_dataDict) {
        _dataDict = [NSMutableDictionary dictionary];
    }
    if (_tag == DiscoverBeacon) {
        if (beacons.count) {
            [_dataDict setObject:beacons forKey:region.proximityUUID.UUIDString];
        } else {
            [_dataDict removeObjectForKey:region.proximityUUID.UUIDString];
        }
    }
    if (_tag == ScanBeacon) {
        for (CLBeacon *beacon in beacons) {
            NSString *uuid = [beacon.proximityUUID UUIDString];
            NSMutableArray *list = [_dataDict objectForKey:uuid];
            if (!list) {
                list = [NSMutableArray array];
            }
            [list removeAllObjects];
            [list addObject:beacon];
            //
            [_dataDict setObject:list forKey:uuid];
        }
    }
    [self.tableView reloadData];
}

/** ranging有错误产生时的回调  */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error  {
    
}

#pragma mark -- Kill callBack
/** 杀掉进程之后的回调，直接锁屏解锁，会触发 */
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
        LocalPush *localNotification = [[LocalPush alloc] init];
        if ([region isKindOfClass:[CLBeaconRegion class]]) {
            CLBeaconRegion *bregion = (CLBeaconRegion *)region;
            NSString *body = [NSString stringWithFormat:@"status = %@,uuid = %@,major = %ld,minor = %ld",((state==CLRegionStateUnknown)?@"未知":(state=CLRegionStateInside)?@"区域内":@"区域外"),bregion.proximityUUID.UUIDString,(long)[bregion.major integerValue],(long)[bregion.minor integerValue]];
            localNotification.body = body;
            localNotification.soundName = nil;
            localNotification.delayTimeInterval = 0.0;
            [localNotification pushLocalNotification];
        }
}

@end
