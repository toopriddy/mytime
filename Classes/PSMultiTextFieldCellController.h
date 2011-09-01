//
//  PSMultiTextFieldCellController.h
//  MyTime
//
//  Created by Brent Priddy on 8/31/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "UITableViewMultiTextFieldCell.h"
#import "PSBaseCellController.h"
@class PSMultiTextFieldCellController;

@interface PSMultiTextFieldConfiguration : NSObject
{
	id textChangedTarget_;
	SEL textChangedAction_;
	PSMultiTextFieldCellController *parent;
}
@property (nonatomic, assign, readonly) PSMultiTextFieldCellController *parent;
@property (nonatomic, retain, readonly) UITextField *textField;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, assign) UIReturnKeyType returnKeyType;
@property (nonatomic, assign) UIKeyboardType keyboardType;
@property (nonatomic, assign) UITextFieldViewMode clearButtonMode;
@property (nonatomic, assign) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic, assign) UITextAutocorrectionType autocorrectionType;
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, assign) UITextFieldViewMode rightViewMode;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, retain) NSObject *model;
@property (nonatomic, copy) NSString *modelPath;

// form of -(void)textChangedForController:(PSMultiTextFieldCellController *)controller configuration:(PSMultitextFieldConfiguration *)configuration text:(NSString *)text
- (void)setTextChangedTarget:(id)target action:(SEL)action;
@end

@interface PSMultiTextFieldCellController : PSBaseCellController<UITableViewMultiTextFieldCellDelegate>
{
	NSArray *textFields;
}
@property (nonatomic, retain, readonly) NSArray *textFieldConfigurations;
@property (nonatomic, assign) BOOL allowSelectionWhenNotEditing;

@property (nonatomic, retain) NSMutableSet *allTextFields;

- (id)initWithTextFieldCount:(int)count;

@end
