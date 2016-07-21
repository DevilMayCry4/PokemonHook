//
//  AddressManager.m
//  pokemenSetting
//
//  Created by virgil on 16/7/21.
//  Copyright © 2016年 virgil. All rights reserved.
//

#import "AddressManager.h"
#import "Define.h"
@implementation AddressManager
static AddressManager *_manager;

+ (AddressManager *)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[AddressManager alloc] init];
    });
    return _manager;
}


- (void)save:(double)lati lon:(double)lon tag:(NSString *)tag
{
    NSMutableDictionary *item = [NSMutableDictionary dictionary];
    item[kLatitudeKey] = @(lati);
    item[kLongitudeKey] = @(lon);
    item[kTagKey] = tag;
    NSMutableArray *list = [self list];
    [list addObject:item];
    [list writeToFile:[self savePath] atomically:YES];
}

- (NSMutableArray *)list
{
    NSMutableArray *list = [NSMutableArray arrayWithContentsOfFile:[self savePath]];
    if (list == nil)
    {
        list = [NSMutableArray array];
    }
    return list;
}

- (NSString *)savePath
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *logPath = [document stringByAppendingPathComponent:@"address"];
    return logPath;
}

- (void)saveList:(NSArray *)list
{
    [list writeToFile:[self savePath] atomically:YES];
}
@end
