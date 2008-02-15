#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPickerView.h>

@interface PublicationView : UIView {
    UIPickerView *_picker;
    
    NSObject *_saveObject;
    SEL _saveSelector;
    
    NSObject *_cancelObject;
    SEL _cancelSelector;
    
    int _year;
    int _month;
    int _publication;
    int _day;
}

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
 * initialize this view given the curent configuration
 *
 * @param rect - the rect
 * @param publication - NSString of the publication
 * @param year - the year of our common era
 * @param month - the month where 0 = Jan
 * @param day - the day of the month for a watchtower or awake
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day;


/**
 * setup a callback for clicking on the cancel button
 *
 * @param aSelector - the selector on obj to callback
 * @param obj - the object to callback using the passed in aSelector
 * @returns self
 */
- (void)setCancelAction: (SEL)aSelector forObject:(NSObject *)obj;

/**
 * setup a callback for clicking on the save button
 *
 * @param aSelector - the selector on obj to callback
 * @param obj - the object to callback using the passed in aSelector
 * @returns self
 */
- (void)setSaveAction: (SEL)aSelector forObject:(NSObject *)obj;


// picker handler callback functions
- (int)numberOfColumnsInPickerView: (UIPickerView*)p;
- (int) pickerView:(UIPickerView*)p numberOfRowsInColumn:(int)col;
- (id) pickerView:(UIPickerView*)p tableCellForRow:(int)row inColumn:(int)col;

// navigation bar callback functions
- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button;

@end

