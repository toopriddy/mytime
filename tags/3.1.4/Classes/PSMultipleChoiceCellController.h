//
//  PSLabelCellController.h
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSLabelCellController.h"
#import "PSMultipleChoiceViewController.h"

@interface PSMultipleChoiceCellController : PSLabelCellController <PSMultipleChoiceViewControllerDelegate>
{
}
// This is a NSArray of Dictionaries using the keys above
@property (nonatomic, retain) NSArray *choices;
@end
