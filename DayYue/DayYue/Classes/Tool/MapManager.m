//
//  MapManager.m
//  klxc
//
//  Created by sctto on 16/4/14.
//  Copyright © 2016年 sctto. All rights reserved.
//

#import "MapManager.h"

@interface MapManager ()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager        *locationManager;
@property (nonatomic,  copy) CLManagerCompleteBlock    block;
@end

@implementation MapManager

+ (MapManager *)sharedInstance{
    static dispatch_once_t once;
    static MapManager *__singleton__;
    dispatch_once(&once, ^{
        __singleton__ = [[MapManager alloc] init];
    });
    return __singleton__;
}

/** 由于IOS8中定位的授权机制改变 需要进行手动授权
 * 获取授权认证，两个方法：
 * [self.locationManager requestWhenInUseAuthorization];
 * [self.locationManager requestAlwaysAuthorization];
 */
-(instancetype)init{
    if (self = [super init]) {
        if([CLLocationManager locationServicesEnabled]) {
            if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
                if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    DLog(@"requestWhenInUseAuthorization");
                    [self.locationManager requestWhenInUseAuthorization]; // 在使用时请求一直定位
                }
            }
        }else{
            NSLog(@"无法定位");
        }
    }
    return self;
}

-(void)startSearchLocation{
    if (self.locationManager) {
        [self.locationManager startUpdatingLocation];
    }else{
        [self locationWithIp];
    }
}

- (void)locationWithIp{
    [self locationWithCLLocation:nil];
}

- (void)locationWithCLLocation:(CLLocation *)aLocation{
    [self locationWithCLLocation:aLocation andCLPlacemark:nil];
}

- (void)locationWithCLLocation:(CLLocation *)aLocation andCLPlacemark:(CLPlacemark *)aMark{
    DLog(@"国家:%@ 城市:%@ 区:%@ 具体位置:%@", aMark.country, aMark.locality, aMark.subLocality, aMark.name);
    DLog(@"纬度%0.12f 经度%0.8f", aLocation.coordinate.latitude, aLocation.coordinate.longitude);

    if (aLocation != nil) {
        CLLocationCoordinate2D coordinate = aLocation.coordinate;
        DLog(@"纬度:%f 经度:%f", coordinate.latitude, coordinate.longitude);
//        [YJTool setObject:[NSString stringWithFormat:@"%0.12f",aLocation.coordinate.latitude] forKey:LatitudeKey];
//        [YJTool setObject:[NSString stringWithFormat:@"%0.8f",aLocation.coordinate.longitude] forKey:LongitudeKey];
    }
    
    if (self.block) {
        self.block(aMark, aMark.addressDictionary, aLocation);
        self.block = nil;
    }
}

- (void)startWithCompleteBlock:(CLManagerCompleteBlock)block{
    self.block = block;
    [self startSearchLocation];
}

-(void)stopSearchLocation{
    self.block=nil;
    [self.locationManager stopUpdatingLocation];
}

//通过定位信息获取城市信息
- (void)locationToCityName:(CLLocation *)aLocation{
    WEAK_SELF
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:aLocation completionHandler:^(NSArray *placemark, NSError *error) {
        STRONG_SELF
        CLPlacemark *mark = nil;
        if (error) {
            DLog(@"error = %@",error);
            [self locationWithCLLocation:aLocation];
        }else {
            mark = [placemark objectAtIndex:0];
            DLog(@"mark %@", mark);
            DLog(@"dict %@", mark.addressDictionary);
            DLog(@"Country %@", mark.addressDictionary[@"Country"]);
            DLog(@"State %@", mark.addressDictionary[@"State"]);
            DLog(@"City %@", mark.addressDictionary[@"City"]);
        
            [self locationWithCLLocation:aLocation andCLPlacemark:mark];
        }
    }];
}

#pragma mark 定位成功 iOS7 及其以后的新方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [self locationToCityName:locations[0]];
    [self.locationManager stopUpdatingLocation];
}

#pragma mark 定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    DLog(@"定位失败:error:%@", error.localizedDescription);
    [self locationWithIp];
    [self.locationManager stopUpdatingLocation];
}

- (void)dealloc{
    self.locationManager.delegate = nil;
}

-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 1000.f;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

@end
