//
//  PSPersonPickerTextFieldCellController.m
//  MyTime
//
//  Created by Brent Priddy on 8/29/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSPersonPickerTextFieldCellController.h"


@interface PSPersonPickerTextFieldCellController ()
@property (nonatomic, retain) UIButton *button;
- (void)userSelected;
@end

@implementation PSPersonPickerTextFieldCellController
@synthesize button;
@synthesize textModel;
@synthesize textPath;
@synthesize idPath;
@synthesize emailIdPath;
@synthesize personPickerTitle;

- (NSString *)textFieldText
{
	NSString *name = [self.textModel valueForKey:self.textPath];
	NSNumber *ownerId = nil;
	if(self.idPath)
	{
		ownerId = [self.textModel valueForKey:self.idPath];
	}
	
	if(ownerId)
	{
		NSNumber *ownerEmailId = nil;
		if(self.emailIdPath)
		{
			ownerEmailId = [self.textModel valueForKey:self.emailIdPath];
		}
		if(addressBook == nil)
		{
			addressBook = ABAddressBookCreate();
		}
		
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [ownerId intValue]);
		ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
		int index = ABMultiValueGetIndexForIdentifier(emails, [ownerEmailId intValue]);
		if(index >= 0 && index < ABMultiValueGetCount(emails))
		{
			name = [(NSString *)ABMultiValueCopyValueAtIndex(emails, index) autorelease];
		}
		CFRelease(emails);
	}	
	return name;
}

- (void)setTextFieldText:(NSString *)text
{
	[self.textModel setValue:text forKey:self.textPath];
	if(self.idPath)
	{
		[self.textModel setValue:nil forKey:self.idPath];
	}
	if(self.emailIdPath)
	{
		[self.textModel setValue:nil forKey:self.emailIdPath];
	}
}

- (id)init
{
	if( (self = [super init]) )
	{
		self.button = [UIButton buttonWithType:UIButtonTypeContactAdd];
		self.rightView = button;
		self.rightViewMode = UITextFieldViewModeAlways;
		self.model = self;
		self.modelPath = @"textFieldText";
		
		[button addTarget:self action:@selector(userSelected) forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

- (void)dealloc
{
	if(addressBook)
	{
		CFRelease(addressBook);
	}
	[self.button removeTarget:self action:@selector(userSelected) forControlEvents:UIControlEventTouchUpInside];
	self.button = nil;
	self.textModel = nil;
	self.textPath = nil;
	self.emailIdPath = nil;
	self.idPath = nil;
	self.personPickerTitle = nil;
	
	[super dealloc];
}

- (void)userSelected
{
	[self.textField becomeFirstResponder];
	[self.textField resignFirstResponder];

	// make the new call view 
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.title = self.personPickerTitle;
	picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    picker.peoplePickerDelegate = self;
    [[self.tableViewController navigationController] presentModalViewController:picker animated:YES];
	[self.tableViewController retainObject:self whileViewControllerIsManaged:picker];
    [picker release];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
    [[self.tableViewController navigationController] dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
	ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(ABMultiValueGetCount(emails) == 1)
	{
		[[self.tableViewController navigationController] dismissModalViewControllerAnimated:YES];

		if(self.idPath)
		{
			[self.textModel setValue:[NSNumber numberWithInt:ABRecordGetRecordID(person)] forKey:self.idPath];
		}
		if(self.emailIdPath)
		{
			[self.textModel setValue:[NSNumber numberWithInt:ABMultiValueGetIdentifierAtIndex(emails, 0)] forKey:self.emailIdPath];
		}
		NSString *text = self.textFieldText;
		[self.textModel setValue:text forKey:self.textPath];
		self.textField.text = text;
		
		CFRelease(emails);
		return NO;
	}
	CFRelease(emails);
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
	[[self.tableViewController navigationController] dismissModalViewControllerAnimated:YES];
	
	if(self.idPath)
	{
		[self.textModel setValue:[NSNumber numberWithUnsignedInt:ABRecordGetRecordID(person)] forKey:self.idPath];
	}
	if(self.emailIdPath)
	{
		[self.textModel setValue:[NSNumber numberWithInt:identifier] forKey:self.emailIdPath];
	}
	NSString *text = self.textFieldText;
	[self.textModel setValue:text forKey:self.textPath];
	self.textField.text = text;
	
    return NO;
}

@end
