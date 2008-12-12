//
//  UITableViewMultiTextFieldCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/27/08.
//  Copyright 2008 PG Software. All rights reserved.
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

