//
//  MetadataCustomViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
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
#import "UITableViewTextFieldCell.h"

typedef enum {
	EMAIL,
	PHONE,
	STRING,
	NOTES,
	NUMBER,
	DATE,
	URL,
	CHOICE
} MetadataType;

typedef struct 
{
	NSString *name;
	MetadataType type;
} MetadataInformation;

@class MetadataCustomViewController;

@protocol MetadataCustomViewControllerDelegate<NSObject>
@required
- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController;
@end

@interface MetadataCustomViewController : UIViewController <UITableViewDelegate, 
													      UITableViewDataSource,
														  UITableViewTextFieldCellDelegate> 
{
	id<MetadataCustomViewControllerDelegate> delegate;
@private
	UITableView *theTableView;
	UITableViewTextFieldCell *_name;
	int _selected;
}

@property (nonatomic, assign) id<MetadataCustomViewControllerDelegate> delegate;
@property (nonatomic, retain) UITableViewTextFieldCell *name;
@property (readonly, getter = type) MetadataType type;

/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;

@end




