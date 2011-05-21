//
//  FilterDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "FilterDetailViewController.h"
#import "PSLabelCellController.h"
#import "PSSwitchCellController.h"
#import "FilterDetailViewController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSLabelCellController.h"
#import "PSCheckmarkCellController.h"
#import "PSDateCellController.h"
#import "MTFilter.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSTextFieldCellController.h"
#import "PSLocalization.h"
#import "FilterTableViewController.h"

@implementation FilterDetailViewController
@synthesize delegate;
@synthesize filter;
@synthesize allTextFields;

- (id) initWithFilter:(MTFilter *)theFilter newFilter:(BOOL)newFilter
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Edit Sort Rule", @"Sort Rules View title");
		self.filter = theFilter;
		self.hidesBottomBarWhenPushed = YES;
		self.allTextFields = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc 
{
	self.filter = nil;
	self.allTextFields = nil;
		
	[super dealloc];
}

- (void)checkDoneButton
{
	if([self.filter.operator isEqualToString:@"MATCHES"] && isIOS4OrGreater())
	{
		NSError *error = nil;
		NSRegularExpressionOptions options = 0;
		if(self.filter.caseInsensitiveValue)
			options |= NSRegularExpressionCaseInsensitive;
		if([NSRegularExpression regularExpressionWithPattern:self.filter.value options:options error:&error])
		{
			[[self.navigationItem rightBarButtonItem] setEnabled:YES];
		}
#warning give them an error about the value
	}
	else
	{
		[[self.navigationItem rightBarButtonItem] setEnabled:[self.filter.operator length] != 0];
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)navigationControlDone:(id)sender 
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(filterViewControllerDone:)])
	{
		[self.delegate filterViewControllerDone:self];
	}
}	

- (void)loadView 
{
	[super loadView];
	self.editing = self.filter.listValue;

	[self.navigationItem setHidesBackButton:YES animated:YES];
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView operatorSelectedAtIndexPath:(NSIndexPath *)indexPath
{
	[self checkDoneButton];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView specificValueSelectedAtIndexPath:(NSIndexPath *)indexPath
{
	[[self.navigationItem rightBarButtonItem] setEnabled:YES];

	NSString *untranslatedValueTitle = (NSString *)labelCellController.userData;
	self.filter.untranslatedValueTitle = untranslatedValueTitle;
}

- (FilterTableViewController *)filterTableViewController
{
	if(filterTableViewController_ == nil)
	{
		filterTableViewController_ = [FilterTableViewController alloc];
		filterTableViewController_.filter = self.filter;
		filterTableViewController_.managedObjectContext = self.filter.managedObjectContext;
	}
	return filterTableViewController_;
}

- (void)resignAllFirstResponders
{
	for(UITextField *textField in self.allTextFields)
	{
		[textField resignFirstResponder];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self resignAllFirstResponders];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	self.title = self.filter.title;
	if(self.filter.listValue)
	{
		// Filters
		[self.filterTableViewController constructSectionControllersForTableViewController:self];
	}
	else
	{
		NSDictionary *foundEntry = nil;
		for(NSDictionary *group in [MTFilter displayEntriesForEntityName:self.filter.filterEntityName])
		{
			for(NSDictionary *entry in [group objectForKey:MTFilterGroupArray])
			{
				if([[entry objectForKey:MTFilterPath] isEqualToString:self.filter.path])
				{
					foundEntry = entry;
					break;
				}
			}
		}
		if(foundEntry)
		{
			self.title = [[PSLocalization localizationBundle] localizedStringForKey:self.filter.untranslatedName value:self.filter.untranslatedName table:@""];
			NSArray *filterValues = [foundEntry objectForKey:MTFilterValues];
			if(filterValues)
			{
				self.filter.operator = @"==";
				
				GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
				[self.sectionControllers addObject:sectionController];
				[sectionController release];
				
				int i = 0; 
				NSArray *filterValuesTitles = [foundEntry objectForKey:MTFilterValuesUntranslatedTitles];
				for(NSString *value in filterValues)
				{
					PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
					NSString *valueTitle = [filterValuesTitles objectAtIndex:i++];
					if(valueTitle)
					{
						cellController.title = [[PSLocalization localizationBundle] localizedStringForKey:valueTitle value:valueTitle table:@""];
					}
					else
					{
						cellController.title = value;
					}
					cellController.userData = valueTitle;
					cellController.model = self.filter;
					cellController.modelPath = @"value";
					cellController.checkedValue = value;
					[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:specificValueSelectedAtIndexPath:)];
					[self addCellController:cellController toSection:sectionController];
				}
			}
			else
			{
				switch([self.filter typeForPath])
				{
					default:
					case NSUndefinedAttributeType:
					case NSInteger16AttributeType:
					case NSInteger32AttributeType:
					case NSInteger64AttributeType:
					case NSDecimalAttributeType:
					case NSDoubleAttributeType:
					case NSFloatAttributeType:
					{
						{
							
							GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
							[self.sectionControllers addObject:sectionController];
							[sectionController release];
							
							PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
							cellController.model = self.filter;
							cellController.modelPath = @"value";
							cellController.placeholder = NSLocalizedString(@"Value", @"This is the placeholder text in the Display Rule detail screen where you name the display rule");
							cellController.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
							cellController.returnKeyType = UIReturnKeyDone;
							cellController.clearButtonMode = UITextFieldViewModeAlways;
							cellController.autocapitalizationType = UITextAutocapitalizationTypeNone;
							cellController.selectionStyle = UITableViewCellSelectionStyleNone;
							cellController.allTextFields = self.allTextFields;
							cellController.indentWhileEditing = NO;
						}
						{
							GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
							[self.sectionControllers addObject:sectionController];
							[sectionController release];
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Equals", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"==";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Greater Than or Equals", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @">=";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Less Than or Equals", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"<=";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Greater Than", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @">";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Less Than", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"<";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
						}						
						break;
					}
						
					case NSStringAttributeType:
					{
						
						if([self.filter.operator length] == 0)
						{
							self.filter.caseInsensitiveValue = YES;
							self.filter.diacriticInsensitiveValue = YES;
						}
						
						{
							
							GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
							[self.sectionControllers addObject:sectionController];
							[sectionController release];
							
							PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
							cellController.model = self.filter;
							cellController.modelPath = @"value";
							cellController.placeholder = NSLocalizedString(@"Value", @"This is the placeholder text in the Display Rule detail screen where you name the display rule");
							cellController.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
							cellController.returnKeyType = UIReturnKeyDone;
							cellController.clearButtonMode = UITextFieldViewModeAlways;
							cellController.autocapitalizationType = UITextAutocapitalizationTypeNone;
							cellController.selectionStyle = UITableViewCellSelectionStyleNone;
							cellController.allTextFields = self.allTextFields;
							cellController.indentWhileEditing = NO;
							[self addCellController:cellController toSection:sectionController];
						}
						{
							GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
							[self.sectionControllers addObject:sectionController];
							[sectionController release];
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Equals", @"Title for switch in the filter for the strings operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"LIKE";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Contains", @"Title for switch in the filter for the strings operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"CONTAINS";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Begins With", @"Title for switch in the filter for the strings operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"BEGINSWITH";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Ends With", @"Title for switch in the filter for the strings operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"ENDSWITH";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}

#if 0							
							if(isIOS4OrGreater())
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Regular Expression Match", @"Title for switch in the filter for the strings operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"MATCHES";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
#endif
						}						
						{
							GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
							[self.sectionControllers addObject:sectionController];
							[sectionController release];
							
							{
								PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Case Insensitive", @"Title for switch in the filter view to have the strings be compared in a case sensitive manor");
								cellController.model = self.filter;
								cellController.modelPath = @"caseInsensitive";
								cellController.selectionStyle = UITableViewCellSelectionStyleNone;
								[self addCellController:cellController toSection:sectionController];
							}
							{
								PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Diacritic Insensitive", @"Title for switch in the filter view to have the strings be compared in a diacritic sensitive manor");
								cellController.model = self.filter;
								cellController.modelPath = @"diacriticInsensitive";
								cellController.selectionStyle = UITableViewCellSelectionStyleNone;
								[self addCellController:cellController toSection:sectionController];
							}
						}
						break;
					}
					case NSBooleanAttributeType:
					{
						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];
						
						if([self.filter.operator length] == 0)
						{
							self.filter.operator = @"==";
							self.filter.value = @"NO";
						}
						
						{
							PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
							cellController.title = [[PSLocalization localizationBundle] localizedStringForKey:self.filter.untranslatedName value:self.filter.untranslatedName table:nil];
							cellController.model = self.filter;
							cellController.modelPath = @"value";
							cellController.modelValueIsString = YES;
							cellController.selectionStyle = UITableViewCellSelectionStyleNone;
							[self addCellController:cellController toSection:sectionController];
						}
						break;
					}
					case NSDateAttributeType:
					{
						{
							
							GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
							[self.sectionControllers addObject:sectionController];
							[sectionController release];
							
							PSDateCellController *cellController = [[PSDateCellController alloc] init];
							cellController.model = self.filter;
							cellController.modelPath = @"value";
							cellController.title = NSLocalizedString(@"Value", @"Label for filter view for the date value to match with");
							cellController.datePickerMode = UIDatePickerModeDateAndTime;
							cellController.modelValueIsString = YES;
							if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
							{
								[cellController setDateFormat:@"d/M/yyy"];
							}
							else
							{
								[cellController setDateFormat:NSLocalizedString(@"M/d/yyy", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
							}
							
							[self addCellController:cellController toSection:sectionController];
						}
						{
							GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
							[self.sectionControllers addObject:sectionController];
							[sectionController release];
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Equals", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"==";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Greater Than or Equals", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @">=";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Less Than or Equals", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"<=";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Greater Than", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @">";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
							
							{
								PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
								cellController.title = NSLocalizedString(@"Less Than", @"Title for switch in the filter for the number operator");
								cellController.model = self.filter;
								cellController.modelPath = @"operator";
								cellController.checkedValue = @"<";
								[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:operatorSelectedAtIndexPath:)];
								[self addCellController:cellController toSection:sectionController];
							}
						}						
						break;
					}
				}
			}
			
			{
				GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
				[self.sectionControllers addObject:sectionController];
				[sectionController release];
				
				PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
				cellController.title = NSLocalizedString(@"Invert Logic", @"Title for switch in the filter view to change the logical result of the filter to the logical alternate value TRUE->FALSE or FALSE->TRUE");
				cellController.model = self.filter;
				cellController.modelPath = @"not";
				cellController.selectionStyle = UITableViewCellSelectionStyleNone;
				[self addCellController:cellController toSection:sectionController];
			}
			
		}
		[self checkDoneButton];
	}
}

@end


#if 0
// String
// 		Value

// 		Equals
// 		Contains
// 		Starts With
// 		Ends with
//      MATCHES regular expression

//		not
//		case sensitive
//		diacritic sensitive

// NUMBER
//		Value

//		Equals
//		Less Than
//      Greater Than
//		Less Than or Equal To
//		Greater Than or Equal To

//		not

// BOOLEAN
//		Value

//		ON
//		OFF

//		not

#endif
