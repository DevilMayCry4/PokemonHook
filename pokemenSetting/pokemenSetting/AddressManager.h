//
//  AddressManager.h
//  pokemenSetting
//
//  Created by virgil on 16/7/21.
//  Copyright © 2016年 virgil. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressManager : NSObject

+ (AddressManager *)manager;

- (void)save:(double)lati lon:(double)lon tag:(NSString *)tag;
- (NSMutableArray *)list;
- (void)saveList:(NSArray *)list;

@end
