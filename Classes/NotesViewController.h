//
//  NotesViewController.h
//  MyTime
//
//  Created by Brent Priddy on 9/20/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NotesViewControllerDelegate.h"

@interface NotesViewController : UIViewController {
	UITextView *textView;
	UIView *containerView;
	id<NotesViewControllerDelegate> delegate;
}
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) id<NotesViewControllerDelegate> delegate;

- (id) initWithNotes:(NSString *)notes;
- (NSString *)notes;

@end
