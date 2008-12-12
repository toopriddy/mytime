//
//  MetadataCustomViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 PG Software. All rights reserved.
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




