//
//  NotesViewController.h
//  MyTime
//
//  Created by Brent Priddy on 9/20/08.
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

#import "NotesViewControllerDelegate.h"

@interface NotesViewController : UIViewController {
	UITextView *textView;
	UIView *containerView;
	id<NotesViewControllerDelegate> delegate;
	int tag;
}
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) id<NotesViewControllerDelegate> delegate;
@property (nonatomic, assign) int tag;

- (id) initWithNotes:(NSString *)notes;
- (NSString *)notes;

@end
