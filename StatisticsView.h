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

@interface StatisticsView : UIView {
    CGRect _rect;
    UIPreferencesTable *_table;
	NSMutableDictionary *_settings;
	
	int _thisMonth;
	int _lastMonth;
	int _thisYear;
	int _lastYear;
	
	int _thisMonthBooks;
	int _thisMonthBrochures;
	int _thisMonthMinutes;
	int _thisMonthMagazines;
	int _thisMonthReturnVisits;
	int _thisMonthBibleStudies;
	int _thisMonthSpecialPublications;
	
	int _lastMonthBooks;
	int _lastMonthBrochures;
	int _lastMonthMinutes;
	int _lastMonthMagazines;
	int _lastMonthReturnVisits;
	int _lastMonthBibleStudies;
	int _lastMonthSpecialPublications;

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
