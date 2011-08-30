//
//  PSPersonPickerTextFieldCellController.h
//  MyTime
//
//  Created by Brent Priddy on 8/29/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCell.h"
#import "PSTextFieldCellController.h"
#import <AddressBookUI/AddressBookUI.h>


@interface PSPersonPickerTextFieldCellController : PSTextFieldCellController <ABPeoplePickerNavigationControllerDelegate>
{
	ABAddressBookRef addressBook;
}

@property (nonatomic, retain) NSObject *textModel;
@property (nonatomic, copy) NSString *textPath;
@property (nonatomic, copy) NSString *idPath;
@property (nonatomic, copy) NSString *emailIdPath;
@property (nonatomic, copy) NSString *personPickerTitle;
@end
