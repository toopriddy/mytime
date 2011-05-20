//
//  NSManagedObjectContext+PriddySoftware.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSSortDescriptor(PriddySoftware)
+ (id)psSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending;
+ (id)psSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector;
@end


@interface NSManagedObjectContext(PriddySoftware)
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
						 withPredicate:(id)stringOrPredicate, ...;
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 propertiesToFetch:(NSArray *)propertiesToFetch
						 withPredicate:(id)stringOrPredicate, ...;
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 propertiesToFetch:(NSArray *)propertiesToFetch
				   withSortDescriptors:(NSArray *)sortDescriptors
						 withPredicate:(id)stringOrPredicate, ...;

- (NSUInteger)countForFetchedObjectsForEntityName:(NSString *)newEntityName
									withPredicate:(id)stringOrPredicate, ...;

- (NSDictionary *)dictionaryFromManagedObject:(NSManagedObject*)managedObject skipRelationshipNames:(NSArray *)skipRelationshipNames;
- (NSManagedObject*)managedObjectFromDictionary:(NSDictionary*)structureDictionary;
- (NSManagedObject*)managedObjectFromDictionary:(NSDictionary*)structureDictionary uniqueObjects:(NSDictionary *)uniqueObjects;


+ (void)presentErrorDialog:(NSError *)error;

@end
