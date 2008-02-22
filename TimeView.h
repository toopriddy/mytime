//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>
#import "AddressView.h"
#import "PublicationView.h"

@interface TimeView : UIView {
    CGRect _rect;
    UIPreferencesTable *_table;
	UINavigationBar *_navigationBar;
	
	NSMutableArray *_timeEntries;
}

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *) settings;
- (void)dealloc;


- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button;
- (int)numberOfRowsInTable:(UITable*)table;
- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column;
-(BOOL)table:(UITable*)table showDisclosureForRow:(int)row;
-(BOOL)table:(UITable*)table canDeleteRow:(int)row;
-(void)table:(UITable*)table movedRow:(int)fromRow toRow:(int)toRow;

@end