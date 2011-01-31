//
//  DisplayRuleViewController.h
//  MyTime
//
//  Created by Brent Priddy on 1/23/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"
#import <CoreData/CoreData.h>
#import "MTUser.h"

@class DisplayRuleViewController;

@protocol DisplayRuleViewControllerDelegate
- (void)displayRuleViewControllerDone:(DisplayRuleViewController *)viewController;
@end

@interface DisplayRuleViewController : GenericTableViewController
{
	NSObject<DisplayRuleViewControllerDelegate> *delegate;
	MTDisplayRule *displayRule;
	NSMutableSet *allTextFields;
	BOOL obtainFocus;
}
@property (nonatomic, assign) NSObject<DisplayRuleViewControllerDelegate> *delegate;
@property (nonatomic, retain) MTDisplayRule *displayRule;
@property (nonatomic, retain) NSMutableSet *allTextFields;

- (id)initWithDisplayRule:(MTDisplayRule *)displayRule newDisplayRule:(BOOL)newDisplayRule;
@end
