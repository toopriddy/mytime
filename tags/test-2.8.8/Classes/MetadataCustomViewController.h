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
#import "GenericTableViewController.h"

typedef enum {
	// do not reorder!!! dont add in the middle!!!
	EMAIL,
	PHONE,
	STRING,
	NOTES,
	NUMBER,
	DATE,
	URL,
	CHOICE,
	SWITCH
} MetadataType;

typedef struct 
{
	NSString *name;
	MetadataType type;
} MetadataInformation;

@class MetadataCustomViewController;

@protocol MetadataCustomViewControllerDelegate
@required
- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController;
@end

@protocol MultipleChoiceMetadataValueCellControllerDelegate
@required
- (NSString *)name;
- (void)tableView:(UITableView *)tableView didSelectValue:(NSString *)value atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)selectedMetadataValue;
@end

@interface MetadataCustomViewController : GenericTableViewController
{
	id<MetadataCustomViewControllerDelegate> delegate;
@private
	NSMutableString *name;
	int selected;
	int startedWithSelected;
	BOOL nameNeedsFocus;
	NSMutableArray *data;
}

@property (nonatomic, assign) id<MetadataCustomViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableString *name;
@property (readonly, getter = type) MetadataType type;
@property (nonatomic, retain) NSMutableArray *data;

/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;
- (id) initWithName:(NSString *)theName type:(MetadataType)type data:(NSMutableArray *)theData;

+ (void)addCellMultipleChoiceCellControllersToSectionController:(GenericTableViewSectionController *)sectionController tableController:(GenericTableViewController *)viewController choices:(NSMutableArray *)data metadataDelegate:(NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *)metadataDelegate;

@end




