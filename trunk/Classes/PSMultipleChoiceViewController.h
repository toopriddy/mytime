//
//  PSMultipleChoiceViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/6/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"

// keys used in a section
extern NSString * const PSMultipleChoiceHeader; // NSString
extern NSString * const PSMultipleChoiceFooter; // NSString 
extern NSString * const PSMultipleChoiceOptions; // NSAarray of NSDictionaries (keys below)
// The label is used as the value if the Value is not specified
extern NSString * const PSMultipleChoiceOptionsLabel;
extern NSString * const PSMultipleChoiceOptionsValue;

@class PSMultipleChoiceViewController;
@protocol PSMultipleChoiceViewControllerDelegate
- (void)psMultipleChoiceViewController:(PSMultipleChoiceViewController *)controller choiceSelected:(NSDictionary *)choice;
@end



@interface PSMultipleChoiceViewController : GenericTableViewController
{
}
@property (nonatomic, assign) NSObject<PSMultipleChoiceViewControllerDelegate> *delegate;
@property (nonatomic, retain) NSArray *choices;
@property (nonatomic, retain) NSObject *model;
@property (nonatomic, copy) NSString *modelPath;
@end

