//
//  MapManager.h
//  klxc
//
//  Created by sctto on 16/4/14.
//  Copyright © 2016年 sctto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^CLManagerCompleteBlock)(CLPlacemark *mark, NSDictionary *addressDictionary, CLLocation *aLocation);

@interface MapManager : NSObject

+ (MapManager *)sharedInstance;

- (void)startSearchLocation;

- (void)startWithCompleteBlock:(CLManagerCompleteBlock)block;

- (void)stopSearchLocation;

@end
