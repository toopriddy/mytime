//
//  UITableViewMultiTextFieldCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/27/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UITableViewMultiTextFieldCell;

@protocol UITableViewMultiTextFieldCellDelegate<NSObject>
@optional
- (void)tableViewMultiTextFieldCell:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField selected:(BOOL)selected;
- (BOOL)tableViewMultiTextFieldCell:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end

@interface UITableViewMultiTextFieldCell : UITableViewCell <UITextFieldDelegate> {
	id<UITableViewMultiTextFieldCellDelegate> delegate;
@private
	NSMutableArray *_textFields;
	NSMutableArray *_widths;
	UIResponder *_nextKeyboardResponder;
//	NSIndexPath *_indexPath;
//	UITableView *_tableView;
	
}

@property (nonatomic, assign) id<UITableViewMultiTextFieldCellDelegate> delegate;
@property (nonatomic, retain) UIResponder *nextKeyboardResponder;
@property (nonatomic, retain) NSMutableArray *widths;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier textFieldCount:(int)textFieldCount;

- (UITextField *)textFieldAtIndex:(int)index;
@end

