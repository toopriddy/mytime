//
//  UITableViewTextFieldCellDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 9/8/08.
//  Copyright 2008 PG Software. All rights reserved.
//

@class UITableViewTextFieldCell;

@protocol UITableViewTextFieldCellDelegate<NSObject>
@optional
- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected;
- (BOOL)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end

