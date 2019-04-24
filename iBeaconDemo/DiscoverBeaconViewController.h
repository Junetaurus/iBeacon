//
//  DiscoverBeaconViewController.h
//  iBeaconDemo
//
//  Created by LaiYoung_ on 2018/2/4.
//  Copyright © 2018年 LaiYoung_. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FromBeaconViewTag) {
    DiscoverBeacon,
    ScanBeacon,
};

@interface DiscoverBeaconViewController : UIViewController

@property (nonatomic, assign) FromBeaconViewTag tag;
@property (nonatomic, copy) NSArray *equipmentArray;

@end
