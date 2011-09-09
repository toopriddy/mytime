//
//  PSTextViewCellController.h
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseCellController.h"
#import "NotesViewControllerDelegate.h"

@interface PSTextViewCellController : PSBaseCellController<NotesViewControllerDelegate>
{
}
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *title;
@end

