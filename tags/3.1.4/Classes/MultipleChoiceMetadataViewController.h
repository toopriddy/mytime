//
//  MultipleChoiceMetadataViewController.h
//  MyTime
//
//  Created by Brent Priddy on 11/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
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
#import "MetadataEditorViewController.h"
#import "MTAdditionalInformation.h"

@class MultipleChoiceMetadataViewController;

@protocol MultipleChoiceMetadataViewControllerDelegate
@required
- (void)multipleChoiceMetadataViewControllerDone:(MultipleChoiceMetadataViewController *)metadataCustomViewController;
@end

@interface MultipleChoiceMetadataViewController : GenericTableViewController<MultipleChoiceMetadataValueCellControllerDelegate>
{
	NSObject<MultipleChoiceMetadataViewControllerDelegate> *delegate;
@private
	MTAdditionalInformation *additionalInformation_;
	NSString *value;
}
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) MTAdditionalInformation *additionalInformation;
@property (nonatomic, assign) NSObject<MultipleChoiceMetadataViewControllerDelegate> *delegate;

- (id)initWithAdditionalInformation:(MTAdditionalInformation *)additionalInformation;


@end
