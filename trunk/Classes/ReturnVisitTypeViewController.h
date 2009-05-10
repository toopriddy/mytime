//
//  ReturnVisitTypeViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/13/08.
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

@class ReturnVisitTypeViewController;

@protocol ReturnVisitTypeViewControllerDelegate<NSObject>
@required
- (void)returnVisitTypeViewControllerDone:(ReturnVisitTypeViewController *)returnVisitTypeViewController;
@end


@interface ReturnVisitTypeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
	id<ReturnVisitTypeViewControllerDelegate> delegate;
    NSString *type;
@private
	UITableView *theTableView;

	UITableViewCell *returnVisitCell;
    UITableViewCell *studyCell;
    UITableViewCell *notAtHomeCell;
    UITableViewCell *transferedReturnVisitCell;
    UITableViewCell *transferedStudyCell;
    UITableViewCell *transferedNotAtHomeCell;
	BOOL isInitialVisit;
}

@property (nonatomic,assign) id<ReturnVisitTypeViewControllerDelegate> delegate;
@property (nonatomic,retain) NSString *type;


/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithType:(NSString *)type isInitialVisit:(BOOL)isInitialVisit;

@end




