//
//  LocationFaker.mm
//  LocationFaker
//
//  Created by Xiaoxuan Tang on 16/7/8.
//  Copyright (c) 2016年 __MyCompanyName__. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

static CLLocationManager *fakeManager = nil;


typedef enum {
    Direction_Up,
    Direction_Down,
    Direction_Left,
    Direction_Right,
}DirectionGO;



@interface FakeLocationManager:NSObject
{
    CMMotionManager *_manager;
    CMMotionManager *_shakeManager;
}

@property (nonatomic,assign)DirectionGO direction;

+ (FakeLocationManager *)manager;

+ (void)saveLog:(NSString *)log;


@end

static const NSString * kLatitudeKey = @"lat";
static const NSString * kLongitudeKey = @"lon";

static CLLocationDegrees startLatitude = 37.78790729999996;
static CLLocationDegrees startLongitude = -122.40792430000003;

@interface CLLocation(Swizzle)

@end

@implementation CLLocation(Swizzle)

static float x = -1;
static float y = -1;


+ (void) load {
    Method m1 = class_getInstanceMethod(self, @selector(coordinate));
    Method m2 = class_getInstanceMethod(self, @selector(coordinate_));
    method_exchangeImplementations(m1, m2);
    NSData *data = [NSData dataWithContentsOfFile:[CLLocation savePath]];
    if (data)
    {
        NSDictionary *location = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        CLLocationDegrees latitude = [location[kLatitudeKey] doubleValue];
        CLLocationDegrees longitude = [location[kLongitudeKey]doubleValue];
        startLatitude = latitude;
        startLongitude = longitude;
    }
    
    [FakeLocationManager manager];
}

- (CLLocationCoordinate2D) coordinate_ {
    
    CLLocationCoordinate2D pos = [self coordinate_];
    
    // 算与联合广场的坐标偏移量
    if (x == -1 && y == -1) {
        x = pos.latitude - startLatitude;
        y = pos.longitude - (startLongitude);
    }
    
    return CLLocationCoordinate2DMake(pos.latitude-x, pos.longitude-y);
}

 

+ (NSString *)savePath
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [document stringByAppendingPathComponent:@"location.json"];
}
 
@end



static FakeLocationManager *mamanger;

@implementation FakeLocationManager

+ (FakeLocationManager *)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mamanger = [[FakeLocationManager alloc] init];
       
    });
    return mamanger;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [FakeLocationManager saveLog:@"init"];
        [FakeLocationManager  exchangeLocationFuction];
        
        _manager = [[CMMotionManager  alloc] init];
        _manager.accelerometerUpdateInterval = 0.4;
        _manager.gyroUpdateInterval = 1;
        [self start];
        
//        _shakeManager = [[CMMotionManager  alloc] init];
//        _shakeManager.accelerometerUpdateInterval = 0.1;
//        _shakeManager.gyroUpdateInterval = 0.1;
//        [_shakeManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
//            CMAcceleration acceleration = accelerometerData.acceleration;
//            
//            double accelerameter =sqrt( pow( acceleration.x , 2 ) + pow( acceleration.y , 2 )
//                                       + pow( acceleration.z , 2) );
//            //当综合加速度大于2.3时，就激活效果（此数值根据需求可以调整，数据越小，用户摇动的动作就越小，越容易激活，反之加大难度，但不容易误触发）
//            if (accelerameter>2.0f) {
//                
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    if (_manager.accelerometerActive)
//                    {
//                        [_manager stopAccelerometerUpdates];
//                    }
//                    else
//                    {
//                        [self start];
//                    }
//                });
//            }
//            
//        }];
        [FakeLocationManager saveLog:@"start"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFore) name:UIApplicationWillEnterForegroundNotification object:nil];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterback) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}

- (void)enterFore
{
    [self start];
}

- (void)enterback
{
    [_manager stopAccelerometerUpdates];
}

- (void)start
{
    [_manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        [FakeLocationManager saveLog:@"_mamge"];
        if (x == -1 && y == -1)
        {
            return;
        }
         CMAcceleration acceleration = accelerometerData.acceleration;
        double value = [[NSString stringWithFormat:@"0.0000%@",[@( 20 *  random() + 40) stringValue]] doubleValue];
        if (fabs(acceleration.x) > fabs(acceleration.y))
        {
            if (acceleration.x > 0)
            {
                x += value;
            }
            else
            {
                x -= value;
            }
        }
        else
        {
            if (acceleration.y  > 0)
            {
                y += value;
            }
            else
            {
                y -= value;
                
            }
        } 
        
    }];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    if (manager)
    {
        fakeManager = manager;
    }
    [FakeLocationManager saveLog:@"didupdate"];
    CLLocation *object = [locations firstObject];
    NSDictionary *s = @{kLatitudeKey:@(object.coordinate.latitude),kLongitudeKey:@(object.coordinate.longitude)};
    [[NSJSONSerialization dataWithJSONObject:s options:NSJSONWritingPrettyPrinted error:nil] writeToFile:[CLLocation savePath] atomically:YES];
    [FakeLocationManager exchangeLocationFuction];
    [self locationManager:manager didUpdateLocations:locations];
    [FakeLocationManager exchangeLocationFuction];
}

+ (void)exchangeLocationFuction
{
    Class manager = NSClassFromString(@"NIAIosLocationManager");
    if (manager != NULL)
    {
        Method method1 = class_getInstanceMethod(manager, @selector(locationManager:didUpdateLocations:));
        Method method2 = class_getInstanceMethod(self, @selector(locationManager:didUpdateLocations:));
        method_exchangeImplementations(method1, method2);
    }
}

+ (void)saveLog:(NSString *)log
{
//    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *logPath = [document stringByAppendingPathComponent:@"log"];
//    NSMutableString *string = [[NSMutableString alloc] initWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
//    if (string == nil)
//    {
//        string = [NSMutableString string];
//    }
//    [string appendFormat:@"\n%@",log];
//    [string writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}
@end

