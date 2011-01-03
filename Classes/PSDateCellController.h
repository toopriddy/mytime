//
//  PSDateCellController.h
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseCellController.h"
#import "DatePickerViewController.h"

@interface PSDateCellController : PSBaseCellController<DatePickerViewControllerDelegate>
{
}
@property (nonatomic, copy) NSString *dateFormat;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;

@end
