//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UISectionList.h>
#import <UIKit/UISectionIndex.h>
#import <UIKit/UIButtonBar.h>
#import "PublicationView.h"
#import "SortedCallsView.h"
#import "StatisticsView.h"
#import "TimeView.h"
#import "SettingsView.h"

typedef enum {
	  VIEW_SORTED_BY_STREET = 1
	, VIEW_SORTED_BY_DATE
	, VIEW_TIME
	, VIEW_STATISTICS
	, VIEW_SETTINGS
} SelectedButtonBarView;

@interface MainView : UIView {
    CGRect _rect;

	SortedCallsView *_sortedCallsView;
	TimeView *_timeView;
	StatisticsView *_statisticsView;
	SettingsView *_settingsView;
	
	UIButtonBar *_buttonBar;
	int _buttons[5];

	SelectedButtonBarView _currentButtonBarView;
	UIView *_currentView;
	UITransitionView *_transitionView;

    NSMutableDictionary *_settings;
}

- (void)setBounds:(CGRect)rect;

- (NSMutableDictionary *)getSavedData;
- (void)saveData;
- (void)setCalls:(NSMutableArray *)calls;

- (void)buttonBarCustomize;

/*
 * Settings Dictionary:
 *     NSMutableArray calls (of the Calls NSMtableDictionary seen below)
 *
 *
 * Calls NSMutableDictionary:
 *     NSString name
 *     NSString street
 *     NSString city
 *     NSString state
 *     NSMutableArray phoneNumbers
 *            NSString type
 *            NSString number
 *     NSMutableArray returnVisits of NSMutableDictionary
 *            NSString notes
 *            NSCalendarDate date
 *            NSMutableArray publications of NSMutableDictionary
 *                   NSString title
 *                   NSString name
 *                   NSInteger year
 *                   NSInteger month
 *                   NSInteger day
 *
 * these are the standard names for the elements in the Call NSMutableDictionary
 */
extern NSString const * const CallName;
extern NSString const * const CallStreetNumber;
extern NSString const * const CallStreet;
extern NSString const * const CallCity;
extern NSString const * const CallState;
extern NSString const * const CallPhoneNumbers;
extern NSString const * const CallPhoneNumberType;
extern NSString const * const CallPhoneNumber;
extern NSString const * const CallReturnVisits;
extern NSString const * const CallReturnVisitNotes;
extern NSString const * const CallReturnVisitDate;
extern NSString const * const CallReturnVisitPublications;
extern NSString const * const CallReturnVisitPublicationTitle;
extern NSString const * const CallReturnVisitPublicationType;
extern NSString const * const CallReturnVisitPublicationName;
extern NSString const * const CallReturnVisitPublicationYear;
extern NSString const * const CallReturnVisitPublicationMonth;
extern NSString const * const CallReturnVisitPublicationDay;

#define PublicationTypeBook @"Book"
#define PublicationTypeBrochure @"Brochure"
#define PublicationTypeMagazine @"Magazine"
#define PublicationTypeTract @"Tract"
#define PublicationTypeSpecial @"Special"

extern NSString const * const SettingsCalls;
extern NSString const * const SettingsLastCallStreetNumber;
extern NSString const * const SettingsLastCallStreet;
extern NSString const * const SettingsLastCallCity;
extern NSString const * const SettingsLastCallState;
extern NSString const * const SettingsCurrentButtonBarView;

extern NSString const * const SettingsTimeStartDate;
extern NSString const * const SettingsTimeEntries;
extern NSString const * const SettingsTimeEntryDate;
extern NSString const * const SettingsTimeEntryMinutes;

extern NSString const * const SettingsDonated;
extern NSString const * const SettingsFirstView;
extern NSString const * const SettingsSecondView;
extern NSString const * const SettingsThirdView;
extern NSString const * const SettingsFourthView;

@end


// button bar strings that should have been in the UIButtonBar header file
extern NSString *kUIButtonBarButtonAction;
extern NSString *kUIButtonBarButtonInfo;
extern NSString *kUIButtonBarButtonInfoOffset;
extern NSString *kUIButtonBarButtonSelectedInfo;
extern NSString *kUIButtonBarButtonStyle;
extern NSString *kUIButtonBarButtonTag;
extern NSString *kUIButtonBarButtonTarget;
extern NSString *kUIButtonBarButtonTitle;
extern NSString *kUIButtonBarButtonTitleVerticalHeight;
extern NSString *kUIButtonBarButtonTitleWidth;
extern NSString *kUIButtonBarButtonType;


