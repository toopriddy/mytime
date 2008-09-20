//
//  UITableViewTextFieldCellDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 9/8/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@class UITableViewTextFieldCell;

@protocol UITableViewTextFieldCellDelegate<NSObject>

@required

- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected;

@end

