//
//  MapController.m
//  GoogleMapTest
//
//  Created by Melody Yang on 3/10/17.
//  Copyright © 2017 Melody Yang. All rights reserved.
//

#import "MapsController.h"
@import GooglePlaces;
@import GooglePlacePicker;

@interface MapsController (){
    GMSMapView *mapView;
    GMSPlacePicker *_placePicker;
    __weak IBOutlet UIButton *refresh;
    double lat;
    double lon;
}

@end

@implementation NSNull (IntValue)
-(int)intValue { return 0 ; }
@end

@implementation MapsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    lat = _locationManager.location.coordinate.latitude;
    lon = _locationManager.location.coordinate.longitude;
    [_locationManager startUpdatingLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lon zoom:12 ];
    mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.settings.compassButton = YES;
    mapView.settings.myLocationButton = YES;
    mapView.settings.zoomGestures = YES;
    // Insets are specified in this order: top, left, bottom, right
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0);
    mapView.padding = mapInsets;
    [self.view insertSubview:mapView atIndex:0];
    
    [refresh sendActionsForControlEvents:UIControlEventTouchUpInside];
}

/*Generate Google Maps markers with the following:
 The search query to pull JSON, change loc to be current, make radius variable??
 https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=33.6839%2C-117.7947&radius=5000&type=grocery_or_supermarket&key=AIzaSyDXF8oOlysDPBXICvB9TlTjclEic7eQlFw*/
- (IBAction)refresh:(UIButton *)sender {
    NSLog(@"map reset");
    [mapView clear];
    lat = mapView.camera.target.latitude;
    lon = mapView.camera.target.longitude;
    NSLog(@"Latitude is===>>>%f",lat);
    NSLog(@"Longitude is===>>>%f",lon);
    NSString *base = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f", lat, lon];
    NSString *apiKey = @"AIzaSyDXF8oOlysDPBXICvB9TlTjclEic7eQlFw";
    base = [base stringByAppendingString:@"&radius=5000&type=grocery_or_supermarket&key="];
    base = [base stringByAppendingString:apiKey];
    
    NSURL * url=[NSURL URLWithString:base];
    NSData * data=[NSData dataWithContentsOfURL:url];
    NSError * error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *results = [json objectForKey:@"results"];
    NSArray *placeID = [results valueForKey:@"place_id"];
    NSArray *openStat = [json valueForKeyPath:@"results.opening_hours.open_now"];
    
    int i = 0;
    for (NSString *string in placeID) {
        GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
        _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
        [[GMSPlacesClient sharedClient] lookUpPlaceID:string callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
                marker.title = place.name;
                if ([((NSNumber*)[openStat objectAtIndex:i]) intValue] == 1){
                    marker.snippet = @"We Are Open!";
                    marker.map = mapView;
                }
                else{
                    marker.snippet = @"We are closed :(";
                }
                
            } else {
                NSLog(@"No place details for %@", placeID);
            }
        }];
        i++;
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
