//
//  DisplayRuleViewController.h
//  MyTime
//
//  Created by Brent Priddy on 1/23/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"
#import "SorterViewController.h"
#import <CoreData/CoreData.h>
#import "MTSorter.h"
#import "MTDisplayRule.h"

@class DisplayRuleViewController;

@protocol DisplayRuleViewControllerDelegate
- (void)displayRuleViewControllerDone:(DisplayRuleViewController *)viewController;
@end

@interface DisplayRuleViewController : GenericTableViewController <SorterViewControllerDelegate>
{
	NSObject<DisplayRuleViewControllerDelegate> *delegate;
	MTDisplayRule *displayRule;
	NSMutableSet *allTextFields;
	BOOL obtainFocus;
}
@property (nonatomic, assign) NSObject<DisplayRuleViewControllerDelegate> *delegate;
@property (nonatomic, retain) MTDisplayRule *displayRule;
@property (nonatomic, retain) NSMutableSet *allTextFields;
@property (nonatomic, retain) MTSorter *temporarySorter;

- (id)initWithDisplayRule:(MTDisplayRule *)displayRule newDisplayRule:(BOOL)newDisplayRule;
@end
