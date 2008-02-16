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
	
	int _thisMonth;
	int _lastMonth;
	
	int _thisMonthBooks;
	int _thisMonthBroshures;
	int _thisMonthHours;
	int _thisMonthMagazines;
	int _thisMonthReturnVisits;
	int _thisMonthBibleStudies;
	int _thisMonthSpecialPublications;
	
	int _lastMonthBooks;
	int _lastMonthBroshures;
	int _lastMonthHours;
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
- (id) initWithFrame: (CGRect)rect;
- (void)dealloc;
- (void)reloadData;
@end