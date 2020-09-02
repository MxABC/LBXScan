//
//  SettingViewController.m
//  
//
//  Created by lbxia on 2017/3/30.
//  Copyright © 2017年 lbx. All rights reserved.
//

#import "SettingViewController.h"
#import "Global.h"
#import "LBXAlertAction.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<NSString*>*>* arrayItems;
@property (nonatomic, strong) NSString *cellIdentifier;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫码配置";
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.cellIdentifier = @"cell";
    [self arrayItems];
    [self tableView];
}

- (NSArray*)arrayItems
{
    if (!_arrayItems) {
        
        _arrayItems = @[
                        @[@"native",@"ZXing",@"ZBar"],
                        [Global sharedManager].nativeTypes,@[@"是否连续扫码"]];
    }
    return _arrayItems;
}

- (UITableView*)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:_cellIdentifier];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


#pragma mark --DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrayItems.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayItems[section].count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"选择扫码库";
            break;
        case 1:
            return @"选择识别码制(ZXing库默认同时识别多个码制)";
            break;
        case 2:
            return @"是否需要连续扫码";
            break;
        default:
            break;
    }
    return  @"";
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        switch ([Global sharedManager].libraryType) {
            case SLT_Native:
                return @"native支持同时识别多个码制，但实际测试效果很差";
                break;
            case SLT_ZXing:
                 return @"ZXing库支持同时识别多个码制,所以这里全部勾上";
                break;
            case SLT_ZBar:
                return @"ZBar不支持同时识别多个码制";
                break;
            default:
                break;
        }
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = _arrayItems[indexPath.section][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case 0:
         if (indexPath.row == [Global sharedManager].libraryType) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 1:
            
            if ([Global sharedManager].libraryType == SLT_ZXing) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else if (indexPath.row == [Global sharedManager].scanCodeType) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        case 2:
            cell.accessoryType = [Global sharedManager].continuous ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark --Delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            [Global sharedManager].libraryType = indexPath.row;
            break;
        case 1:
        {
            if ( [Global sharedManager].libraryType != SLT_ZXing )
            {
                if (indexPath.row == SCT_BarCodeITF)
                {
                   [LBXAlertAction showAlertWithTitle:@"提示" msg:@"只有ZXing支持ITF码制识别" buttonsStatement:@[@"知道了"] chooseBlock:nil];
                }
                else
                {
                     [Global sharedManager].scanCodeType = indexPath.row;
                }
            }
        }
            break;
        case 2:
        {
            [Global sharedManager].continuous =  ![Global sharedManager].continuous;
        }
            break;
        default:
            break;
    }
    [tableView reloadData];
}


@end
