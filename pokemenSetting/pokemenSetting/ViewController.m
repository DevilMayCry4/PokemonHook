//
//  ViewController.m
//  pokemenSetting
//
//  Created by virgil on 16/7/18.
//  Copyright © 2016年 virgil. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"
static const NSString * kLatitudeKey = @"lat";
static const NSString * kLongitudeKey = @"lon";


static const NSString * kEnableMotionKey = @"enable";
static const NSString * kScaleKey = @"scale";
static const NSString * kChangeDirectionKey = @"direction";
static const NSString * kUpSideDownKey = @"upsidedown";
static const NSString * kYUpSideDownKey = @"Yupsidedown";

@interface ViewController ()
{
    BOOL _enable;
    CGFloat _scale;
    BOOL _direction;
    BOOL _upsidedown;
    double _lat;
    double _lon;
    BOOL _yUpsideDown;
}
@property (weak, nonatomic) IBOutlet UISwitch *yUpSideDownSwitch;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UILabel *scaleLabel;
@property (weak, nonatomic) IBOutlet UISlider *scaleSlider;
@property (weak, nonatomic) IBOutlet UISwitch *upsideDownButton;
@property (weak, nonatomic) IBOutlet UISwitch *changeDirection;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *save = [NSDictionary dictionaryWithContentsOfFile:[self savePath]];
    if (save == nil)
    {
        _scale = 1;
        _lat = 37.78790729999996;
        _lon = -122.40792430000003;
    }
    else
    {
        NSDictionary *params = [NSMutableDictionary dictionaryWithContentsOfFile:[self savePath]];
        _scale = [params[kScaleKey] floatValue];
        _enable = [params[kEnableMotionKey] boolValue];
        _direction = [params[kChangeDirectionKey] boolValue];
        _upsidedown = [params[kUpSideDownKey] boolValue];
        _yUpsideDown = [params[kYUpSideDownKey] boolValue];
        _lat =  [params[kLatitudeKey] doubleValue];
        _lon = [params[kLongitudeKey] doubleValue];
    }
    _addressButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _addressButton.titleLabel.numberOfLines = 0;
    _scaleSlider.continuous = NO;
    [self updateUI];
    [self updateDataInShare]; 

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)updateUI
{
    _enableSwitch.on = _enable;
    _changeDirection.on = _direction;
    _upsideDownButton.on = _upsidedown;
    _scaleSlider.value = _scale;
    _yUpSideDownSwitch.on = _yUpsideDown;
    _scaleLabel.text = [NSString stringWithFormat:@"%.1f",_scale];
    [_addressButton setTitle:[NSString stringWithFormat:@"lan:%@\nlon:%@",[@(_lat) stringValue],[@(_lon) stringValue]] forState:UIControlStateNormal];
}

- (void)updateDataInShare
{
    NSDictionary *p = [NSMutableDictionary dictionaryWithContentsOfFile:[self savePath]];
    if (p)
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:p options:NSJSONWritingPrettyPrinted error:nil];
        UIPasteboard *paste =  [UIPasteboard pasteboardWithName:@"com.pokemen" create:YES];
        paste.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

- (void)save
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[kScaleKey] = @(_scale);
    params[kEnableMotionKey] = @(_enable);
    params[kChangeDirectionKey] = @(_direction);
    params[kUpSideDownKey] = @(_upsidedown);
    params[kLatitudeKey] = @(_lat);
    params[kLongitudeKey] = @(_lon);
    [params writeToFile:[self savePath] atomically:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)savePath
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logPath = [document stringByAppendingPathComponent:@"log"];
    return logPath;
}

#pragma mark ----- 
- (IBAction)enableChange:(id)sender {
    _enable = _enableSwitch.on;
    [self save];
    [self updateDataInShare];
}

- (IBAction)directionChange:(id)sender {
    _direction = _changeDirection.on;
    [self save];
    [self updateDataInShare];
}


- (IBAction)upsideDownChange:(id)sender {
    
    _upsidedown = _upsideDownButton.on;
    [self save];
    [self updateDataInShare];
}

- (IBAction)changeScale:(id)sender {
    _scale = _scaleSlider.value;
    
    _scaleLabel.text = [NSString stringWithFormat:@"%.1f",_scale];
    [self save];
    [self updateDataInShare];
    
}

- (IBAction)yUpSideDownChange:(id)sender {
    _yUpsideDown = _yUpSideDownSwitch.on;
    [self save];
    [self updateDataInShare];
}

- (IBAction)onAddressButtonPress:(id)sender {
    
    MapViewController *c = [[MapViewController alloc] init];
    c.lat = _lat;
    c.lon = _lon;
    c.saveAddress = ^(double lat,double lon){
        _lat = lat;
        _lon = lon;
        [self save];
        [self updateUI];
        [self updateDataInShare];
    };
    [self.navigationController pushViewController:c animated:YES];
}

@end
