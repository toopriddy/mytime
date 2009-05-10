//
//  PublicationTypeViewController.h
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




