//
//  AddressPickerViewController.m
//  qch
//
//  Created by 苏宾 on 16/3/8.
//  Copyright © 2016年 qch. All rights reserved.
//

#import "AddressPickerViewController.h"
#import "ChineseToPinyin.h"
#import "BAddressHeader.h"
#import "HotCityCell.h"
#import "LocationCityCell.h"

@interface AddressPickerViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>{
    UITableView *_tableView;
    UISearchBar *_searchBar;
    UISearchDisplayController *_displayController;
    NSArray *hotCities;
    NSMutableArray *cities;
    NSMutableArray *titleArray;
    NSMutableArray *resultArray;
    
    UIImageView *bkgImageView;
}

@property(nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation AddressPickerViewController

- (id)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self initData];
        [self initSearchBar];
        [self initTableView];
    }
    return self;
}

#pragma mark - Getter and Setter
- (void)setDataSource:(id<AddressPickerDataSource>)dataSource{
    hotCities = [dataSource arrayOfHotCitiesInAddressPicker:self];
    [_tableView reloadData];
}

#pragma mark - UISearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if ([self.delegate respondsToSelector:@selector(beginSearch:)]) {
        [self.delegate beginSearch:searchBar];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
            [UIView animateWithDuration:0.25 animations:^{
                [self.view setBackgroundColor:UIColorFromRGBA(198, 198, 203, 1.0)];
                for (UIView *subview in self.view.subviews){
                    subview.transform = CGAffineTransformMakeTranslation(0, statusBarFrame.size.height);
                }
            }];
        }
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    if ([self.delegate respondsToSelector:@selector(endSearch:)]) {
        [self.delegate endSearch:searchBar];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            [UIView animateWithDuration:0.25 animations:^{
                for (UIView *subview in self.view.subviews){
                    subview.transform = CGAffineTransformMakeTranslation(0, 0);
                }
            } completion:^(BOOL finished) {
                [self.view setBackgroundColor:[UIColor whiteColor]];
            }];
        }
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [resultArray removeAllObjects];
    for (int i = 0; i < cities.count; i++) {
        NSString *dict=[cities objectAtIndex:i];
        if ([[ChineseToPinyin pinyinFromChiniseString:dict] hasPrefix:[searchString uppercaseString]] || [dict hasPrefix:searchString]) {
            [resultArray addObject:dict];
        }
    }
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    [self searchDisplayController:controller shouldReloadTableForSearchString:_searchBar.text];
    return YES;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _tableView) {
        return [[self.dictionary allKeys] count] + 3;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _tableView) {
        if (section > 2) {
            NSString *cityKey = [titleArray objectAtIndex:section - 3];
            NSArray *array = [self.dictionary objectForKey:cityKey];
            return [array count];
        }
        return 1;
    }else{
        return [resultArray count];
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (tableView == _tableView) {
        if (indexPath.section==0) {
            LocationCityCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
            cell.locationLabel.text = @"全国";
            return cell;
        }
        if (indexPath.section == 1) {
            LocationCityCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
            cell.locationLabel.text = UserDefaultEntity.city;
            cell.locationLabel.textColor = [UIColor themeBlueColor];
            return cell;
            
        }else if (indexPath.section == 2){
            HotCityCell *hotCell = [tableView dequeueReusableCellWithIdentifier:@"hotCityCell"];
            if (hotCell == nil) {
                hotCell = [[HotCityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hotCityCell" array:hotCities];
            }
            hotCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [hotCell setBackgroundColor:[UIColor whiteColor]];
            [hotCell buttonWhenClick:^(UIButton *button) {
                if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                    [self.delegate addressPicker:self didSelectedCity:button.titleLabel.text];
                }
            }];
            return hotCell;
        }else{
            
            static NSString *Identifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor whiteColor]];
            NSString *cityKey = [titleArray objectAtIndex:indexPath.section - 3];
            NSArray *array = [self.dictionary objectForKey:cityKey];
            cell.textLabel.text = [array objectAtIndex:indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:16.0];
            cell.textLabel.textColor=[UIColor blackColor];
            return cell;
        }
    }else{
        static NSString *Identifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        }
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [resultArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        return cell;
    }
}

//右侧索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView == _tableView) {
        NSMutableArray *titleSectionArray = [NSMutableArray arrayWithObjects:@"全国",@"当前",@"热门", nil];
        for (int i = 0; i < [titleArray count]; i++) {
            NSString *title = [NSString stringWithFormat:@"    %@",[titleArray objectAtIndex:i]];
            [titleSectionArray addObject:title];
        }
        return titleSectionArray;
    }else{
        return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == _tableView) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 28)];
        headerView.backgroundColor = UIColorFromRGBA(235, 235, 235, 1.0);
        headerView.alpha=0.6;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, ScreenWidth - 15, 28)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor=[UIColor blackColor];
        [headerView addSubview:label];
        if (section==0) {
            label.text = @"所有城市";
        }else if (section == 1) {
            label.text = @"当前城市";
        }else if (section == 2){
            label.text = @"热门城市";
        }else{
            label.text = [titleArray objectAtIndex:section - 3];
        }
        return headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == _tableView) {
        return 28;
    }else{
        return 0.01;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _tableView) {
        if (indexPath.section == 2) {
            return ceil((float)[hotCities count] / 3) * (BUTTON_HEIGHT + 15) + 15;
        }else if (indexPath.section > 2){
            return 42;
        }
        return BUTTON_HEIGHT + 30;
    }else{
        return 42;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _tableView) {
        if (indexPath.section > 2) {
            NSString *cityKey = [titleArray objectAtIndex:indexPath.section - 3];
            NSArray *array = [self.dictionary objectForKey:cityKey];
            if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                [self.delegate addressPicker:self didSelectedCity:[array objectAtIndex:indexPath.row]];
            }
        }else if (indexPath.section==0){
            if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                [self.delegate addressPicker:self didSelectedCity:@""];
            }
        }else if(indexPath.section ==1){
            if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
                [self.delegate addressPicker:self didSelectedCity:UserDefaultEntity.city];
            }
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(addressPicker:didSelectedCity:)]) {
            [self.delegate addressPicker:self didSelectedCity:[resultArray objectAtIndex:indexPath.row]];
        }
    }
}

#pragma mark - init
- (void)initTableView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, ScreenWidth, ScreenHeight - 44-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView.backgroundView addSubview:bkgImageView];
    _tableView.backgroundColor=[UIColor whiteColor];
    _tableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    _tableView.sectionIndexColor = [UIColor grayColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
    [_tableView registerNib:[UINib nibWithNibName:@"LocationCityCell" bundle:nil] forCellReuseIdentifier:@"locationCell"];
    
    [self.view addSubview:_tableView];
}

- (void)initSearchBar{
    resultArray = [[NSMutableArray alloc] init];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    _searchBar.placeholder = @"输入城市名或拼音";
    _searchBar.delegate = self;
    _searchBar.layer.borderColor = [[UIColor grayColor] CGColor];
    _searchBar.backgroundColor=[UIColor whiteColor];
    _displayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    _displayController.delegate = self;
    _displayController.searchResultsDataSource = self;
    _displayController.searchResultsDelegate = self;
    [self.view addSubview:_searchBar];
}

- (void)initData{
    cities = [[NSMutableArray alloc] init];
    NSArray *allCityKeys = [self.dictionary allKeys];
    for (int i = 0; i < [self.dictionary count]; i++) {
        [cities addObjectsFromArray:[self.dictionary objectForKey:[allCityKeys objectAtIndex:i]]];
    }
    titleArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 26; i++) {
        if (i == 8 || i == 14 || i == 20 || i== 21) {
            continue;
        }
        NSString *cityKey = [NSString stringWithFormat:@"%c",i+65];
        [titleArray addObject:cityKey];
    }
}

#pragma mark - Getter and Setter
- (NSMutableDictionary*)dictionary{
    if (_dictionary == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cities" ofType:@"plist"];
        _dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
    return _dictionary;
}


@end
