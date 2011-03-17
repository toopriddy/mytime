//
//  PSExtendedFetchedResultsController.h
//  MyTime
//
//  Created by Brent Priddy on 3/8/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface PSExtendedFetchedResultsController : NSObject<NSFetchedResultsControllerDelegate>
{
	BOOL _coreDataHasChangeContentBug;
	BOOL _requiresArraySorting;
	NSObject< NSFetchedResultsControllerDelegate > *_delegate;
	NSArray *_fetchedObjects;
	NSArray *_sections;
	NSArray *_sectionIndexTitles;
}

/* ========================================================*/
/* ========================= INITIALIZERS ====================*/
/* ========================================================*/

/* Initializes an instance of NSFetchedResultsController
 fetchRequest - the fetch request used to get the objects. It's expected that the sort descriptor used in the request groups the objects into sections.
 context - the context that will hold the fetched objects
 sectionNameKeyPath - keypath on resulting objects that returns the section name. This will be used to pre-compute the section information.
 cacheName - Section info is cached persistently to a private file under this name. Cached sections are checked to see if the time stamp matches the store, but not if you have illegally mutated the readonly fetch request, predicate, or sort descriptor.
 */
- (id)initWithFetchRequest:(NSFetchRequest *)theFetchRequest 
	  managedObjectContext:(NSManagedObjectContext *)context 
		sectionNameKeyPath:(NSString *)theSectionNameKeyPath 
				 cacheName:(NSString *)name
		   sortDescriptors:(NSArray *)theSortDescriptors;

/* Executes the fetch request on the store to get objects.
 Returns YES if successful or NO (and an error) if a problem occurred. 
 An error is returned if the fetch request specified doesn't include a sort descriptor that uses sectionNameKeyPath.
 After executing this method, the fetched objects can be accessed with the property 'fetchedObjects'
 */
- (BOOL)performFetch:(NSError **)error;

/* ========================================================*/
/* ====================== CONFIGURATION ===================*/
/* ========================================================*/

/* Delegate that is notified when the result set changes.
 */
@property (nonatomic, assign) NSObject< NSFetchedResultsControllerDelegate > *delegate;

@property (nonatomic, retain, readonly) NSString *sectionNameKeyPath;

@property (nonatomic, retain) NSArray *sortDescriptors;

@property (nonatomic, assign) BOOL requiresArraySorting;

/* ========================================================*/
/* ============= ACCESSING OBJECT RESULTS =================*/
/* ========================================================*/


@property (nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;

/* Returns the results of the fetch.
 Returns nil if the performFetch: hasn't been called.
 */
@property  (nonatomic, retain, readonly) NSArray *fetchedObjects;

/* Returns the fetched object at a given indexPath.
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/* Returns the indexPath of a given object.
 */
-(NSIndexPath *)indexPathForObject:(id)object;

/* ========================================================*/
/* =========== CONFIGURING SECTION INFORMATION ============*/
/* ========================================================*/
/*	These are meant to be optionally overridden by developers.
 */

/* Returns the corresponding section index entry for a given section name.	
 Default implementation returns the capitalized first letter of the section name.
 Developers that need different behavior can implement the delegate method -(NSString*)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName
 Only needed if a section index is used.
 */
- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName;

/* Returns the array of section index titles.
 It's expected that developers call this method when implementing UITableViewDataSource's
 - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
 
 The default implementation returns the array created by calling sectionIndexTitleForSectionName: on all the known sections.
 Developers should override this method if they wish to return a different array for the section index.
 Only needed if a section index is used.
 */
@property (nonatomic, retain, readonly) NSArray *sectionIndexTitles;

/* ========================================================*/
/* =========== QUERYING SECTION INFORMATION ===============*/
/* ========================================================*/

/* Returns an array of objects that implement the NSFetchedResultsSectionInfo protocol.
 It's expected that developers use the returned array when implementing the following methods of the UITableViewDataSource protocol
 
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; 
 - (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section; 
 
 */
@property (nonatomic, retain, readonly) NSArray *sections;

/* Returns the section number for a given section title and index in the section index.
 It's expected that developers call this method when executing UITableViewDataSource's
 - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
 */
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex;

@end
