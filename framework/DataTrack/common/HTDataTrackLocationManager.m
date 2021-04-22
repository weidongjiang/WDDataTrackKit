//
//  HTDataTrackLocationManager.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/26.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackLocationManager.h"
#import "HTDataTrackDefine.h"

#define kSADefaultDistanceFilter 100.0
#define kSADefaultDesiredAccuracy kCLLocationAccuracyHundredMeters

@interface HTDataTrackLocationManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isUpdatingLocation;

@end


@implementation HTDataTrackLocationManager
- (instancetype)init {
    if (self = [super init]) {
        //默认设置设置精度为 100 ,也就是 100 米定位一次 ；准确性 kCLLocationAccuracyHundredMeters
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kSADefaultDesiredAccuracy;
        self.locationManager.distanceFilter = kSADefaultDistanceFilter;
        self.isUpdatingLocation = NO;
    }
    return self;
}

- (void)startUpdatingLocation {
    @try {
        //判断当前设备定位服务是否打开
        if (![CLLocationManager locationServicesEnabled]) {
            HTDTLog(@"Logger:LocationManager：设备尚未打开定位服务");
            return;
        }
        if (@available(iOS 8.0, *)) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        if (_isUpdatingLocation == NO) {
            [self.locationManager startUpdatingLocation];
            _isUpdatingLocation = YES;
        }
    }@catch (NSException *e) {
        HTDTLog(@"Logger:LocationManager：%@ error: %@", self, e);
    }
}

- (void)stopUpdatingLocation {
    @try {
        if (_isUpdatingLocation) {
            [self.locationManager stopUpdatingLocation];
            _isUpdatingLocation = NO;
        }
    }@catch (NSException *e) {
       HTDTLog(@"Logger:LocationManager：%@ error: %@", self, e);
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations API_AVAILABLE(ios(6.0), macos(10.9)) {
    @try {
        if (self.updateLocationBlock) {
            self.updateLocationBlock(locations.lastObject, nil);
        }
    }@catch (NSException * e) {
         HTDTLog(@"Logger:LocationManager：%@ error: %@", self, e);
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    @try {
        if (self.updateLocationBlock) {
            self.updateLocationBlock(nil, error);
        }
    }@catch (NSException * e) {
         HTDTLog(@"Logger:LocationManager：%@ error: %@", self, e);
    }
}

@end

@implementation HTDataTrackGPSLocationConfig
- (instancetype)init {
    if (self = [super init]) {
        self.enableGPSLocation = NO;
        self.coordinate = kCLLocationCoordinate2DInvalid;
    }
    return self;
}
@end
