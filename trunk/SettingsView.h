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

@interface SettingsView : UIView {
    CGRect _rect;
    UIPreferencesTable *_table;
	NSMutableDictionary *_settings;
	
	NSString *_firstView;
	NSString *_secondView;
	NSNumber *_donated;
	
	bool _donatedAlready;
	
	int _selectedRow;
}

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *)settings;
- (void)dealloc;
- (void)reloadData;
@end
