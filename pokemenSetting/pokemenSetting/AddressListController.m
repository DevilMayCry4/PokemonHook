//
//  AddressListController.m
//  pokemenSetting
//
//  Created by virgil on 16/7/21.
//  Copyright © 2016年 virgil. All rights reserved.
//

#import "AddressListController.h"
#import "Define.h"
#import "AddressManager.h"

@interface AddressListController ()
{
    NSMutableArray *_list;
}
@end

@implementation AddressListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 60;
    _list = [[AddressManager manager] list];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"c"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"c"];
    }
    NSDictionary *item = _list[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"lan:%@ lon:%@",item[kLatitudeKey],item[kLongitudeKey]];
    cell.detailTextLabel.text = item[kTagKey];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _didSelect(_list[indexPath.row]);
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [_list removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        [[AddressManager manager] saveList:_list];
    }
}

@end
