//
//  PublicationTypeViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCell.h"
#import "PublicationViewControllerDelegate.h"

@class PublicationViewController;

@protocol PublicationTypeViewControllerDelegate<NSObject>
@required
- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController;
@end

@interface PublicationTypeViewController : UIViewController <UITableViewDelegate, 
                                                             UITableViewDataSource, 
															 PublicationViewControllerDelegate> 
{
	id<PublicationTypeViewControllerDelegate> delegate;
@private
	UITableView *theTableView;

}

@property (nonatomic,assign) id<PublicationTypeViewControllerDelegate> delegate;


/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;

@end




