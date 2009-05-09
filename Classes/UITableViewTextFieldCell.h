//
//  UITableViewTextFieldCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/27/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
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

@end

