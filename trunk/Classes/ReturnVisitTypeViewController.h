//
//  ReturnVisitTypeViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
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




