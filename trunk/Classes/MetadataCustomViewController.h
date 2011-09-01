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
#import "MTAdditionalInformationType.h"

NSString *localizedNameForMetadataType(MetadataType type);

@class MetadataCustomViewController;

@protocol MetadataCustomViewControllerDelegate
@required
- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController;
@optional
- (void)metadataCustomViewControllerCancel:(MetadataCustomViewController *)metadataCustomViewController;
@end

@protocol MultipleChoiceMetadataValueCellControllerDelegate
@required
- (NSString *)name;
- (void)tableView:(UITableView *)tableView didSelectValue:(NSString *)value atIndexPath:(NSIndexPath *)indexPath;
- (NSString *)selectedMetadataValue;
@end


@interface MetadataCustomViewController : GenericTableViewController <UIActionSheetDelegate>
{
	id<MetadataCustomViewControllerDelegate> delegate;
@private
	NSMutableString *name;
	int selected;
	int startedWithSelected;
	BOOL nameNeedsFocus;
	MTAdditionalInformationType *type_;
}
@property (nonatomic, assign) BOOL newType;
@property (nonatomic, retain) MTAdditionalInformationType *type;
@property (nonatomic, assign) id<MetadataCustomViewControllerDelegate> delegate;
@property (nonatomic, retain) NSMutableString *name;
@property (nonatomic, retain) NSMutableSet *allTextFields;

/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id)initWithAdditionalInformationType:(MTAdditionalInformationType *)type;

+ (void)addCellMultipleChoiceCellControllersToSectionController:(GenericTableViewSectionController *)sectionController tableController:(GenericTableViewController *)viewController fromType:(MTAdditionalInformationType *)type metadataDelegate:(NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *)metadataDelegate;
@end




