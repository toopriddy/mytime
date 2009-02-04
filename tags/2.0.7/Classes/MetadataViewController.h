//
//  MetadataViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetadataCustomViewController.h"

@class MetadataViewController;

@protocol MetadataViewControllerDelegate<NSObject>
@required
- (void)metadataViewControllerAdd:(MetadataViewController *)metadataViewController metadataInformation:(MetadataInformation *)metadataInformation;
@end

@interface MetadataViewController : UIViewController <UITableViewDelegate, 
													  UITableViewDataSource,
													  MetadataCustomViewControllerDelegate> 
{
	id<MetadataViewControllerDelegate> delegate;
@private
	UITableView *theTableView;

}

@property (nonatomic,assign) id<MetadataViewControllerDelegate> delegate;


/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;

@end




