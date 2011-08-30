//
//  PSTextFieldCell.h
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCell.h"
#import "PSBaseCellController.h"

@interface PSTextFieldCellController : PSBaseCellController<UITableViewTextFieldCellDelegate>
{
	UITextField *textField;
	id textChangedTarget_;
	SEL textChangedAction_;
}
@property (nonatomic, retain, readonly) UITextField *textField;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, assign) UIReturnKeyType returnKeyType;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, assign) UITextFieldViewMode clearButtonMode;
@property (nonatomic, assign) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic, assign) UITextAutocorrectionType autocorrectionType;
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, assign) UITextFieldViewMode rightViewMode;

@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, retain) NSMutableSet *allTextFields;

- (void)setTextChangedTarget:(id)target action:(SEL)action;

@end
