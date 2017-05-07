//
//  ViewController.m
//  Kanotguiden-2
//
//  Created by Prince on 5/2/17.
//  Copyright © 2017 developteam. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "Mission.h"
@interface ViewController ()<CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *m_view;
@property (nonatomic,retain) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic, strong) NSTimer *myTimer;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    currentZoom=6;
    if([CLLocationManager locationServicesEnabled]) {
        if(!self.locationManager) {
            self.locationManager=[[CLLocationManager alloc] init];
        }
        self.locationManager.delegate=self;
        self.locationManager.distanceFilter=kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];//above ios 8.0 locationmanager Authorization
        }
        self.currentLocation=[[CLLocation alloc]init];
        
        [self.locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"Location services are not enabled");
    }
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (IBAction)onclickedZoomOutBtn:(id)sender {
    currentZoom=currentZoom-1;
    [self showmapview:currentZoom];
}
- (IBAction)onclickedZoomInBtn:(id)sender {
    currentZoom=currentZoom+1;
    [self showmapview:currentZoom];
}
- (IBAction)onclickedUnlockBtn:(id)sender {
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:60*10.f target:self selector:@selector(loadXML) userInfo:nil repeats:YES];
    [self loadXML];
}
- (IBAction)onclickedWorldBtn:(id)sender {
}
- (IBAction)onclickedReloadBtn:(id)sender {
    currentZoom=6;
    [self showmapview:currentZoom];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// You don't need to modify the default initWithNibName:bundle: method.
- (void) loadXML {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        @try {
            NSURL *url = [NSURL URLWithString:@"http://itinplanner.com/Kanotguiden/missions.xml"];
            [XMLConverter convertXMLURL:url completion:^(BOOL success, NSDictionary *dictionary, NSError *error) {
                NSLog(@"%@", success ? dictionary : error);
                if (!error) {
                    missionArray = [NSMutableArray new];
                    
                    NSDictionary *xmlArray = [[dictionary objectForKey:@"missions"] objectForKey:@"mission"];
                    for (NSDictionary *dic in xmlArray) {
                        Mission *mission = [[Mission alloc] init];
                        mission.missionTitle = [dic objectForKey:@"title"];
                        mission.missionDescription=[dic objectForKey:@"description"];
                        mission.missionUrl = [dic objectForKey:@"URL_Link"];
                        mission.missionLat = [dic objectForKey:@"lat"];
                        mission.missionLon = [dic objectForKey:@"lon"];
                        
                        [missionArray addObject:mission];
                    }
                }
            }];
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[SVProgressHUD dismiss];
        });
    });
    
}
- (void)showmapview:(int)level {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude
                                                            longitude:self.currentLocation.coordinate.longitude
                                                                 zoom:level];
//    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
//    mapView.myLocationEnabled = YES;
//    m_view = mapView;
    self.m_view.camera = camera;
//    self.m_view.myLocationEnabled = YES;
    
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    marker.title = @"My Location";
    marker.icon=[UIImage imageNamed:@"icon_marker_my"];
//    marker.snippet = @"Australia";
    marker.map = self.m_view;

}
#pragma mark - CLLocationManageDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    _currentLocation=nil;
    NSLog(@"Failed to get your location");
}


-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation: (CLLocation *)oldLocation {
    NSLog(@"Latitude : %f", newLocation.coordinate.latitude);
    NSLog(@"Longitude : %f", newLocation.coordinate.longitude);
    self.currentLocation=newLocation;
    [self showmapview:currentZoom];
    [manager stopUpdatingLocation];
}
@end
