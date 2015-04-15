//
//  WelcomeVC.m
//  AmazingSequencer
//
//  Created by Ariel Elkin on 07/04/2015.
//  Copyright (c) 2015 Ariel Elkin. All rights reserved.
//

#import "WelcomeVC.h"
#import "SimpleDemoVC.h"
#import "ElaborateDemoVC.h"

@interface WelcomeVC()<UITableViewDataSource, UITableViewDelegate>
@end

@implementation WelcomeVC

- (void)viewDidLoad {

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tableView];

    NSArray *tableViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:@{@"tableView": tableView}];
    [self.view addConstraints:tableViewConstraints];

    tableViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[tableView]|" options:0 metrics:nil views:@{@"tableView": tableView}];
    [self.view addConstraints:tableViewConstraints];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        SimpleDemoVC *vc = [SimpleDemoVC new];
        [self presentViewController:vc animated:YES completion:nil];
    }

    else if (indexPath.row == 1) {
        ElaborateDemoVC *vc = [ElaborateDemoVC new];
        [self presentViewController:vc animated:YES completion:nil];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Simple demo";
    }

    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Elaborate demo";
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    static NSString *headerReuseIdentifier = @"TableViewSectionHeaderViewIdentifier";

    UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    if(sectionHeaderView == nil){
        sectionHeaderView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerReuseIdentifier];
    }

    [sectionHeaderView.textLabel setTextColor:[UIColor colorWithRed:74/255.0 green:74/255.0 blue:74/255.0 alpha:1]];
    [sectionHeaderView.textLabel setShadowColor:[UIColor whiteColor]];
    [sectionHeaderView.textLabel setShadowOffset:CGSizeMake(0, 1)];
    sectionHeaderView.textLabel.text = @"The Amazing Audio Engine - Sequencer Demo";
    sectionHeaderView.textLabel.numberOfLines = 0;

    return sectionHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100;
}

@end
