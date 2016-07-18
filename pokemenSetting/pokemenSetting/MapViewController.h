//
//  MapViewController.h
//  pokemenSetting
//
//  Created by virgil on 16/7/18.
//  Copyright © 2016年 virgil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property (nonatomic,assign) double lat;

@property (nonatomic,assign) double lon;

@property (nonatomic,copy) void (^saveAddress)(double lat,double lon);



@end
