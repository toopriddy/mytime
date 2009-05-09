//
//  LocationPickerViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCell.h"

@class LocationPickerViewController;

@protocol LocationPickerViewControllerDelegate<NSObject>
@required
- (void)locationPickerViewControllerDone:(LocationPickerViewController *)locationPickerViewController;
@end


@interface LocationPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
	id<LocationPickerViewControllerDelegate> delegate;
    NSString *type;
@private
	UITableView *theTableView;

	UITableViewCell *manualCell;
    UITableViewCell *googleMapsCell;
    UITableViewCell *doNotShowCell;
	NSMutableDictionary *call;
}

@property (nonatomic,assign) id<LocationPickerViewControllerDelegate> delegate;
@property (nonatomic,retain) NSString *type;


/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithCall:(NSMutableDictionary *)call;

@end




