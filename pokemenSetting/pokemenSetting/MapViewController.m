//
//  MapViewController.m
//  pokemenSetting
//
//  Created by virgil on 16/7/18.
//  Copyright © 2016年 virgil. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "AddressManager.h"
#import "AddressListController.h"
#import "Define.h"
@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end

@interface MapAnnotation : NSObject  <MKAnnotation>

@property(nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

@end

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395
#define kPanHeight 40.0
@implementation MKMapView (ZoomLevel)

#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}

@end

@implementation MapAnnotation


@end



@interface MapViewController ()<MKMapViewDelegate>
{
    MapAnnotation *_lastAnnotation;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"选择书签" style:UIBarButtonItemStyleDone target:self action:@selector(onChoosePress)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(onSaveItemPress)];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithTitle:@"使用" style:UIBarButtonItemStyleDone target:self action:@selector(onUsePress)];
    self.navigationItem.rightBarButtonItems = @[item1,item2,item3];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(_lat, _lon);
    
    if (CLLocationCoordinate2DIsValid(coord))
    {
        MapAnnotation *annotation = [[MapAnnotation alloc] init];
        annotation.title = [NSString stringWithFormat:@"lan:%@ lon:%@",[@(_lat) stringValue],[@(_lon) stringValue]];
        annotation.coordinate = coord;
        [self.mapView addAnnotation:annotation];
        [self.mapView setCenterCoordinate:coord zoomLevel:17 animated:NO];
        _lastAnnotation = annotation;
    }
    self.mapView.delegate = self;
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    lpress.allowableMovement = 10.0;
    [self.mapView addGestureRecognizer:lpress];//m_mapView是MKMapView的实例
    // Do any additional setup after loading the view from its nib.
}

- (void)onChoosePress
{
    AddressListController *c = [[AddressListController alloc] init];
    [self.navigationController pushViewController:c  animated:YES];
    c.didSelect = ^(NSDictionary *params){
        [self.mapView removeAnnotation:_lastAnnotation];
        _lastAnnotation = nil;
        
        //坐标转换
        CLLocationCoordinate2D touchMapCoordinate = CLLocationCoordinate2DMake([params[kLatitudeKey] doubleValue], [params[kLongitudeKey] doubleValue]);
        
        [self.mapView setCenterCoordinate:touchMapCoordinate zoomLevel:17 animated:NO];
        MapAnnotation *annotation = [[MapAnnotation alloc] init];
        annotation.title = [NSString stringWithFormat:@"lan:%@ lon:%@",[@(touchMapCoordinate.latitude) stringValue],[@(touchMapCoordinate.longitude) stringValue]];
        annotation.coordinate = touchMapCoordinate;
        [self.mapView addAnnotation:annotation];
        _lastAnnotation = annotation;
    };
}

- (void)onUsePress
{
    if (_saveAddress)
    {
        _saveAddress(_lastAnnotation.coordinate.latitude,_lastAnnotation.coordinate.longitude);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSaveItemPress
{
    UIAlertController *c =  [UIAlertController alertControllerWithTitle:@"保存到书签" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [c addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[AddressManager manager] save:_lastAnnotation.coordinate.latitude  lon:_lastAnnotation.coordinate.longitude tag: c.textFields.firstObject.text];
    }];
    [c addAction:action];
    
    [c addAction:action2];
    [self presentViewController:c animated:YES completion:nil];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        return;
    }
    [self.mapView removeAnnotation:_lastAnnotation];
    _lastAnnotation = nil;
    
    //坐标转换
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    
    MapAnnotation *annotation = [[MapAnnotation alloc] init];
    annotation.title = [NSString stringWithFormat:@"lan:%@ lon:%@",[@(touchMapCoordinate.latitude) stringValue],[@(touchMapCoordinate.longitude) stringValue]];
    annotation.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:annotation];
    _lastAnnotation = annotation;
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
