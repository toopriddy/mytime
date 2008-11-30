//
//  MetadataEditorViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 PG Software. All rights reserved.
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

	UITableViewTextFieldCell *_textFieldCell;
	UITextView *_textView;
    UIDatePicker *_datePicker;
    NumberedPickerView *_numberPicker;
	UIView *_containerView;
	UIResponder *_firstResponder;
	UITableView *_theTableView;
	
	id<MetadataEditorViewControllerDelegate> _delegate;
}
@property (nonatomic, assign) id<MetadataEditorViewControllerDelegate> delegate;


- (id) initWithName:(NSString *)name type:(MetadataType)type data:(NSObject *)data value:(NSString *)value;
- (void)navigationControlDone:(id)sender;

- (NSString *)value;
- (NSObject *)data;
@end