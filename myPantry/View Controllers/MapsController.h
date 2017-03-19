//
//  MapController.h
//  GoogleMapTest
//
//  Created by Melody Yang on 3/10/17.
//  Copyright © 2017 Melody Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface MapsController : UIViewController
@property(nonatomic,retain) CLLocationManager *locationManager;
- (IBAction)refresh:(UIButton *)sender;

@end

