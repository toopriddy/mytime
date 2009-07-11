//
//  UITableViewTextFieldCell.h
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
#import "UITableViewTextFieldCellDelegate.h"

@interface UITableViewTextFieldCell : UITableViewCell <UITextFieldDelegate> {
	UITextField *textField;
	UILabel *titleLabel;
	UILabel *valueLabel;
	UIResponder *nextKeyboardResponder;
	BOOL observeEditing;
	id<UITableViewTextFieldCellDelegate> delegate;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIResponder *nextKeyboardResponder;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, assign) id<UITableViewTextFieldCellDelegate> delegate;
@property (nonatomic, assign) NSString *value;
@property (nonatomic, assign) BOOL observeEditing;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (id)initWithTextField:(UITextField *)field Frame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end

