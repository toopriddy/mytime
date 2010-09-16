//
//  MetadataPickerViewController.h
//  MyTime
//
//  Created by Brent Priddy on 2/4/09.
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
#import <Foundation/Foundation.h>

@class MetadataPickerViewController;

@protocol MetadataPickerViewDelegate
- (void)metadataPickerViewControllerDone:(MetadataPickerViewController *)metadataPickerViewController;
- (void)metadataPickerViewControllerChanged:(MetadataPickerViewController *)metadataPickerViewController;
@end

@interface MetadataPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{	
@private	
    IBOutlet UINavigationItem *navigationTitle;
    IBOutlet UIPickerView *pickerView;

	NSArray *_metadataArray;
	NSInteger _selection;
	id _delegate;
}
@property (nonatomic, assign) id<MetadataPickerViewDelegate> delegate;
@property (nonatomic, assign) NSString *metadata;
- (IBAction)done;
- (id) initWithMetadata:(NSString *)metadata;
- (void)reloadData;

@end
