//
//  PSBaseCellController.h
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"


@interface PSBaseCellController : NSObject<TableViewCellController>
{
@private
	NSObject *model_;
	NSString *path_;
}
@property (nonatomic, retain) NSObject *model;
@property (nonatomic, retain) NSString *modelPath;
@property (nonatomic, assign) BOOL indentWhileEditing;
@property (nonatomic, assign) UITableViewCellEditingStyle editingStyle;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic, assign) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, assign) UITableViewCellAccessoryType editingAccessoryType;
//@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) GenericTableViewController *tableViewController;
@property (nonatomic, copy) NSIndexPath *selectedRow;
// 0 means to not go to the next row
@property (nonatomic, assign) int selectNextRowResponderIncrement;

- (UIResponder *)nextRowResponderForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end