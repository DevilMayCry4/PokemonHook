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


//
//  Toast+UIView.m
//  Toast
//  Version 1.2
//
//  Copyright 2012 Charles Scalesse.
//

#import <QuartzCore/QuartzCore.h>

#define kMaxWidth                   0.8
#define kMaxHeight                  0.8

#define kHorizontalPadding          10.0
#define kVerticalPadding            10.0
#define kCornerRadius               10.0
#define kOpacity                    0.4
#define kFontSize                   16.0
#define kMaxTitleLines              999
#define kMaxMessageLines            999
#define kFadeDuration               0.2
#define kDisplayShadow              YES

#define kDefaultLength              3.0
#define kDefaultPosition            @"bottom"

#define kImageWidth                 80.0
#define kImageHeight                80.0

#define kActivityWidth              100.0
#define kActivityHeight             100.0
#define kActivityDefaultPosition    @"center"
#define kActivityTag                91325

static NSString *kDurationKey = @"CSToastDurationKey";


@interface UIWindow (ToastPrivate)

- (CGPoint)getPositionFor:(id)position toast:(UIView *)toast;
- (UIView *)makeViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;

@end


@implementation UIWindow (Toast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message {
    [self makeToast:message duration:kDefaultLength position:kDefaultPosition];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position {
    UIView *toast = [self makeViewForMessage:message title:nil image:nil];
    [self showToast:toast duration:interval position:position];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title {
    UIView *toast = [self makeViewForMessage:message title:title image:nil];
    [self showToast:toast duration:interval position:position];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position image:(UIImage *)image {
    UIView *toast = [self makeViewForMessage:message title:nil image:image];
    [self showToast:toast duration:interval position:position];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval  position:(id)position title:(NSString *)title image:(UIImage *)image {
    UIView *toast = [self makeViewForMessage:message title:title image:image];
    [self showToast:toast duration:interval position:position];
}

- (void)showToast:(UIView *)toast {
    [self showToast:toast duration:kDefaultLength position:kDefaultPosition];
}

- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point {
    
    /****************************************************
     *                                                  *
     * Displays a view for a given duration & position. *
     *                                                  *
     ****************************************************/
    
    CGPoint toastPoint = [self getPositionFor:point toast:toast];
    
    // use an associative reference to associate the toast view with the display interval
    objc_setAssociatedObject (toast, &kDurationKey, [NSNumber numberWithFloat:interval], OBJC_ASSOCIATION_RETAIN);
    
    [toast setCenter:toastPoint];
    [toast setAlpha:0.0];
    [self addSubview:toast];
    
    [UIView beginAnimations:@"fade_in" context:(void*)toast];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [toast setAlpha:1.0];
    [UIView commitAnimations];
    
}

#pragma mark - Toast Activity Methods

- (void)makeToastActivity {
    [self makeToastActivity:kActivityDefaultPosition];
}

- (void)makeToastActivity:(id)position {
    // prevent more than one activity view
    UIView *existingToast = [self viewWithTag:kActivityTag];
    if (existingToast != nil) {
        [existingToast removeFromSuperview];
    }
    
    UIView *activityContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kActivityWidth, kActivityHeight)];
#if !__has_feature(objc_arc)
    [activityContainer autorelease];
#endif
    [activityContainer setCenter:[self getPositionFor:position toast:activityContainer]];
    [activityContainer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
    [activityContainer setAlpha:0.0];
    [activityContainer setTag:kActivityTag];
    [activityContainer setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [activityContainer.layer setCornerRadius:kCornerRadius];
    if (kDisplayShadow) {
        [activityContainer.layer setShadowColor:[UIColor blackColor].CGColor];
        [activityContainer.layer setShadowOpacity:0.8];
        [activityContainer.layer setShadowRadius:6.0];
        [activityContainer.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
    }
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
#if !__has_feature(objc_arc)
    [activityView autorelease];
#endif
    [activityView setCenter:CGPointMake(activityContainer.bounds.size.width / 2, activityContainer.bounds.size.height / 2)];
    [activityContainer addSubview:activityView];
    [activityView startAnimating];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:kFadeDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [activityContainer setAlpha:1.0];
    [UIView commitAnimations];
    
    [self addSubview:activityContainer];
}

- (void)hideToastActivity {
    UIView *existingToast = [self viewWithTag:kActivityTag];
    if (existingToast != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kFadeDuration];
        [UIView setAnimationDelegate:existingToast];
        [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [existingToast setAlpha:0.0];
        [UIView commitAnimations];
    }
}

#pragma mark - Animation Delegate Method

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
    
    UIView *toast = (UIView *)(id)context;
    
    // retrieve the display interval associated with the view
    CGFloat interval = [(NSNumber *)objc_getAssociatedObject(toast, &kDurationKey) floatValue];
    
    if([animationID isEqualToString:@"fade_in"]) {
        
        [UIView beginAnimations:@"fade_out" context:(void*)toast];
        [UIView setAnimationDelay:interval];
        [UIView setAnimationDuration:kFadeDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [toast setAlpha:0.0];
        [UIView commitAnimations];
        
    } else if ([animationID isEqualToString:@"fade_out"]) {
        
        [toast removeFromSuperview];
        
    }
    
}

#pragma mark - Private Methods

- (CGPoint)getPositionFor:(id)point toast:(UIView *)toast {
    
    /*************************************************************************************
     *                                                                                   *
     * Converts string literals @"top", @"bottom", @"center", or any point wrapped in an *
     * NSValue object into a CGPoint                                                     *
     *                                                                                   *
     *************************************************************************************/
    
    if([point isKindOfClass:[NSString class]]) {
        
        if( [point caseInsensitiveCompare:@"top"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + kVerticalPadding);
        } else if( [point caseInsensitiveCompare:@"bottom"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - kVerticalPadding);
        } else if( [point caseInsensitiveCompare:@"center"] == NSOrderedSame ) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
        
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    NSLog(@"Error: Invalid position for toast.");
    return [self getPositionFor:kDefaultPosition toast:toast];
}

- (UIView *)makeViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image {
    
    /***********************************************************************************
     *                                                                                 *
     * Dynamically build a toast view with any combination of message, title, & image. *
     *                                                                                 *
     ***********************************************************************************/
    
    if((message == nil) && (title == nil) && (image == nil)) return nil;
    
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
#if !__has_feature(objc_arc)
    [wrapperView autorelease];
#endif
    [wrapperView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
    [wrapperView.layer setCornerRadius:kCornerRadius];
    if (kDisplayShadow) {
        [wrapperView.layer setShadowColor:[UIColor blackColor].CGColor];
        [wrapperView.layer setShadowOpacity:0.8];
        [wrapperView.layer setShadowRadius:6.0];
        [wrapperView.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
    }
    
    [wrapperView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
#if !__has_feature(objc_arc)
        [imageView autorelease];
#endif
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, kImageWidth, kImageHeight)];
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = kHorizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
#if !__has_feature(objc_arc)
        [titleLabel autorelease];
#endif
        [titleLabel setNumberOfLines:kMaxTitleLines];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:kFontSize]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setLineBreakMode:UILineBreakModeWordWrap];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setAlpha:1.0];
        [titleLabel setText:title];
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * kMaxWidth) - imageWidth, self.bounds.size.height * kMaxHeight);
        CGSize expectedSizeTitle = [title sizeWithFont:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        [titleLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height)];
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
#if !__has_feature(objc_arc)
        [messageLabel autorelease];
#endif
        [messageLabel setNumberOfLines:kMaxMessageLines];
        [messageLabel setFont:[UIFont systemFontOfSize:kFontSize]];
        [messageLabel setLineBreakMode:UILineBreakModeWordWrap];
        [messageLabel setTextColor:[UIColor whiteColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setAlpha:1.0];
        [messageLabel setText:message];
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * kMaxWidth) - imageWidth, self.bounds.size.height * kMaxHeight);
        CGSize expectedSizeMessage = [message sizeWithFont:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
        [messageLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height)];
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = kVerticalPadding;
        titleLeft = imageLeft + imageWidth + kHorizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;
    
    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + kHorizontalPadding;
        messageTop = titleTop + titleHeight + kVerticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    
    
    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (kHorizontalPadding * 2)), (longerLeft + longerWidth + kHorizontalPadding));
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + kVerticalPadding), (imageHeight + (kVerticalPadding * 2)));
    
    [wrapperView setFrame:CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight)];
    
    if(titleLabel != nil) {
        [titleLabel setFrame:CGRectMake(titleLeft, titleTop, titleWidth, titleHeight)];
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        [messageLabel setFrame:CGRectMake(messageLeft, messageTop, messageWidth, messageHeight)];
        [wrapperView addSubview:messageLabel];
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    return wrapperView;
}

@end

@interface FakeLocationManager:NSObject
{
    CMMotionManager *_manager;
    CMMotionManager *_shakeManager;
    BOOL _changeDirection;
    BOOL _xUpSideDown;
    BOOL _yUpSideDown;
}

@property (nonatomic,readonly) double scale;
+ (FakeLocationManager *)manager;

+ (void)saveLog:(NSString *)log;
- (NSDictionary *)loadSetting;
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations;


@end

static float x = -1;
static float y = -1;
static CLLocationDegrees startLatitude = 37.78790729999996;
static CLLocationDegrees startLongitude = -122.40792430000003;

static CLLocationDegrees lastLatitude = 0;
static CLLocationDegrees lastLontitude = 0;

static CLLocationManager *fakeManager = nil;

@interface ControllerView : UIView
{
    NSTimer *_timer;
}
@end

@implementation ControllerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGFloat width = CGRectGetWidth(frame);
        CGFloat height = CGRectGetHeight(frame);
        
        UIButton *leftUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftUpButton.frame = CGRectMake(10, 10, 40, 40);
        [leftUpButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [leftUpButton setImage:[[UIImage imageNamed:@"leftup"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        leftUpButton.tag = 4;
        [self addSubview:leftUpButton];
        
        
        UIButton *rightUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
        rightUpButton.frame = CGRectMake(70, 10, 40, 40);
        [rightUpButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [rightUpButton setImage:[[UIImage imageNamed:@"rightup"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        rightUpButton.tag = 5;
        [self addSubview:rightUpButton];
        
        
        UIButton *leftDownButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftDownButton.frame = CGRectMake(10, 70, 40, 40);
        [leftDownButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [leftDownButton setImage:[[UIImage imageNamed:@"leftdown"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        leftDownButton.tag = 6;
        [self addSubview:leftDownButton];
        
        
        UIButton *rightDownButton = [UIButton buttonWithType:UIButtonTypeSystem];
        rightDownButton.frame = CGRectMake(70, 70, 40, 40);
        [rightDownButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [rightDownButton setImage:[[UIImage imageNamed:@"rightdown"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        rightDownButton.tag = 7;
        [self addSubview:rightDownButton];
        
        
        UIButton *upButton = [UIButton buttonWithType:UIButtonTypeSystem];
        upButton.frame = CGRectMake(0, 0, 40, 40);
        [upButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [upButton setImage:[[UIImage imageNamed:@"up"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        upButton.tag = 0;
        [self addSubview:upButton];
        upButton.center = CGPointMake(width/2, 20);
        
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeSystem];
        downButton.frame = CGRectMake(0, 0, 40, 40);
        [downButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [downButton setImage:[[UIImage imageNamed:@"down"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        downButton.tag = 1;
        [self addSubview:downButton];
        
        downButton.center = CGPointMake(width/2, CGRectGetHeight(frame) - 20);
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftButton.frame = CGRectMake(0, 0, 40, 40);
        [leftButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [leftButton setImage:[[UIImage imageNamed:@"left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self addSubview:leftButton];
        leftButton.tag = 2;
        
        leftButton.center = CGPointMake(20, height/2);
        
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        rightButton.frame = CGRectMake(0, 0, 40, 40);
        [rightButton addTarget:self action:@selector(onButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setImage:[[UIImage imageNamed:@"right"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self addSubview:rightButton];
        rightButton.tag = 3;
        
        rightButton.center = CGPointMake(width - 20, height/2);
        self.alpha = 0.7;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:pan];
        
    }
    return self;
}

- (void)onPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint point = [gesture translationInView:self];
        [gesture setTranslation:CGPointZero inView:self];
        CGPoint center = self.center;
        self.center = CGPointMake(point.x + center.x, point.y + center.y);
    }
}

- (void)onButtonPress:(UIButton *)button
{
    if (x == -1 && y == -1)
    {
        return;
    }
 
    NSInteger index = button.tag;
    double value = [[NSString stringWithFormat:@"0.0000%@",[@( 20 *  random() + 40) stringValue]] doubleValue]*[FakeLocationManager manager].scale;
    double xValue = 0;
    double yValue = 0;
    switch (index)
    {
        case 0:
            yValue = value; 
            break;
            
        case 1:
            yValue = -value;
            break;
            
        case 2:
            xValue = value;
            break;
            
        case 3:
            xValue = -value;
            break;
            
        case 4:
            xValue = value;
            yValue = value;
            break;
            
        case 5:
            xValue = -value;
            yValue = value;
            break;
            
        case 6:
            xValue = value;
            yValue = -value;
            break;
            
        case 7:
            xValue = -value;
            yValue = -value;
            break;
            
        default:
            break;
    }
    x += xValue;
    y += yValue;
    if (fakeManager)
    {
        
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(lastLatitude - xValue + x , lastLontitude - yValue + y);
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coor altitude:0 horizontalAccuracy:5 verticalAccuracy:5 timestamp:[NSDate date]];
        [fakeManager.delegate locationManager:fakeManager didUpdateLocations:@[location]];
    }
}

@end



static const NSString * kLatitudeKey = @"lat";
static const NSString * kLongitudeKey = @"lon";


static const NSString * kEnableMotionKey = @"enable";
static const NSString * kScaleKey = @"scale";
static const NSString * kChangeDirectionKey = @"direction";
static const NSString * kUpSideDownKey = @"upsidedown";
static const NSString * kYUpSideDownKey = @"Yupsidedown";

static const NSString * kLoadLastPositionKey = @"last";


@interface CLLocation(Swizzle)

@end

@implementation CLLocation(Swizzle)




+ (void) load {
  
    Method m1 = class_getInstanceMethod(self, @selector(coordinate));
    Method m2 = class_getInstanceMethod(self, @selector(coordinate_));
    method_exchangeImplementations(m1, m2);
}

- (CLLocationCoordinate2D) coordinate_ {
    
    CLLocationCoordinate2D pos = [self coordinate_];
    
    // 算与联合广场的坐标偏移量
    if (x == -1 && y == -1) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                UIView *v =  [[UIApplication sharedApplication].keyWindow viewWithTag:878787];
                if (v == nil)
                {
                ControllerView *view = [[ControllerView alloc] initWithFrame:CGRectMake(20, 40, 120, 120)];
                view.tag = 878787;
                    [[UIApplication sharedApplication].keyWindow addSubview:view];
                }
            });
    
        NSDictionary *location = [[FakeLocationManager manager] loadSetting];
        if (location && [location[kLoadLastPositionKey] boolValue] == NO)
        {
            CLLocationDegrees latitude = [location[kLatitudeKey] doubleValue];
            CLLocationDegrees longitude = [location[kLongitudeKey]doubleValue];
            startLatitude = latitude;
            startLongitude = longitude;
        }
        else
        {
            NSData *data = [NSData dataWithContentsOfFile:[CLLocation savePath]];
            if (data)
            {
                NSDictionary *location = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                CLLocationDegrees latitude = [location[kLatitudeKey] doubleValue];
                CLLocationDegrees longitude = [location[kLongitudeKey]doubleValue];
                startLatitude = latitude;
                startLongitude = longitude;
            }
         
        }
        
        x = pos.latitude - startLatitude;
        y = pos.longitude - (startLongitude);
    }
    lastLatitude = pos.latitude-x;
    lastLontitude =  pos.longitude-y;
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
        [FakeLocationManager  exchangeLocationFuction];
        
        _manager = [[CMMotionManager  alloc] init];
        _manager.accelerometerUpdateInterval = 1;
        _manager.gyroUpdateInterval = 1;
        _scale = 1.0;
        _changeDirection = NO;
        _xUpSideDown = NO;
        _yUpSideDown = NO;
        [self enterFore];
 
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFore) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterback) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    }
    return self;
}

- (NSDictionary *)loadSetting
{
   UIPasteboard *paste = [UIPasteboard pasteboardWithName:@"com.pokemen" create:NO];
    if (paste.string)
    {
        NSData *data = [paste.string dataUsingEncoding:NSUTF8StringEncoding];
        if (data)
        {
            return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
    }
    return nil;
}


- (void)enterFore
{
    NSDictionary *dict = [self loadSetting];
    if (dict)
    {
        _xUpSideDown = [dict[kUpSideDownKey] boolValue];
        _yUpSideDown = [dict[kYUpSideDownKey] boolValue];
        _changeDirection = [dict[kChangeDirectionKey]boolValue];
        _scale = [dict[kScaleKey] floatValue];
        if ([dict[kEnableMotionKey] boolValue])
        {
            [self makeToast:@"重力感应开始"];
            [self startMotion];
        }
        else
        {
            [self makeToast:@"重力感应停止"];
        }
    }
}

- (void)enterback
{
    [_manager stopAccelerometerUpdates];
}

- (void)startMotion
{
    [_manager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        [FakeLocationManager saveLog:@"_mamge"];
        if (x == -1 && y == -1)
        {
            return;
        }
        CMAcceleration acceleration = accelerometerData.acceleration;
        double value = [[NSString stringWithFormat:@"0.0000%@",[@( 20 *  random() + 40) stringValue]] doubleValue]*_scale;
        if (fabs(acceleration.x) > fabs(acceleration.y))
        {
            if (_changeDirection)
            {
                y += (_yUpSideDown ?  -1 : 1)*(acceleration.y  > 0 ?  value : (-value));
               
            }
            else
            {
                x += (_xUpSideDown ?  -1 : 1)*(acceleration.x  > 0 ?  value : (-value));
            }
           
        }
        else
        {
            if (_changeDirection)
            {
                x += (_xUpSideDown ?  -1 : 1)*(acceleration.x  > 0 ?  value : (-value));
            }
            else
            {
              y += (_yUpSideDown ?  -1 : 1)*(acceleration.y  > 0 ?  value : (-value));
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

- (void)makeToast:(NSString *)toast
{
    [[UIApplication sharedApplication].keyWindow makeToast:toast];
}
@end

