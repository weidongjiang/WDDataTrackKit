//
//  HTDataTrackLocationManager.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/26.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN



@interface HTDataTrackLocationManager : NSObject {
    CLLocationManager *_locationManager;
}
@property (nonatomic, copy) void(^updateLocationBlock)(CLLocation *location, NSError *error);
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end

NS_ASSUME_NONNULL_END


@interface HTDataTrackGPSLocationConfig : NSObject

@property (nonatomic, assign) BOOL enableGPSLocation; //default is NO .
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;//default is kCLLocationCoordinate2DInvalid

@end;
