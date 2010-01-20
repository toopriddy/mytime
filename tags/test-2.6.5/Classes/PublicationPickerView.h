//
//  PublicationPickerView.h
//  MyTime
//
//  Created by Brent Priddy on 8/7/08.
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


@interface PublicationPickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>
{
    int _year;
    int _month;
    int _publication;
    int _day;
	
	NSMutableArray *_publicationLookupTable;
}
#if 0
// Delegate Methods
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
- (UIView *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

// DataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
#endif

+ (BOOL)areTherePublicationsForFilter:(NSString *)filter;

/**
 * names for the publications used for comparison
 * @return the "official" name of the publication as used in this program
 */
+ (NSString *)watchtowerAndAwake;
+ (NSString *)watchtower;
+ (NSString *)awake;

/**
 * year of our common era
 *
 * @returns year of our common era
 */
- (int)year;

/**
 * get the month of the publication
 *
 * @returns 1-12 where 0=not used
 */
- (int)month;    

/**
 * get the name of the publication
 *
 * @returns the string name of the publication
 */
- (NSString *)publication;

/**
 * get the title of the publication
 *
 * @returns the official title of the publication like "Watchtower Jan 15, 2007"
 */
- (NSString *)publicationTitle;

/**
 * get the publicationType (PublicationType*)
 * @returns one of the PublicationType* strings
 */
- (NSString *)publicationType; 

/**
 * get the day of the publication
 *
 * @returns 0 = not used and 1, 8, 15, 22 for the day of the month
 */
- (int)day;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect;

/**
 * initalize filtered to a specific type
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect filteredToType:(NSString *)filter;

/**
 * initialize this view given the curent configuration
 *
 * @param rect - the rect
 * @param publication - NSString of the publication
 * @param year - the year of our common era
 * @param month - the month where 0 = Jan
 * @param day - the day of the month for a watchtower or awake
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect filteredToType:(NSString *)filter;
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day;
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day filter:(NSString *)filter;



@end
