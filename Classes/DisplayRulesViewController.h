//
//  DisplayRulesViewController.h
//  MyTime
//
//  Created by Brent Priddy on 1/22/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"
#import "DisplayRuleViewController.h"
#import <CoreData/CoreData.h>
#import "MTUser.h"

@class DisplayRulesViewController;

@protocol DisplayRulesViewControllerDelegate
- (void)displayRulesViewController:(DisplayRulesViewController *)viewController selectedDisplayRule:(MTDisplayRule *)displayRule;
@end

@interface DisplayRulesViewController : GenericTableViewController<DisplayRuleViewControllerDelegate>
{
	NSObject<DisplayRulesViewControllerDelegate> *delegate;
	NSManagedObjectContext *managedObjectContext;
	
}
@property (nonatomic, assign) NSObject<DisplayRulesViewControllerDelegate> *delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MTDisplayRule *temporaryDisplayRule;

@end
