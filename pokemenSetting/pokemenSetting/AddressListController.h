//
//  AddressListController.h
//  pokemenSetting
//
//  Created by virgil on 16/7/21.
//  Copyright © 2016年 virgil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressListController : UITableViewController

@property (nonatomic,copy) void(^didSelect)(NSDictionary *);

@end
