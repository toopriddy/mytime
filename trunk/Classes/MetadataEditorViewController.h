//
//  MetadataEditorViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "NumberedPickerView.h"
#import "UITableViewTextFieldCell.h"
#import "MetadataViewController.h"

@class MetadataEditorViewController;

@protocol MetadataEditorViewControllerDelegate<NSObject>

@required

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController;

@end



@interface  MetadataEditorViewController : UIViewController <UITableViewDelegate, 
													         UITableViewDataSource>
{
@private
	MetadataType _type;

	int _tag;
	UITableViewCell *_textFieldCell;
	UIViewController *_cellViewController;
	UITextView *_textView;
    UIDatePicker *_datePicker;
    NumberedPickerView *_numberPicker;
	UIView *_containerView;
	UIResponder *_firstResponder;
	UITableView *_theTableView;
	
	id<MetadataEditorViewControllerDelegate> _delegate;
}
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) id<MetadataEditorViewControllerDelegate> delegate;


- (id) initWithName:(NSString *)name type:(MetadataType)type data:(NSObject *)data value:(NSString *)value;
- (void)setAutocapitalizationType:(UITextAutocapitalizationType)type;
- (void)setPlaceholder:(NSString *)placeholder;
- (void)navigationControlDone:(id)sender;

- (NSString *)value;
- (BOOL)boolValue;
- (NSDate *)date;
@end