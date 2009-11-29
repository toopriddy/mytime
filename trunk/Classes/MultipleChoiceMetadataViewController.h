//
//  MultipleChoiceMetadataViewController.h
//  MyTime
//
//  Created by Brent Priddy on 11/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import "MetadataEditorViewController.h"

@class MultipleChoiceMetadataViewController;

@protocol MultipleChoiceMetadataViewControllerDelegate
@required
- (void)multipleChoiceMetadataViewControllerDone:(MultipleChoiceMetadataViewController *)metadataCustomViewController;
@end

@interface MultipleChoiceMetadataViewController : GenericTableViewController<MultipleChoiceMetadataValueCellControllerDelegate>
{
	NSObject<MultipleChoiceMetadataViewControllerDelegate> *delegate;
@private
	int selected;
	NSMutableArray *data;
	NSString *value;
}
@property (nonatomic, assign) NSObject<MultipleChoiceMetadataViewControllerDelegate> *delegate;
@property (nonatomic, retain) NSString *value;

- (id) initWithName:(NSString *)theName value:(NSString *)value;


@end
