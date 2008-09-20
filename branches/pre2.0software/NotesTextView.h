//
//  NotesTextView.h
//  MyTime
//
//  Created by Brent Priddy on 6/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>


@interface NotesTextView : UIPreferencesTableCell {
	UITextView *notes;
	UIPreferencesTable *parent;
}

- (NotesTextView *)initWithString:(NSString *)string editing:(BOOL)editing;
- (NSString *)text;
- (float) height;
- (UITextView *)textView;
@end
